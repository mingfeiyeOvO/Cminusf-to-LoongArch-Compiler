#include "CodeGen.hpp"

#include "CodeGenUtil.hpp"

void CodeGen::allocate() {
    // 备份 $ra $fp
    unsigned offset = PROLOGUE_OFFSET_BASE;

    // 为每个参数分配栈空间
    for (auto &arg : context.func->get_args()) {
        auto size = arg.get_type()->get_size();
        offset = offset + size;
        context.offset_map[&arg] = -static_cast<int>(offset);
    }

    // 为指令结果分配栈空间
    for (auto &bb : context.func->get_basic_blocks()) {
        for (auto &instr : bb.get_instructions()) {
            // 每个非 void 的定值都分配栈空间
            if (not instr.is_void()) {
                auto size = instr.get_type()->get_size();
                offset = offset + size;
                context.offset_map[&instr] = -static_cast<int>(offset);
            }
            // alloca 的副作用：分配额外空间
            if (instr.is_alloca()) {
                auto *alloca_inst = static_cast<AllocaInst *>(&instr);
                auto alloc_size = alloca_inst->get_alloca_type()->get_size();
                offset += alloc_size;
            }
        }
    }

    // 分配栈空间，需要是 16 的整数倍
    context.frame_size = ALIGN(offset, PROLOGUE_ALIGN);
}

void CodeGen::copy_stmt() {
    for (auto &succ : context.bb->get_succ_basic_blocks()) {
        for (auto &inst : succ->get_instructions()) {
            if (inst.is_phi()) {
                // 遍历后继块中 phi 的定值 bb
                for (unsigned i = 1; i < inst.get_operands().size(); i += 2) {
                    // phi 的定值 bb 是当前翻译块
                    if (inst.get_operand(i) == context.bb) {
                        auto *lvalue = inst.get_operand(i - 1);
                        if (lvalue->get_type()->is_float_type()) {
                            load_to_freg(lvalue, FReg::fa(0));
                            store_from_freg(&inst, FReg::fa(0));
                        } else {
                            load_to_greg(lvalue, Reg::a(0));
                            store_from_greg(&inst, Reg::a(0));
                        }
                        break;
                    }
                    // 如果没有找到当前翻译块，说明是 undef，无事可做
                }
            } else {
                break;
            }
        }
    }
}

void CodeGen::load_to_greg(Value *val, const Reg &reg) {
    assert(val->get_type()->is_integer_type() ||
           val->get_type()->is_pointer_type());

    if (auto *constant = dynamic_cast<ConstantInt *>(val)) {
        int32_t val = constant->get_value();
        if (IS_IMM_12(val)) {
            append_inst(ADDI WORD, {reg.print(), "$zero", std::to_string(val)});
        } else {
            load_large_int32(val, reg);
        }
    } else if (auto *global = dynamic_cast<GlobalVariable *>(val)) {
        append_inst(LOAD_ADDR, {reg.print(), global->get_name()});
    } else {
        load_from_stack_to_greg(val, reg);
    }
}

void CodeGen::load_large_int32(int32_t val, const Reg &reg) {
    int32_t high_20 = val >> 12; // si20
    uint32_t low_12 = val & LOW_12_MASK;
    append_inst(LU12I_W, {reg.print(), std::to_string(high_20)});
    append_inst(ORI, {reg.print(), reg.print(), std::to_string(low_12)});
}

void CodeGen::load_large_int64(int64_t val, const Reg &reg) {
    auto low_32 = static_cast<int32_t>(val & LOW_32_MASK);
    load_large_int32(low_32, reg);

    auto high_32 = static_cast<int32_t>(val >> 32);
    int32_t high_32_low_20 = (high_32 << 12) >> 12; // si20
    int32_t high_32_high_12 = high_32 >> 20;        // si12
    append_inst(LU32I_D, {reg.print(), std::to_string(high_32_low_20)});
    append_inst(LU52I_D,
                {reg.print(), reg.print(), std::to_string(high_32_high_12)});
}

