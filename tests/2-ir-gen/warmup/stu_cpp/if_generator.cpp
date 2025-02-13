#include "BasicBlock.hpp"
#include "Constant.hpp"
#include "Function.hpp"
#include "IRBuilder.hpp"
#include "Module.hpp"
#include "Type.hpp"

#include <iostream>
#include <memory>

#define CONST_INT(num) ConstantInt::get(num, module)
#define CONST_FP(num) ConstantFP::get(num, module)

int main() {
    auto module = new Module();
    auto *Int32Type = module->get_int32_type();
    auto *FloatType = module->get_float_type();

    auto mainFun = Function::create(FunctionType::get(Int32Type, {}), "main", module);
    auto bb = BasicBlock::create(module, "entry", mainFun);
    auto builder = new IRBuilder(bb, module);

    auto aAlloca = builder->create_alloca(FloatType);
    builder->create_store(CONST_FP(5.555), aAlloca);

    auto aLoad = builder->create_load(aAlloca);
    auto oneFP = CONST_FP(1.0);
    auto cmp = builder->create_fcmp_gt(aLoad, oneFP);

    auto trueBB = BasicBlock::create(module, "trueBB", mainFun);
    auto falseBB = BasicBlock::create(module, "falseBB", mainFun);

    builder->create_cond_br(cmp, trueBB, falseBB);

    // 在 trueBB 中：返回 233
    builder->set_insert_point(trueBB);
    builder->create_ret(CONST_INT(233));

    // 在 falseBB 中：返回 0
    builder->set_insert_point(falseBB);
    builder->create_ret(CONST_INT(0));

    std::cout << module->print();
    delete module;
    return 0;
}
