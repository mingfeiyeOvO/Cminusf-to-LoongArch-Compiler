#include "BasicBlock.hpp"
#include "Constant.hpp"
#include "Function.hpp"
#include "GlobalVariable.hpp"
#include "Instruction.hpp"
#include "LICM.hpp"
#include "PassManager.hpp"
#include <cstddef>
#include <memory>
#include <vector>

/**
 * @brief 循环不变式外提Pass的主入口函数
 * 
 */
void LoopInvariantCodeMotion::run() {

    loop_detection_ = std::make_unique<LoopDetection>(m_);
    loop_detection_->run();
    func_info_ = std::make_unique<FuncInfo>(m_);
    func_info_->run();
    for (auto &loop : loop_detection_->get_loops()) {
        is_loop_done_[loop] = false;
    }

    for (auto &loop : loop_detection_->get_loops()) {
        traverse_loop(loop);
    }
}

/**
 * @brief 遍历循环及其子循环
 * @param loop 当前要处理的循环
 * 
 */
void LoopInvariantCodeMotion::traverse_loop(std::shared_ptr<Loop> loop) {
    if (is_loop_done_[loop]) {
        return;
    }
    is_loop_done_[loop] = true;
    for (auto &sub_loop : loop->get_sub_loops()) {
        traverse_loop(sub_loop);
    }
    run_on_loop(loop);
}

// TODO: 实现collect_loop_info函数
// 1. 遍历当前循环及其子循环的所有指令
// 2. 收集所有指令到loop_instructions中
// 3. 检查store指令是否修改了全局变量，如果是则添加到updated_global中
// 4. 检查是否包含非纯函数调用，如果有则设置contains_impure_call为true
void LoopInvariantCodeMotion::collect_loop_info(
    std::shared_ptr<Loop> loop,
    std::set<Value *> &loop_instructions,
    std::set<Value *> &updated_global,
    bool &contains_impure_call) {

    for (auto &block : loop->get_blocks()) {
        for (auto &inst : block->get_instructions()) {
            loop_instructions.insert(&inst);  // 收集指令到 loop_instructions 中
            // 检查是否是 Store 指令，若是，则检查它的左值是否是全局变量
            if (inst.is_store()) {
                auto store_inst = dynamic_cast<StoreInst*>(&inst);
                if (auto global_var = dynamic_cast<GlobalVariable*>(store_inst->get_lval())) {
                    updated_global.insert(global_var);  // 如果是全局变量，则加入到 updated_global
                }
            }
            // 检查是否是非纯函数调用
            if (inst.is_call()) {
                auto call_inst = dynamic_cast<CallInst*>(&inst);
                Function *called_func = call_inst->get_function();
                if (called_func && !func_info_->is_pure_function(called_func)) {  // 如果是非纯函数调用
                    contains_impure_call = true;  // 设置为 true
                }
            }
        }
    }
    // 递归检查子循环
    for (auto &sub_loop : loop->get_sub_loops()) {
        collect_loop_info(sub_loop, loop_instructions, updated_global, contains_impure_call);
    }
    //throw std::runtime_error("Lab4: 你有一个TODO需要完成！");
}

/**
 * @brief 对单个循环执行不变式外提优化
 * @param loop 要优化的循环
 * 
 */