void CodeGen::load_from_stack_to_greg(Value *val, const Reg &reg) {
    auto offset = context.offset_map.at(val);
    auto offset_str = std::to_string(offset);
    auto *type = val->get_type();
    if (IS_IMM_12(offset)) {
        if (type->is_int1_type()) {
            append_inst(LOAD BYTE, {reg.print(), "$fp", offset_str});
        } else if (type->is_int32_type()) {
            append_inst(LOAD WORD, {reg.print(), "$fp", offset_str});
        } else { // Pointer
            append_inst(LOAD DOUBLE, {reg.print(), "$fp", offset_str});
        }
    } else {
        load_large_int64(offset, reg);
        append_inst(ADD DOUBLE, {reg.print(), "$fp", reg.print()});
        if (type->is_int1_type()) {
            append_inst(LOAD BYTE, {reg.print(), reg.print(), "0"});
        } else if (type->is_int32_type()) {
            append_inst(LOAD WORD, {reg.print(), reg.print(), "0"});
        } else { // Pointer
            append_inst(LOAD DOUBLE, {reg.print(), reg.print(), "0"});
        }
    }
}

void CodeGen::store_from_greg(Value *val, const Reg &reg) {
    auto offset = context.offset_map.at(val);
    auto offset_str = std::to_string(offset);
    auto *type = val->get_type();
    if (IS_IMM_12(offset)) {
        if (type->is_int1_type()) {
            append_inst(STORE BYTE, {reg.print(), "$fp", offset_str});
        } else if (type->is_int32_type()) {
            append_inst(STORE WORD, {reg.print(), "$fp", offset_str});
        } else { // Pointer
            append_inst(STORE DOUBLE, {reg.print(), "$fp", offset_str});
        }
    } else {
        auto addr = Reg::t(8);
        load_large_int64(offset, addr);
        append_inst(ADD DOUBLE, {addr.print(), "$fp", addr.print()});
        if (type->is_int1_type()) {
            append_inst(STORE BYTE, {reg.print(), addr.print(), "0"});
        } else if (type->is_int32_type()) {
            append_inst(STORE WORD, {reg.print(), addr.print(), "0"});
        } else { // Pointer
            append_inst(STORE DOUBLE, {reg.print(), addr.print(), "0"});
        }
    }
}

void CodeGen::load_to_freg(Value *val, const FReg &freg) {
    assert(val->get_type()->is_float_type());
    if (auto *constant = dynamic_cast<ConstantFP *>(val)) {
        float val = constant->get_value();
        load_float_imm(val, freg);
    } else {
        auto offset = context.offset_map.at(val);
        auto offset_str = std::to_string(offset);
        if (IS_IMM_12(offset)) {
            append_inst(FLOAD SINGLE, {freg.print(), "$fp", offset_str});
        } else {
            auto addr = Reg::t(8);
            load_large_int64(offset, addr);
            append_inst(ADD DOUBLE, {addr.print(), "$fp", addr.print()});
            append_inst(FLOAD SINGLE, {freg.print(), addr.print(), "0"});
        }
    }
}

void CodeGen::load_float_imm(float val, const FReg &r) {
    int32_t bytes = *reinterpret_cast<int32_t *>(&val);
    load_large_int32(bytes, Reg::t(8));
    append_inst(GR2FR WORD, {r.print(), Reg::t(8).print()});
}

void CodeGen::store_from_freg(Value *val, const FReg &r) {
    auto offset = context.offset_map.at(val);
    if (IS_IMM_12(offset)) {
        auto offset_str = std::to_string(offset);
        append_inst(FSTORE SINGLE, {r.print(), "$fp", offset_str});
    } else {
        auto addr = Reg::t(8);
        load_large_int64(offset, addr);
        append_inst(ADD DOUBLE, {addr.print(), "$fp", addr.print()});
        append_inst(FSTORE SINGLE, {r.print(), addr.print(), "0"});
    }
}

