#include "BasicBlock.hpp"
#include "Constant.hpp"
#include "Function.hpp"
#include "IRBuilder.hpp"
#include "Module.hpp"
#include "Type.hpp"

#include <iostream>

#define CONST_INT(num) ConstantInt::get(num, module)

int main() {
    // 创建 Module 实例
    auto module = new Module();

    // 获取 i32 类型
    auto *Int32Type = module->get_int32_type();

    // 创建 main 函数
    auto mainFun = Function::create(FunctionType::get(Int32Type, {}), "main", module);

    // 创建基本块
    auto entryBB = BasicBlock::create(module, "entry", mainFun);
    auto loopBB = BasicBlock::create(module, "loop", mainFun);
    auto continueLoopBB = BasicBlock::create(module, "continueLoopBB", mainFun);
    auto afterLoopBB = BasicBlock::create(module, "afterLoop", mainFun);

    // 实例化 IRBuilder，并设置插入点为 entryBB
    auto builder = new IRBuilder(entryBB, module);

    // 为变量 a 和 i 分配栈空间
    auto aAlloca = builder->create_alloca(Int32Type);
    auto iAlloca = builder->create_alloca(Int32Type);

    // 初始化 a = 10 和 i = 0
    builder->create_store(CONST_INT(10), aAlloca);
    builder->create_store(CONST_INT(0), iAlloca);

    // 创建跳转到循环基本块
    builder->create_br(loopBB);

    // 设置插入点为 loopBB
    builder->set_insert_point(loopBB);

    // 加载 i 的值
    auto iLoad = builder->create_load(iAlloca);
    
    // 创建比较 i < 10
    auto cond = builder->create_icmp_lt(iLoad, CONST_INT(10));

    // 创建条件跳转，根据比较结果决定是否跳出循环
    builder->create_cond_br(cond, continueLoopBB, afterLoopBB);

    // 在循环体中更新 i 和 a 的值
    // 在跳转前更新插入点到 loopBB
    builder->set_insert_point(continueLoopBB);

    // 更新 i 的值
    auto aLoad = builder->create_load(aAlloca); // 加载 a 的值
    auto iNext = builder->create_iadd(iLoad, CONST_INT(1)); // i = i + 1
    builder->create_store(iNext, iAlloca); // 存储新的 i 值

    // 更新 a 的值 a = a + i
    auto aNext = builder->create_iadd(aLoad, iNext);
    builder->create_store(aNext, aAlloca); // 存储新的 a 值

    // 在循环的末尾，跳回 loopBB
    builder->create_br(loopBB); // 继续循环

    // 设置 afterLoopBB 中的指令
    builder->set_insert_point(afterLoopBB);

    // 返回 a 的最终值
    auto finalA = builder->create_load(aAlloca);
    builder->create_ret(finalA);

    // 输出生成的 IR
    std::cout << module->print();

    // 释放资源
    delete module;

    return 0;
}
