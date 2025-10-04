# Cminusf编译器 - 详细代码分析笔记

## 1. 编译器主程序流程 (main.cpp)

### 核心编译流程
```cpp
int main(int argc, char **argv) {
    Config config(argc, argv);                    // 1. 命令行参数解析
    
    auto syntax_tree = parse(config.input_file.c_str());  // 2. 词法语法分析
    auto ast = AST(syntax_tree);                  // 3. 构建AST
    
    if (config.emitast) {                         // 4a. 输出AST（调试模式）
        ASTPrinter printer;
        ast.run_visitor(printer);
    } else {
        CminusfBuilder builder;                   // 4b. AST转IR
        ast.run_visitor(builder);                 // 访问者模式遍历
        m = builder.getModule();                  // 获取IR模块
        
        PassManager PM(m.get());                  // 5. 优化管理器
        if(config.mem2reg) {                      // 6. 条件优化
            PM.add_pass<Mem2Reg>();
            PM.add_pass<DeadCode>();
        }
        PM.run();                                 // 执行优化
        
        if (config.emitllvm) {                    // 7a. 输出LLVM IR
            output_stream << m->print();
        } else if (config.emitasm) {              // 7b. 输出汇编
            CodeGen codegen(m.get());
            codegen.run();
            output_stream << codegen.print();
        }
    }
}
```

### 配置系统分析
```cpp
struct Config {
    std::filesystem::path input_file;
    std::filesystem::path output_file;
    bool emitast{false};     // 输出AST
    bool emitasm{false};     // 输出汇编
    bool emitllvm{false};    // 输出LLVM IR
    bool mem2reg{false};     // Mem2Reg优化
    bool licm{false};        // 循环优化
};
```

**关键特性**:
- 支持多种输出格式（AST、IR、汇编）
- 模块化的优化选项
- 现代C++17特性（filesystem、智能指针）


## 2. AST设计和访问者模式

### AST节点类型系统
```cpp
enum CminusType { TYPE_INT, TYPE_FLOAT, TYPE_VOID };

enum RelOp { OP_LE, OP_LT, OP_GT, OP_GE, OP_EQ, OP_NEQ };
enum AddOp { OP_PLUS, OP_MINUS };
enum MulOp { OP_MUL, OP_DIV };
```

### 访问者模式实现
```cpp
struct ASTNode {
    virtual Value* accept(ASTVisitor &) = 0;  // 纯虚函数，强制实现
    virtual ~ASTNode() = default;
};

// 具体节点类型
struct ASTProgram : ASTNode {
    virtual Value* accept(ASTVisitor &) override final;
    std::vector<std::shared_ptr<ASTDeclaration>> declarations;
};
```

**设计亮点**:
- 使用智能指针管理内存（shared_ptr）
- 虚函数实现多态
- 访问者模式解耦遍历和操作

### IR生成器 (CminusfBuilder)

#### 类型系统初始化
```cpp
Value *CminusfBuilder::visit(ASTProgram &node) {
    VOID_T = module->get_void_type();
    INT1_T = module->get_int1_type();
    INT32_T = module->get_int32_type();
    INT32PTR_T = module->get_int32_ptr_type();
    FLOAT_T = module->get_float_type();
    FLOATPTR_T = module->get_float_ptr_type();
    
    // 遍历所有声明
    for (auto &decl : node.declarations) {
        ret_val = decl->accept(*this);  // 递归调用
    }
}
```

#### 类型提升机制
```cpp
bool promote(IRBuilder *builder, Value **l_val_p, Value **r_val_p) {
    bool is_int = false;
    auto &l_val = *l_val_p;
    auto &r_val = *r_val_p;
    
    if (l_val->get_type() == r_val->get_type()) {
        is_int = l_val->get_type()->is_integer_type();
    } else {
        // 自动类型提升：int -> float
        if (l_val->get_type()->is_integer_type()) {
            l_val = builder->create_sitofp(l_val, FLOAT_T);
        } else {
            r_val = builder->create_sitofp(r_val, FLOAT_T);
        }
    }
    return is_int;
}
```

**关键特性**:
- 自动类型提升（int→float）
- 类型安全检查
- SSA形式IR生成