void CodeGen::gen_prologue() {
    if (IS_IMM_12(-static_cast<int>(context.frame_size))) {
        append_inst("st.d $ra, $sp, -8");
        append_inst("st.d $fp, $sp, -16");
        append_inst("addi.d $fp, $sp, 0");
        append_inst("addi.d $sp, $sp, " +
                    std::to_string(-static_cast<int>(context.frame_size)));
    } else {
        load_large_int64(context.frame_size, Reg::t(0));
        append_inst("st.d $ra, $sp, -8");
        append_inst("st.d $fp, $sp, -16");
        append_inst("sub.d $sp, $sp, $t0");
        append_inst("add.d $fp, $sp, $t0");
    }

    int garg_cnt = 0;
    int farg_cnt = 0;
    for (auto &arg : context.func->get_args()) {
        if (arg.get_type()->is_float_type()) {
            store_from_freg(&arg, FReg::fa(farg_cnt++));
        } else { // int or pointer
            store_from_greg(&arg, Reg::a(garg_cnt++));
        }
    }
}

void CodeGen::gen_epilogue() {
    // TODO 根据你的理解设定函数的 epilogue
    // 恢复栈指针（释放栈帧空间）
    if (IS_IMM_12(context.frame_size)) {
        // 如果栈帧大小可以用立即数表示，直接调整栈指针
        append_inst("addi.d $sp, $sp, " + std::to_string(context.frame_size));
    } else {
        // 否则使用临时寄存器加载偏移量
        load_large_int64(context.frame_size, Reg::t(0));
        append_inst("add.d $sp, $sp, $t0");
    }
    // 恢复返回地址寄存器 ra 和帧指针 fp
    append_inst("ld.d $ra, $sp, -8");
    append_inst("ld.d $fp, $sp, -16");
    // 返回指令
    append_inst("jr $ra");
    
}

void CodeGen::gen_ret() {
    // TODO 函数返回，思考如何处理返回值、寄存器备份，如何返回调用者地址
    if (context.func->get_return_type()->is_integer_type() || 
        context.func->get_return_type()->is_pointer_type()) {
        // 整数或指针返回值 -> $a0
        load_to_greg(context.inst->get_operand(0), Reg::a(0));
    } else if (context.func->get_return_type()->is_float_type()) {
        // 浮点返回值 -> $fa0
        load_to_freg(context.inst->get_operand(0), FReg::fa(0));
    } else if (context.func->get_return_type()->is_void_type()) {
        // 对于 void 类型函数，清零返回寄存器
        append_inst(ADD DOUBLE, {Reg::a(0).print(), Reg::zero().print(), Reg::zero().print()});
    }
    // 恢复上下文
    gen_epilogue();
    // 返回调用者地址
    append_inst("jr $ra");
}

void CodeGen::gen_br() {
    auto *branchInst = static_cast<BranchInst *>(context.inst);
    if (branchInst->is_cond_br()) {
        // TODO 补全条件跳转的情况
        // 获取条件操作数和两个目标基本块
        auto *cond = branchInst->get_operand(0);
        auto *trueBB = static_cast<BasicBlock *>(branchInst->get_operand(1));
        auto *falseBB = static_cast<BasicBlock *>(branchInst->get_operand(2));
        // 加载条件值到寄存器
        load_to_greg(cond, Reg::t(0));
        // 重要的处理
        append_inst("bstrpick.d $t1, $t0, 0, 0");
        // 生成条件跳转指令
        append_inst("bnez " + Reg::t(1).print() + ", " + label_name(trueBB)); // 条件为真时跳转
        append_inst("b " + label_name(falseBB)); // 否则跳转到假分支
    } else {
        auto *branchbb = static_cast<BasicBlock *>(branchInst->get_operand(0));
        append_inst("b " + label_name(branchbb));
    }
}