void LoopInvariantCodeMotion::run_on_loop(std::shared_ptr<Loop> loop) {
    std::set<Value *> loop_instructions;
    std::set<Value *> updated_global;
    bool contains_impure_call = false;
    collect_loop_info(loop, loop_instructions, updated_global, contains_impure_call);

    std::vector<Value *> loop_invariant;


    // TODO: 识别循环不变式指令
    //
    // - 如果指令已被标记为不变式则跳过
    // - 跳过 store、ret、br、phi 等指令与非纯函数调用
    // - 特殊处理全局变量的 load 指令
    // - 检查指令的所有操作数是否都是循环不变的
    // - 如果有新的不变式被添加则注意更新 changed 标志，继续迭代

    bool changed;
    do {
        // 确定循环变式
        std::set<Value *> loop_variables;
        for (auto &ins : loop_instructions) {
            auto inst = dynamic_cast<Instruction*>(ins);
            // 跳过已经标记为不变式的指令
            if (std::find(loop_invariant.begin(), loop_invariant.end(), inst) != loop_invariant.end()) {
                continue;  // 如果指令已经在不变式指令中，跳过
            }
            // 跳过不变式的指令类型
            if (inst->is_store()) continue;
            if (inst->is_ret()) continue;
            if (inst->is_br()) continue;
            loop_variables.insert(inst);
        }

        changed = false;
        for (auto &ins : loop_instructions) {
            auto inst = dynamic_cast<Instruction*>(ins);
            // 跳过已经标记为不变式的指令
            if (std::find(loop_invariant.begin(), loop_invariant.end(), inst) != loop_invariant.end()) {
                continue;
            }
            // 跳过不变式的指令类型
            if (inst->is_store()) continue;
            if (inst->is_ret()) continue;
            if (inst->is_br()) continue;
            if (inst->is_phi()) continue;
            // 跳过非纯函数调用
            if (inst->is_call()) {
                auto call_inst = dynamic_cast<CallInst*>(inst);
                Function *called_func = call_inst->get_function();
                if (called_func && !func_info_->is_pure_function(called_func)) {
                    continue;
                }
            }
            
            // 特殊处理全局变量的 load 指令
            if (auto load_inst = dynamic_cast<LoadInst*>(inst)) {
                if (auto global_var = dynamic_cast<GlobalVariable*>(load_inst->get_lval())) {
                    loop_invariant.push_back(inst);
                    changed = true;
                    continue;
                }
            }

            // 检查操作数是否是 loop_varible
            bool is_invariant = true;
            for (auto *operand : inst->get_operands()) {
                if (auto *constant_operand = dynamic_cast<Constant*>(operand)) {
                    // 常量永远是循环不变的
                    continue;
                }
                // 如果操作数是全局变量，检查它是否修改了
                if (auto *global_var = dynamic_cast<GlobalVariable*>(operand)) {
                    // 这里需要检查全局变量是否在循环内被修改
                    if (updated_global.count(global_var) > 0) {
                        // 如果全局变量在循环内被修改过，它不是循环不变的
                        is_invariant = false;
                        break;
                    }
                    continue;
                }
                if (loop_variables.find(operand) != loop_variables.end()) {
                    is_invariant = false;
                    break; // 退出操作数检查
                }
            }

            // 有新的不变式被添加则更新 changed 标志，继续迭代
            if (is_invariant) {
                loop_invariant.push_back(inst);
                changed = true;
            }
        }
        //throw std::runtime_error("Lab4: 你有一个TODO需要完成！");
    } while (changed);

    if (loop->get_preheader() == nullptr) {
        loop->set_preheader(
            BasicBlock::create(m_, "", loop->get_header()->get_parent()));
    }

    if (loop_invariant.empty())
        return;

    // insert preheader
    auto preheader = loop->get_preheader();
    
    // TODO: 更新 phi 指令
    for (auto &phi_inst_ : loop->get_header()->get_instructions()) {
        if (phi_inst_.get_instr_type() != Instruction::phi)
            continue;

        // 遍历 phi 指令的所有前驱块和对应的操作数
        for (size_t i = 0; i < phi_inst_.get_num_operand(); i += 2) {
            auto incoming_block = phi_inst_.get_operand(i + 1);   // 对应的前驱块
            if (std::find(loop->get_blocks().begin(), loop->get_blocks().end(), incoming_block) == loop->get_blocks().end()) {
                // 更新为 preheader 中的值
                phi_inst_.set_operand(i + 1, loop->get_preheader());
            }
        }
        //throw std::runtime_error("Lab4: 你有一个TODO需要完成！");
    }
    
    // TODO: 用跳转指令重构控制流图 
    // 将所有非 latch 的 header 前驱块的跳转指向 preheader
    // 并将 preheader 的跳转指向 header
    // 注意这里需要更新前驱块的后继和后继的前驱

    // 找到循环的 latch 块
    std::vector<BasicBlock *> pred_to_remove;
    for (auto &pred : loop->get_header()->get_pre_basic_blocks()) {
        // 跳过 latch 块
        if (*pred->get_succ_basic_blocks().begin() == loop->get_header() &&
        std::find(loop->get_blocks().begin(), loop->get_blocks().end(), pred) != loop->get_blocks().end()) {
            continue;
        }
        // 找到并修改前驱块的跳转指令
        for (auto &inst : pred->get_instructions()) {
            if (auto *br_inst = dynamic_cast<BranchInst*>(&inst)) {
                // 假设跳转指令的目标是操作数，且目标基本块是第一个操作数
                if (br_inst->get_num_operand() > 0) {
                    // 获取第一个操作数（跳转的目标基本块）
                    BasicBlock *target_block = dynamic_cast<BasicBlock*>(br_inst->get_operand(0));

                    // 如果该跳转指令指向 loop header，修改跳转目标为 preheader
                    if (target_block == loop->get_header()) {
                        br_inst->set_operand(0, preheader); // 修改跳转目标为 preheader
                    }
                }
            }
        }
        pred->remove_succ_basic_block(loop->get_header());  // 删除跳转到 header
        pred->add_succ_basic_block(preheader);  // 将 preheader 作为后继块
        preheader->add_pre_basic_block(pred);   // 将 pred 作为 preheader 的前驱块
        pred_to_remove.push_back(pred);
        //throw std::runtime_error("Lab4: 你有一个TODO需要完成！");
    }

    for (auto &pred : pred_to_remove) {
        loop->get_header()->remove_pre_basic_block(pred);
    }

    // TODO: 外提循环不变指令
    for (auto &inst : loop_invariant) {
        auto *instr = dynamic_cast<Instruction*>(inst);
        // 遍历循环中的所有基本块，查找并删除该指令
        for (auto &block : loop->get_blocks()) {
            for (auto &block_inst : block->get_instructions()) {
                if (&block_inst == instr) {
                    // 找到该指令并从基本块中移除
                    block->remove_instr(&block_inst);
                    break;  // 指令删除后跳出循环
                }
            }
        }

        // 将该指令添加到 preheader 中
        preheader->add_instruction(instr);
    }
    //throw std::runtime_error("Lab4: 你有一个TODO需要完成！");

    // insert preheader br to header
    BranchInst::create_br(loop->get_header(), preheader);

    // insert preheader to parent loop
    if (loop->get_parent() != nullptr) {
        loop->get_parent()->add_block(preheader);
    }
}