## 3. 优化Pass实现分析

### Mem2Reg: 内存到寄存器提升

#### 算法流程
```cpp
void Mem2Reg::run() {
    // 1. 建立支配树
    dominators_ = std::make_unique<Dominators>(m_);
    dominators_->run();
    
    for (auto &f : m_->get_functions()) {
        if (f.is_declaration()) continue;
        
        // 2. 插入phi指令
        generate_phi();
        
        // 3. 变量重命名
        rename(func_->get_entry_block());
    }
}
```

#### Phi指令插入算法
```cpp
void Mem2Reg::generate_phi() {
    // 步骤1: 找到全局活跃变量
    std::set<Value *> global_live_var_name;
    std::map<Value *, std::set<BasicBlock *>> live_var_2blocks;
    
    for (auto &bb : func_->get_basic_blocks()) {
        for (auto &instr : bb.get_instructions()) {
            if (instr.is_store()) {
                auto l_val = static_cast<StoreInst *>(&instr)->get_lval();
                if (is_valid_ptr(l_val)) {
                    global_live_var_name.insert(l_val);
                    live_var_2blocks[l_val].insert(&bb);
                }
            }
        }
    }
    
    // 步骤2: 在支配边界插入phi指令
    for (auto var : global_live_var_name) {
        // 在每个支配边界插入phi节点
        work_list.assign(live_var_2blocks[var].begin(),
                        live_var_2blocks[var].end());
        // ... 插入phi指令的具体逻辑
    }
}
```

**技术要点**:
- 基于支配树的phi函数插入
- 静态单赋值形式构造
- 消除冗余的内存访问

### LICM: 循环不变量外提

#### 算法框架
```cpp
void LoopInvariantCodeMotion::run() {
    // 1. 循环检测
    loop_detection_ = std::make_unique<LoopDetection>(m_);
    loop_detection_->run();
    
    // 2. 函数信息分析
    func_info_ = std::make_unique<FuncInfo>(m_);
    func_info_->run();
    
    // 3. 遍历每个循环
    for (auto &loop : loop_detection_->get_loops()) {
        traverse_loop(loop);
    }
}
```

**关键特性**:
- 依赖循环检测pass
- 需要支配关系分析
- 确保外提的安全性

## 4. 代码生成器 (CodeGen)

### 栈空间分配
```cpp
void CodeGen::allocate() {
    unsigned offset = PROLOGUE_OFFSET_BASE;
    
    // 1. 为函数参数分配栈空间
    for (auto &arg : context.func->get_args()) {
        auto size = arg.get_type()->get_size();
        offset = offset + size;
        context.offset_map[&arg] = -static_cast<int>(offset);
    }
    
    // 2. 为指令结果分配栈空间
    for (auto &bb : context.func->get_basic_blocks()) {
        for (auto &instr : bb.get_instructions()) {
            if (not instr.is_void()) {
                auto size = instr.get_type()->get_size();
                offset = offset + size;
                context.offset_map[&instr] = -static_cast<int>(offset);
            }
            
            // 3. alloca指令的额外空间分配
            if (instr.is_alloca()) {
                auto *alloca_inst = static_cast<AllocaInst *>(&instr);
                auto alloc_size = alloca_inst->get_alloca_type()->get_size();
                offset += alloc_size;
            }
        }
    }
}
```

**设计特点**:
- 简单的栈式内存管理
- 为每个IR值分配栈位置
- 支持动态内存分配(alloca)


## 5. 控制流语句的IR生成

### if-else语句处理
```cpp
Value *CminusfBuilder::visit(ASTSelectionStmt &node) {
    // 1. 计算条件表达式
    auto *ret_val = node.expression->accept(*this);
    
    // 2. 创建基本块
    auto *trueBB = BasicBlock::create(module.get(), "", context.func);
    BasicBlock *falseBB{};
    auto *contBB = BasicBlock::create(module.get(), "", context.func);
    
    // 3. 类型转换：将值转为布尔条件
    Value *cond_val = nullptr;
    if (ret_val->get_type()->is_integer_type()) {
        cond_val = builder->create_icmp_ne(ret_val, CONST_INT(0));
    } else {
        cond_val = builder->create_fcmp_ne(ret_val, CONST_FP(0.));
    }
    
    // 4. 创建条件分支
    if (node.else_statement == nullptr) {
        builder->create_cond_br(cond_val, trueBB, contBB);
    } else {
        falseBB = BasicBlock::create(module.get(), "", context.func);
        builder->create_cond_br(cond_val, trueBB, falseBB);
    }
    
    // 5. 生成then分支代码
    builder->set_insert_point(trueBB);
    node.if_statement->accept(*this);
}
```