void CodeGen::gen_binary() {
    load_to_greg(context.inst->get_operand(0), Reg::t(0));
    load_to_greg(context.inst->get_operand(1), Reg::t(1));
    switch (context.inst->get_instr_type()) {
    case Instruction::add:
        output.emplace_back("add.w $t2, $t0, $t1");
        break;
    case Instruction::sub:
        output.emplace_back("sub.w $t2, $t0, $t1");
        break;
    case Instruction::mul:
        output.emplace_back("mul.w $t2, $t0, $t1");
        break;
    case Instruction::sdiv:
        output.emplace_back("div.w $t2, $t0, $t1");
        break;
    default:
        assert(false);
    }
    store_from_greg(context.inst, Reg::t(2));
}

void CodeGen::gen_float_binary() {
    // TODO 浮点类型的二元指令
    // 获取操作数和指令类型
    auto *inst = context.inst;
    auto *operand1 = inst->get_operand(0);
    auto *operand2 = inst->get_operand(1);
    // 加载操作数到浮点寄存器
    load_to_freg(operand1, FReg::fa(0)); // 加载第一个操作数到 $fa0
    load_to_freg(operand2, FReg::fa(1)); // 加载第二个操作数到 $fa1
    // 根据指令类型生成浮点运算指令
    switch (inst->get_instr_type()) {
    case Instruction::fadd:
        append_inst("fadd.s " + FReg::fa(2).print() + ", " + FReg::fa(0).print() + ", " + FReg::fa(1).print());
        break;
    case Instruction::fsub:
        append_inst("fsub.s " + FReg::fa(2).print() + ", " + FReg::fa(0).print() + ", " + FReg::fa(1).print());
        break;
    case Instruction::fmul:
        append_inst("fmul.s " + FReg::fa(2).print() + ", " + FReg::fa(0).print() + ", " + FReg::fa(1).print());
        break;
    case Instruction::fdiv:
        append_inst("fdiv.s " + FReg::fa(2).print() + ", " + FReg::fa(0).print() + ", " + FReg::fa(1).print());
        break;
    default:
        assert(false);
    }
    // 将结果存储回目标变量
    store_from_freg(inst, FReg::fa(2)); // 将 $fa2 中的结果存储到 inst 的目标位置
}

void CodeGen::gen_alloca() {
    /* 我们已经为 alloca 的内容分配空间，在此我们还需保存 alloca
     * 指令自身产生的定值，即指向 alloca 空间起始地址的指针
     */
    // TODO 将 alloca 出空间的起始地址保存在栈帧上
    auto *allocaInst = static_cast<AllocaInst*>(context.inst);
    int offset = context.offset_map.at(context.inst) - allocaInst->get_alloca_type()->get_size();
    // 分配内存，调整栈指针
    append_inst(ADDI DOUBLE, { Reg::t(1).print(),Reg::fp().print(),std::to_string(offset) });
    // 将栈指针保存为 alloca 指针的值
    store_from_greg(context.inst, Reg::t(1));
}

void CodeGen::gen_load() {
    auto *ptr = context.inst->get_operand(0);
    auto *type = context.inst->get_type();
    load_to_greg(ptr, Reg::t(0));

    if (type->is_float_type()) {
        append_inst("fld.s $ft0, $t0, 0");
        store_from_freg(context.inst, FReg::ft(0));
    } else {
        // TODO load 整数类型的数据
        if (type->is_int1_type()) { // 1 字节整数
            append_inst("ld.b $t1, $t0, 0");
        } else if (type->is_int32_type()) {     // 4 字节整数
            append_inst("ld.w $t1, $t0, 0");
        } else { // 假定是指针类型或 8 字节整数
            append_inst("ld.d $t1, $t0, 0");
        }
        // 存储加载的整数值
        store_from_greg(context.inst, Reg::t(1)); // 将 $t1 的值存储到目标变量
    }
}

