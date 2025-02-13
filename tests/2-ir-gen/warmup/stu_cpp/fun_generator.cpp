#include "BasicBlock.hpp"
#include "Constant.hpp"
#include "Function.hpp"
#include "IRBuilder.hpp"
#include "Module.hpp"
#include "Type.hpp"

#include <iostream>
#include <memory>

#define CONST_INT(num) ConstantInt::get(num, module)

int main() {
    auto module = new Module();
    auto *Int32Type = module->get_int32_type();

    auto calleeFun = Function::create(FunctionType::get(Int32Type, {Int32Type}), "callee", module);

    auto calleeBB = BasicBlock::create(module, "entry", calleeFun);
    auto builder = new IRBuilder(calleeBB, module);

    auto aAlloca = builder->create_alloca(Int32Type);
    std::vector<Value *> args;
    for (auto &arg : calleeFun->get_args()) {
        args.push_back(&arg);
    }
    builder->create_store(args[0], aAlloca);
    auto aLoad = builder->create_load(aAlloca);

    auto mulResult = builder->create_imul(aLoad, CONST_INT(2));

    builder->create_ret(mulResult);

    auto mainFun = Function::create(FunctionType::get(Int32Type, {}), "main", module);

    auto mainBB = BasicBlock::create(module, "entry", mainFun);
    builder->set_insert_point(mainBB);

    auto callCallee = builder->create_call(calleeFun, {CONST_INT(110)});
    builder->create_ret(callCallee);

    std::cout << module->print();
    delete module;
    return 0;
}