### while循环处理
```cpp
Value *CminusfBuilder::visit(ASTIterationStmt &node) {
    // 1. 创建循环条件检查块
    auto *exprBB = BasicBlock::create(module.get(), "", context.func);
    builder->create_br(exprBB);
    builder->set_insert_point(exprBB);

    // 2. 计算循环条件
    auto *ret_val = node.expression->accept(*this);
    auto *trueBB = BasicBlock::create(module.get(), "", context.func);
    auto *contBB = BasicBlock::create(module.get(), "", context.func);
    
    // 3. 条件转换和分支
    Value *cond_val = (ret_val->get_type()->is_integer_type()) 
        ? builder->create_icmp_ne(ret_val, CONST_INT(0))
        : builder->create_fcmp_ne(ret_val, CONST_FP(0.));
    
    builder->create_cond_br(cond_val, trueBB, contBB);
    
    // 4. 生成循环体
    builder->set_insert_point(trueBB);
    node.statement->accept(*this);
    // 循环回跳到条件检查
    builder->create_br(exprBB);
}
```

## 6. 实际编译示例分析

### 源代码示例 (递归函数)
```c
int factorial(int a) { 
    if(a==0) 
        return 1;
    else
        return a*factorial(a-1); 
}
int main(void) {
    int result;
    result = factorial(10);
    return result;
}
```

### 生成的优化IR
```llvm
define i32 @factorial(i32 %arg0) {
label_entry:
  %op1 = icmp eq i32 %arg0, 0        ; 比较 a == 0
  %op2 = zext i1 %op1 to i32         ; 布尔值扩展
  %op3 = icmp ne i32 %op2, 0         ; 转换为条件
  br i1 %op3, label %label4, label %label5  ; 条件分支

label4:                               ; if分支
  ret i32 1                          ; return 1

label5:                               ; else分支
  %op6 = sub i32 %arg0, 1            ; a-1
  %op7 = call i32 @factorial(i32 %op6) ; 递归调用
  %op8 = mul i32 %arg0, %op7         ; a * factorial(a-1)
  ret i32 %op8                       ; 返回结果
}
```

## 7. 编译器技术亮点总结

### 现代编译器特性
1. **SSA形式IR**: 静态单赋值，便于优化分析
2. **类型安全**: 强类型系统确保编译正确性
3. **模块化设计**: Pass管理器支持优化组合
4. **内存管理**: 智能指针自动管理内存

### 优化算法实现
1. **支配树分析**: O(n log n)算法复杂度
2. **Mem2Reg**: 经典SSA构造算法
3. **循环检测**: 基于深度优先搜索
4. **LICM**: 循环不变量识别和外提

### 工程实践特色
1. **测试驱动**: 完整的回归测试套件
2. **错误处理**: 多层次的错误检测机制
3. **调试支持**: 支持IR和AST的可视化输出
4. **平台适配**: 针对LoongArch的后端优化

## 8. 面试重点技术问题准备

### 深度问题1: "SSA构造的具体算法是什么？"
**答案要点**:
- Phi函数插入：在支配边界处插入
- 变量重命名：深度优先遍历重命名
- 支配树计算：Lengauer-Tarjan算法

### 深度问题2: "如何保证LICM优化的正确性？"
**答案要点**:
- 循环不变性检查：操作数都是循环不变
- 支配关系验证：确保外提位置安全
- 副作用分析：避免改变程序语义

### 深度问题3: "代码生成器如何处理寄存器分配？"
**答案要点**:
- 线性扫描算法：简单高效的分配策略
- 栈溢出处理：寄存器不够时使用栈
- 调用约定：遵循LoongArch ABI规范

这个编译器项目展示了对编译原理的深入理解和优秀的工程实践能力！