void CodeGen::gen_store() {
    // TODO 翻译 store 指令
    auto *value = context.inst->get_operand(0);  // 待存储的值
    auto *ptr = context.inst->get_operand(1); // 存储目标地址
    // 加载目标地址到 $t0
    load_to_greg(ptr, Reg::t(0));
    // 判断存储值的类型
    auto *type = value->get_type();
    if (type->is_float_type()) {
        // 浮点数存储
        load_to_freg(value, FReg::ft(0));
        append_inst("fst.s $ft0, $t0, 0"); // 单精度浮点存储
    } else {
        // 整数或指针类型存储
        load_to_greg(value, Reg::t(1));
        if (type->is_int1_type()) {
            append_inst("st.b $t1, $t0, 0"); // 存储 1 字节
        } else if (type->is_int32_type()) {
            append_inst("st.w $t1, $t0, 0"); // 存储 4 字节
        } else { // 默认为指针或 8 字节整数
            append_inst("st.d $t1, $t0, 0"); // 存储 8 字节
        }
    }
}

void CodeGen::gen_icmp() {
    // TODO 处理各种整数比较的情况
    auto *icmpInst = static_cast<ICmpInst *>(context.inst);
    // 加载操作数到寄存器
    load_to_greg(icmpInst->get_operand(0), Reg::t(0));
    load_to_greg(icmpInst->get_operand(1), Reg::t(1));
    // 获取比较类型
    auto cmpType = icmpInst->get_instr_type();
    // 生成比较指令
    switch (cmpType) {
        case ICmpInst::eq: // 等于
            append_inst("slt $t2, $t0, $t1");
            append_inst("slt $t3, $t1, $t0");
            append_inst("nor $t0, $t2, $t3");
            break;
        case ICmpInst::ne: // 不等于
            append_inst("slt $t2, $t0, $t1");
            append_inst("slt $t3, $t1, $t0");
            append_inst("or $t0, $t2, $t3");
            break;
        case ICmpInst::lt: // 小于
            append_inst("slt $t0, $t0, $t1");
            break;
        case ICmpInst::le: // 小于等于
            append_inst("addi.w $t1, $t1, 1");
            append_inst("slt $t0, $t0, $t1");
            break;
        case ICmpInst::gt: // 大于
            append_inst("slt $t0, $t1, $t0");
            break;
        case ICmpInst::ge: // 大于等于
            append_inst("addi.w $t0, $t0, 1");
            append_inst("slt $t0, $t1, $t0");
            break;
        default:
            assert(false);
    }

    // 存储结果
    store_from_greg(context.inst, Reg::t(0));
}

void CodeGen::gen_fcmp() {
    // TODO 处理各种浮点数比较的情况
    auto *fcmpInst = static_cast<FCmpInst*>(context.inst);
    // 加载操作数到寄存器
    load_to_freg(fcmpInst->get_operand(0), FReg::ft(0));
    load_to_freg(fcmpInst->get_operand(1), FReg::ft(1));
    // 获取比较类型
    auto cmpType = fcmpInst->get_instr_type();
    // 生成比较指令
    switch (cmpType) {
        case Instruction::feq:
            append_inst("fcmp.seq.s $ft0, $ft0, $ft1");
            break;
        case Instruction::fne:
            append_inst("fcmp.sne.s $ft0, $ft0, $ft1");
            break;
        case Instruction::flt:
            append_inst("fcmp.slt.s $ft0, $ft0, $ft1");
            break;
        case Instruction::fle:
            append_inst("fcmp.sle.s $ft0, $ft0, $ft1");
            break;
        case Instruction::fgt:
            append_inst("fcmp.slt.s $ft0, $ft1, $ft0");
            break;
        case Instruction::fge:
            append_inst("fcmp.sle.s $ft0, $ft1, $ft0");
            break;
        default:
            assert(false);
    }
    // 存储结果
    store_from_freg(context.inst, FReg::ft(0));
}

void CodeGen::gen_zext() {
    // TODO 将窄位宽的整数数据进行零扩展
    auto *zextInst = static_cast<ZextInst *>(context.inst);
    // 获取操作数和类型信息
    auto *src = zextInst->get_operand(0);
    auto *destType = zextInst->get_type();
    // 加载源操作数到寄存器
    load_to_greg(src, Reg::t(0));
    // 判断是否需要扩展
    if (destType->is_int32_type()) {
        // 使用 bstrpick.w 提取并扩展
        append_inst("bstrpick.w $t1, $t0, 0, 0");
    } else {
        // 使用 bstrpick.d 提取并扩展
        append_inst("bstrpick.d $t1, $t0, 0, 0");
    }
    // 存储结果
    store_from_greg(context.inst, Reg::t(1));
}

void CodeGen::gen_call() {
    // TODO 函数调用，注意我们只需要通过寄存器传递参数，即不需考虑栈上传参的情况
    auto *callInst = static_cast<CallInst *>(context.inst);
    auto &args = callInst->get_operands();    // 获取函数参数
    int intArgCount = 0;  // 整数参数计数
    int floatArgCount = 0; // 浮点参数计数
    // 处理参数传递
    for (auto *arg : args) {
        if (arg->get_type()->is_float_type()) {
            // 加载浮点参数到浮点寄存器
            load_to_freg(arg, FReg::fa(floatArgCount++));
        } else if (arg->get_type()->is_integer_type() || arg->get_type()->is_pointer_type()) {
            // 加载整数或指针参数到通用寄存器
            load_to_greg(arg, Reg::a(intArgCount++));
        }
    }
    // 生成调用指令
    append_inst("bl " + callInst->get_operand(0)->get_name());
    // 返回值处理
    auto *retType = callInst->get_function_type()->get_return_type();
    if (!retType->is_void_type()) {
        if (retType->is_float_type()) {
            store_from_freg(callInst, FReg::fa(0));
        } else {
            store_from_greg(callInst, Reg::a(0));
        }
    }
}

/*
 * %op = getelementptr [10 x i32], [10 x i32]* %op, i32 0, i32 %op
 * %op = getelementptr        i32,        i32* %op, i32 %op
 *
 * Memory layout
 *       -            ^
 * +-----------+      | Smaller address
 * |  arg ptr  |---+  |
 * +-----------+   |  |
 * |           |   |  |
 * +-----------+   /  |
 * |           |<--   |
 * |           |   \  |
 * |           |   |  |
 * |   Array   |   |  |
 * |           |   |  |
 * |           |   |  |
 * |           |   |  |
 * +-----------+   |  |
 * |  Pointer  |---+  |
 * +-----------+      |
 * |           |      |
 * +-----------+      |
 * |           |      |
 * +-----------+      |
 * |           |      |
 * +-----------+      | Larger address
 *       +
 */
void CodeGen::gen_gep() {
    // TODO 计算内存地址
    // 获取指令和基本操作数
    auto* gepInst = static_cast<GetElementPtrInst*>(context.inst);
    auto* base = gepInst->get_operand(0); // 基地址
    load_to_greg(base, Reg::t(0));        // 加载基地址到 $t0
    // 处理数组类型
    if (static_cast<PointerType*>(base->get_type())->get_element_type()->is_array_type()) {
        // 一级索引
        auto* op1 = gepInst->get_operand(1);
        load_to_greg(op1, Reg::t(1)); // 加载 op1 到 $t1
        // 二级索引
        auto* op2 = gepInst->get_operand(2);
        load_to_greg(op2, Reg::t(2)); // 加载 op2 到 $t2
        // 加载数组元素大小和数组本身大小
        int32_t array_element_size = static_cast<PointerType*>(base->get_type())->get_element_type()->get_array_element_type()->get_size();
        int32_t array_size = static_cast<PointerType*>(base->get_type())->get_element_type()->get_size();
        // 将大小常量加载到寄存器
        load_large_int32(array_size, Reg::t(3));          // $t3 = 数组单元大小
        load_large_int32(array_element_size, Reg::t(4)); // $t4 = 元素大小
        // 计算偏移量
        append_inst(MUL WORD, { Reg::t(1).print(), Reg::t(1).print(), Reg::t(3).print() }); // $t1 = op1 * array_size
        append_inst(MUL WORD, { Reg::t(2).print(), Reg::t(2).print(), Reg::t(4).print() }); // $t2 = op2 * element_size
        // 将偏移值限制为 32 位有效范围
        append_inst("bstrpick.d $t1, $t1, 31, 0");
        append_inst("bstrpick.d $t2, $t2, 31, 0");
        // 累加到基地址
        append_inst(ADD DOUBLE, { Reg::t(0).print(), Reg::t(0).print(), Reg::t(1).print() }); // $t0 += $t1
        append_inst(ADD DOUBLE, { Reg::t(0).print(), Reg::t(0).print(), Reg::t(2).print() }); // $t0 += $t2
    } 
    // 处理非数组类型
    else {
        auto* op1 = gepInst->get_operand(1); // 获取一级索引
        load_to_greg(op1, Reg::t(1));        // 加载到 $t1
        // 加载元素大小
        int32_t element_size = static_cast<PointerType*>(base->get_type())->get_pointer_element_type()->get_size();
        load_large_int32(element_size, Reg::t(3)); // $t3 = 元素大小
        // 计算偏移量
        append_inst(MUL WORD, { Reg::t(1).print(), Reg::t(1).print(), Reg::t(3).print() }); // $t1 = op1 * element_size
        // 将偏移值限制为 32 位有效范围
        append_inst("bstrpick.d $t1, $t1, 31, 0");
        // 累加到基地址
        append_inst(ADD DOUBLE, { Reg::t(0).print(), Reg::t(0).print(), Reg::t(1).print() }); // $t0 += $t1
    }
    // 存储最终地址
    store_from_greg(context.inst, Reg::t(0)); // 将结果地址保存到指令对应的寄存器
}


void CodeGen::gen_sitofp() {
    // TODO 整数转向浮点数
    auto* siInst = static_cast<SiToFpInst*>(context.inst);
    auto *srcValue = siInst->get_operand(0);
    // 将整数值加载到通用寄存器 t0
    load_to_greg(srcValue, Reg::t(0));
    // 搬运到浮点数寄存器
    append_inst("movgr2fr.w $ft0, $t0");
    // 转换为单精度浮点数
    append_inst("ffint.s.w $ft1, $ft0");
    store_from_freg(siInst, FReg::ft(1)); // 存储结果
}

void CodeGen::gen_fptosi() {
    // TODO 浮点数转向整数，注意向下取整(round to zero)
    auto* fpInst = static_cast<FpToSiInst*>(context.inst);
    auto* srcValue = fpInst->get_operand(0);
    // 将浮点数值加载到寄存器 ft0
    load_to_freg(srcValue, FReg::ft(0));
    // 转换为整数
    append_inst("ftintrz.w.s $ft1, $ft0");
    store_from_freg(context.inst, FReg::ft(1));
}

void CodeGen::run() {
    // 确保每个函数中基本块的名字都被设置好
    m->set_print_name();

    /* 使用 GNU 伪指令为全局变量分配空间
     * 你可以使用 `la.local` 指令将标签 (全局变量) 的地址载入寄存器中, 比如
     * 要将 `a` 的地址载入 $t0, 只需要 `la.local $t0, a`
     */
    if (!m->get_global_variable().empty()) {
        append_inst("Global variables", ASMInstruction::Comment);
        /* 虽然下面两条伪指令可以简化为一条 `.bss` 伪指令, 但是我们还是选择使用
         * `.section` 将全局变量放到可执行文件的 BSS 段, 原因如下:
         * - 尽可能对齐交叉编译器 loongarch64-unknown-linux-gnu-gcc 的行为
         * - 支持更旧版本的 GNU 汇编器, 因为 `.bss` 伪指令是应该相对较新的指令,
         *   GNU 汇编器在 2023 年 2 月的 2.37 版本才将其引入
         */
        append_inst(".text", ASMInstruction::Atrribute);
        append_inst(".section", {".bss", "\"aw\"", "@nobits"},
                    ASMInstruction::Atrribute);
        for (auto &global : m->get_global_variable()) {
            auto size =
                global.get_type()->get_pointer_element_type()->get_size();
            append_inst(".globl", {global.get_name()},
                        ASMInstruction::Atrribute);
            append_inst(".type", {global.get_name(), "@object"},
                        ASMInstruction::Atrribute);
            append_inst(".size", {global.get_name(), std::to_string(size)},
                        ASMInstruction::Atrribute);
            append_inst(global.get_name(), ASMInstruction::Label);
            append_inst(".space", {std::to_string(size)},
                        ASMInstruction::Atrribute);
        }
    }

    // 函数代码段
    output.emplace_back(".text", ASMInstruction::Atrribute);
    for (auto &func : m->get_functions()) {
        if (not func.is_declaration()) {
            // 更新 context
            context.clear();
            context.func = &func;

            // 函数信息
            append_inst(".globl", {func.get_name()}, ASMInstruction::Atrribute);
            append_inst(".type", {func.get_name(), "@function"},
                        ASMInstruction::Atrribute);
            append_inst(func.get_name(), ASMInstruction::Label);

            // 分配函数栈帧
            allocate();
            // 生成 prologue
            gen_prologue();

            for (auto &bb : func.get_basic_blocks()) {
                context.bb = &bb;
                append_inst(label_name(context.bb), ASMInstruction::Label);
                for (auto &instr : bb.get_instructions()) {
                    // For debug
                    append_inst(instr.print(), ASMInstruction::Comment);
                    context.inst = &instr; // 更新 context
                    switch (instr.get_instr_type()) {
                    case Instruction::ret:
                        gen_ret();
                        break;
                    case Instruction::br:
                        copy_stmt();
                        gen_br();
                        break;
                    case Instruction::add:
                    case Instruction::sub:
                    case Instruction::mul:
                    case Instruction::sdiv:
                        gen_binary();
                        break;
                    case Instruction::fadd:
                    case Instruction::fsub:
                    case Instruction::fmul:
                    case Instruction::fdiv:
                        gen_float_binary();
                        break;
                    case Instruction::alloca:
                        /* 对于 alloca 指令，我们已经为 alloca
                         * 的内容分配空间，在此我们还需保存 alloca
                         * 指令自身产生的定值，即指向 alloca 空间起始地址的指针
                         */
                        gen_alloca();
                        break;
                    case Instruction::load:
                        gen_load();
                        break;
                    case Instruction::store:
                        gen_store();
                        break;
                    case Instruction::ge:
                    case Instruction::gt:
                    case Instruction::le:
                    case Instruction::lt:
                    case Instruction::eq:
                    case Instruction::ne:
                        gen_icmp();
                        break;
                    case Instruction::fge:
                    case Instruction::fgt:
                    case Instruction::fle:
                    case Instruction::flt:
                    case Instruction::feq:
                    case Instruction::fne:
                        gen_fcmp();
                        break;
                    case Instruction::phi:
                        /* for phi, just convert to a series of
                         * copy-stmts */
                        /* we can collect all phi and deal them at
                         * the end */
                        break;
                    case Instruction::call:
                        gen_call();
                        break;
                    case Instruction::getelementptr:
                        gen_gep();
                        break;
                    case Instruction::zext:
                        gen_zext();
                        break;
                    case Instruction::fptosi:
                        gen_fptosi();
                        break;
                    case Instruction::sitofp:
                        gen_sitofp();
                        break;
                    }
                }
            }
            // 生成 epilogue
            gen_epilogue();
        }
    }
}

std::string CodeGen::print() const {
    std::string result;
    for (const auto &inst : output) {
        result += inst.format();
    }
    return result;
}
