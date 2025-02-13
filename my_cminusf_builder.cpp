#include "cminusf_builder.hpp"

#define CONST_FP(num) ConstantFP::get((float)num, module.get())
#define CONST_INT(num) ConstantInt::get(num, module.get())
#define CONST_ZERO(type) ConstantZero::get(type, module.get())


// types
Type *VOID_T;
Type *INT1_T;
Type *INT32_T;
Type *INT32PTR_T;
Type *FLOAT_T;
Type *FLOATPTR_T;

/*
 * use CMinusfBuilder::Scope to construct scopes
 * scope.enter: enter a new scope
 * scope.exit: exit current scope
 * scope.push: add a new binding to current scope
 * scope.find: find and return the value bound to the name
 */

Value* CminusfBuilder::visit(ASTProgram &node) {
    VOID_T = module->get_void_type();
    INT1_T = module->get_int1_type();
    INT32_T = module->get_int32_type();
    INT32PTR_T = module->get_int32_ptr_type();
    FLOAT_T = module->get_float_type();
    FLOATPTR_T = module->get_float_ptr_type();

    Value *ret_val = nullptr;
    for (auto &decl : node.declarations) {
        ret_val = decl->accept(*this);
    }
    return ret_val;
}

Value* CminusfBuilder::visit(ASTNum &node) {
    // TODO: This function is empty now.
    // Add some code here.
    //根据类型，调用相应函数直接得到值
    Value *ret_val = nullptr;
    if(node.type == TYPE_INT)
        ret_val = ConstantInt::get(node.i_val, module.get());
    else if (node.type == TYPE_FLOAT)
        ret_val = ConstantFP::get(node.f_val, module.get());
    else ret_val = 0;
    return ret_val;
}

Value* CminusfBuilder::visit(ASTVarDeclaration &node) {
    // TODO: This function is empty now.
    // Add some code here.
    Type *var_type;
    if(node.type == TYPE_INT) 
        var_type = INT32_T;
    else if (node.type == TYPE_FLOAT)
        var_type = FLOAT_T;
    else var_type = VOID_T;
    auto initializer = CONST_ZERO(var_type);
    //处理全局变量
    if(scope.in_global()) {
        //判断是否为数组
        if(node.num == nullptr) {
            auto global_var = GlobalVariable::create(node.id, module.get(), var_type, false, initializer);
            scope.push(node.id, global_var);
        }
        else {
            auto *arrayType = ArrayType::get(var_type, node.num->i_val);
            auto global_var_array = GlobalVariable::create(node.id, module.get(), arrayType, false, initializer);
            scope.push(node.id, global_var_array);
        }
    }
    //处理 local 变量
    else {
        if(node.num == nullptr) {
            auto alloca_var = builder->create_alloca(var_type);
            scope.push(node.id, alloca_var);
        }
        else {
            auto *arrayType = ArrayType::get(var_type, node.num->i_val);
            auto alloca_var_array = builder->create_alloca(arrayType);
            scope.push(node.id, alloca_var_array);
        }
    } 
    return nullptr;
}

Value* CminusfBuilder::visit(ASTFunDeclaration &node) {
    FunctionType *fun_type;
    Type *ret_type;
    std::vector<Type *> param_types;
    if (node.type == TYPE_INT)
        ret_type = INT32_T;
    else if (node.type == TYPE_FLOAT)
        ret_type = FLOAT_T;
    else
        ret_type = VOID_T;

    for (auto &param : node.params) {
        // TODO: Please accomplish param_types.
        if (param->isarray) {
            if(param->type==TYPE_INT)
                param_types.push_back(INT32PTR_T);
            else if(param->type==TYPE_FLOAT)
                param_types.push_back(FLOATPTR_T);
        }
        else {
            if(param->type==TYPE_INT)
                param_types.push_back(INT32_T);
            else if(param->type==TYPE_FLOAT)
                param_types.push_back(FLOAT_T);
        }
    }

    fun_type = FunctionType::get(ret_type, param_types);
    auto func = Function::create(fun_type, node.id, module.get());
    scope.push(node.id, func);
    context.func = func;
    auto funBB = BasicBlock::create(module.get(), "", func);
    builder->set_insert_point(funBB);
    scope.enter();
    std::vector<Value *> args;
    for (auto &arg : func->get_args()) {
        args.push_back(&arg);
    }
    Value* param_alloca;
    Value* param_value;
    for (unsigned int i = 0; i < node.params.size(); ++i) {
        // TODO: You need to deal with params and store them in the scope.
        auto param = node.params[i];
        //参数是否为数组
        if (param->isarray) {
            if(param->type == TYPE_INT)
                 param_alloca = builder->create_alloca(INT32PTR_T);
            else if(param->type == TYPE_FLOAT)
                 param_alloca = builder->create_alloca(FLOATPTR_T);
            builder->create_store(args[i], param_alloca);
            param_value = builder->create_load(param_alloca);

    std::cerr << "aaaaa" << std::endl;

            //WHY????
            scope.push(param->id, param_value);
        }
        else {
            if(param->type == TYPE_INT)
                 param_alloca = builder->create_alloca(INT32_T);
            else if(param->type == TYPE_FLOAT)
                 param_alloca = builder->create_alloca(FLOAT_T);
            builder->create_store(args[i], param_alloca);
            //
            param_value = builder->create_load(param_alloca);
            scope.push(param->id, param_alloca);
            //scope.push(param->id, param_alloca);
        }
    }
    node.compound_stmt->accept(*this);
    if (not builder->get_insert_block()->is_terminated()) 
    {
        if (context.func->get_return_type()->is_void_type())
            builder->create_void_ret();
        else if (context.func->get_return_type()->is_float_type())
            builder->create_ret(CONST_FP(0.));
        else
            builder->create_ret(CONST_INT(0));
    }
    scope.exit();
    return nullptr;
}

Value* CminusfBuilder::visit(ASTParam &node) {
    // TODO: This function is empty now.
    // Add some code here.
    return nullptr;
}

Value* CminusfBuilder::visit(ASTCompoundStmt &node) {
    // TODO: This function is not complete.
    // You may need to add some code here
    // to deal with complex statements. 

    scope.enter();  //进入新的作用域
    
    for (auto &decl : node.local_declarations) {
        decl->accept(*this);
    }

    for (auto &stmt : node.statement_list) {
        stmt->accept(*this);
        if (builder->get_insert_block()->is_terminated())
            break;
    }

    scope.exit();   //退出作用域

    return nullptr;
}

Value* CminusfBuilder::visit(ASTExpressionStmt &node) {
    // TODO: This function is empty now.
    // Add some code here.
    if(node.expression != nullptr)
        node.expression->accept(*this);
    return nullptr;
}

Value* CminusfBuilder::visit(ASTSelectionStmt &node) {
    // TODO: This function is empty now.
    // Add some code here.
    // 获取当前所在的函数
    auto func = builder->get_insert_block()->get_parent();

    // 处理条件表达式并获得其值
    auto expression = node.expression->accept(*this);
    auto exp_type = expression->get_type();

    // 根据条件表达式的类型，生成适当的比较指令
    Value* cmp;
    if (exp_type->is_int32_type()) {
        cmp = builder->create_icmp_gt(expression, CONST_ZERO(INT32_T));  // int 类型比较
    }
    else if (exp_type->is_int1_type()) {
        cmp = expression;
    }
    else {
        cmp = builder->create_fcmp_gt(expression, CONST_ZERO(FLOAT_T));  // float 类型比较
    }

    // 创建基本块：true 分支和 false 分支
    auto trueBB = BasicBlock::create(module.get(), "", func);   //  千万不能自己命名！！！
    BasicBlock* mergeBB = nullptr; // 合并块（结束后，if 和 else 结束后都跳转到这里）

    if (node.else_statement != nullptr) {
        // 如果存在 else 分支
        auto falseBB = BasicBlock::create(module.get(), "", func);
        mergeBB = BasicBlock::create(module.get(), "", func);
        // 创建条件分支
        builder->create_cond_br(cmp, trueBB, falseBB);
        //true
        builder->set_insert_point(trueBB);
        node.if_statement->accept(*this);
        if (!builder->get_insert_block()->is_terminated()) {
            builder->create_br(mergeBB);  // 如果没有终止指令，跳转到 mergeBB
        }

        //false
        builder->set_insert_point(falseBB);
        node.else_statement->accept(*this);
        if (!builder->get_insert_block()->is_terminated()) {
            builder->create_br(mergeBB);  // 如果没有终止指令，跳转到 mergeBB
        }

        // 合并基本块
        builder->set_insert_point(mergeBB);
    } else {
        // 如果没有 else 分支，只处理 true 分支
        mergeBB = BasicBlock::create(module.get(), "", func);
        builder->create_cond_br(cmp, trueBB, mergeBB);

        // 只有 true
        builder->set_insert_point(trueBB);
        node.if_statement->accept(*this);
        if (!builder->get_insert_block()->is_terminated()) {
            builder->create_br(mergeBB);  // 如果没有终止指令，跳转到 mergeBB
        }

        // 合并基本块
        builder->set_insert_point(mergeBB);
    }

    return nullptr;
}

Value* CminusfBuilder::visit(ASTIterationStmt &node) {
    // TODO: This function is empty now.
    // Add some code here.
    auto func = builder->get_insert_block()->get_parent();
    auto conditionBB = BasicBlock::create(module.get(), "", func);
    auto loopBB = BasicBlock::create(module.get(), "", func);
    auto endBB = BasicBlock::create(module.get(), "", func);

    //  条件判断
    builder->create_br(conditionBB);
    builder->set_insert_point(conditionBB);
    auto expression = node.expression->accept(*this);   //  处理表达式
    auto exp_type = expression->get_type();
    // 生成比较指令
    Value* cmp;
    if (exp_type->is_int32_type()) {
        cmp = builder->create_icmp_gt(expression, CONST_ZERO(INT32_T));  // int32 类型比较
    }
    else if (exp_type->is_int1_type()) {                                //  别忘了 int1
        cmp = expression;
    }
    else {
        cmp = builder->create_fcmp_gt(expression, CONST_ZERO(FLOAT_T));  // float 类型比较
    }
    builder->create_cond_br(cmp, loopBB, endBB); // 根据条件跳转

    // 循环体内执行的BB
    builder->set_insert_point(loopBB);
    node.statement->accept(*this);
    if (!builder->get_insert_block()->is_terminated()) {
        builder->create_br(conditionBB);  // 回到条件判断
    }

    builder->set_insert_point(endBB); // 设置插入点到循环外部，结束
    return nullptr;
}

Value* CminusfBuilder::visit(ASTReturnStmt &node) {
    if (node.expression == nullptr) {
        builder->create_void_ret();
        return nullptr;
    } else {
        // TODO: The given code is incomplete.
        // You need to solve other return cases (e.g. return an integer).
        auto expression = node.expression->accept(*this);   //  处理表达式
        auto exp_type = expression->get_type();
        auto fun = builder->get_insert_block()->get_parent();   //  处理函数返回值
        auto ret_type = fun->get_return_type();

        //  如果函数返回值和表达式类型不同，需要转换
        if (ret_type->is_integer_type()) {
            if (!exp_type->is_integer_type()) {
                expression = builder->create_fptosi(expression, INT32_T);
            }
            builder->create_ret(expression);
        }
        else if (ret_type->is_float_type()) {
            if (!expression->get_type()->is_float_type()) {
                expression = builder->create_sitofp(expression, FLOAT_T);
            }
            builder->create_ret(expression);
        }
        else if (ret_type->is_void_type()) {
            builder->create_void_ret();
        }
    }
    return nullptr;
}

Value* var_location;
//感觉可以优化
Value* CminusfBuilder::visit(ASTVar &node) {
    // TODO: This function is empty now.
    // Add some code here.
    Value* ret_val;
    if(node.expression == nullptr) {
        /*
        var_location = scope.find(node.id);;
        if(!var_location) {
            // 错误处理：变量未定义
            std::cerr << "Undefined variable: " << node.id << std::endl;
            std::abort();
        }
        ret_val = builder->create_load(var_location); // 加载变量的值
        */
        


        var_location = scope.find(node.id);
        if(!var_location) {
            // 错误处理：变量未定义
            std::cerr << "Undefined variable: " << node.id << std::endl;
            std::abort();
        }
        // 如果变量是指针类型，需要进行 GEP 指令来获取实际地址
if(var_location->get_type()->is_pointer_type())
    std::cerr << "Undefined exception handler: neg_idx_except" << std::endl;
        if(var_location->get_type()->is_pointer_type() && var_location->get_type()->get_pointer_element_type()->is_array_type()) {
            //对于数组需要用一次 gep 得到地址
            var_location = builder->create_gep(var_location, {CONST_INT(0), CONST_INT(0)});
            ret_val = var_location; // 加载变量的值
        }
        else ret_val = builder->create_load(var_location); // 加载变量的值
        
    }
    else {
        // 处理数组
        Value* index = node.expression->accept(*this);
        auto function = builder->get_insert_block()->get_parent();
        
        // 类型转换：如果索引是浮点类型，转换为整数
        if(index->get_type()->is_float_type()) {
            index = builder->create_fptosi(index, INT32_T);
        }

//非常重要！数组索引可能是负数
        auto exceptBB = BasicBlock::create(module.get(), "", function); //千万不能自己定义标签，不如会出现标签重复
        auto correctBB = BasicBlock::create(module.get(), "", function);
        // 检查索引是否小于零
        Value* mark_check = builder->create_icmp_lt(index, CONST_ZERO(INT32_T));
        builder->create_cond_br(mark_check, exceptBB, correctBB);
        // 处理异常情况：索引为负
        builder->set_insert_point(exceptBB);
        auto exceptFunction = scope.find("neg_idx_except");
        if(!exceptFunction) {
            std::cerr << "Undefined exception handler: neg_idx_except" << std::endl;
            std::abort();
        }
        builder->create_call(exceptFunction, {});
        // 处理正常情况：索引有效
        builder->create_br(correctBB);
        builder->set_insert_point(correctBB);


        auto var_array = scope.find(node.id);
        if(!var_array) {
            std::cerr << "Undefined array variable: " << node.id << std::endl;
            std::abort();
        }

        Type* elemType = var_array->get_type()->get_pointer_element_type();
        if(elemType->is_array_type()) {
            // 对于指向数组的指针，使用两个索引：{0, mark}
            var_location = builder->create_gep(var_array, {CONST_INT(0), index});
        }
        else {
            // 对于指向非数组的指针，使用一个索引：{mark}
            var_location = builder->create_gep(var_array, {index});
        }

        ret_val = builder->create_load(var_location); // 加载数组元素的值
    }
    return ret_val;
}

Value* CminusfBuilder::visit(ASTAssignExpression &node) {
    // TODO: This function is empty now.
    // Add some code here.
    Value* var;
    Value* expression;
    //主要需要 var_location
    expression = node.expression->accept(*this);
//really important!!!! 先访问 expression 再 var，保证 var_location 不被覆盖
    var = node.var->accept(*this);

    //Value* location = scope.find(node.var->id);

    auto var_type = var->get_type();
    auto exp_type = expression->get_type();
    /*
    if(var->get_type()->is_integer_type() && expression->get_type()->is_float_type())
        expression = builder->create_fptosi(expression, INT32_T);
    else if(var->get_type()->is_float_type() && expression->get_type()->is_integer_type())
        expression = builder->create_sitofp(expression, FLOAT_T);
    */
    if (var_type != exp_type) {
        if (var_type->is_int32_type()) {
            if (exp_type->is_float_type())
                expression = builder->create_fptosi(expression, INT32_T);
            else if (exp_type->is_int1_type())
                expression = builder->create_zext(expression, INT32_T);
        }
        else if (var_type->is_float_type()) {
            expression = builder->create_sitofp(expression, FLOAT_T);
        }
        else if (var_type->is_int1_type()) {
            if (exp_type->is_float_type())
                expression = builder->create_fptosi(expression, INT1_T);
            else if (exp_type->is_int32_type())
                expression = builder->create_icmp_ne(expression, CONST_ZERO(INT32_T));
        }
    }
    builder->create_store(expression, var_location);
    return expression;
}

Value* CminusfBuilder::visit(ASTSimpleExpression &node) {
    // TODO: This function is empty now.
    // Add some code here.
    Value* ret_val;
    if(node.additive_expression_r == nullptr) {
        ret_val = node.additive_expression_l->accept(*this);
    }
    else {
        Value* left_val;
        Value* right_val;
        left_val = node.additive_expression_l->accept(*this);
        right_val = node.additive_expression_r->accept(*this);

        if((left_val->get_type()->is_integer_type()) && (right_val->get_type()->is_integer_type())){
            if (left_val->get_type()->is_int1_type())
                left_val = builder->create_zext(left_val, INT32_T);
            if (right_val->get_type()->is_int1_type())
                right_val = builder->create_zext(right_val, INT32_T);
            switch (node.op) {
                case OP_LE:
                    ret_val = builder->create_icmp_le(left_val, right_val);
                    break;
                case OP_LT:
                    ret_val = builder->create_icmp_lt(left_val, right_val);
                    break;
                case OP_GT:
                    ret_val = builder->create_icmp_gt(left_val, right_val);
                    break;
                case OP_GE:
                    ret_val = builder->create_icmp_ge(left_val, right_val);
                    break;
                case OP_EQ:
                    ret_val = builder->create_icmp_eq(left_val, right_val);
                    break;
                case OP_NEQ:
                    ret_val = builder->create_icmp_ne(left_val, right_val);
                    break;
                default: ret_val = nullptr;
            }
        }
        else {
            if(left_val->get_type()->is_integer_type())
                left_val = builder->create_sitofp(left_val, FLOAT_T);     //转浮点数
            if(right_val->get_type()->is_integer_type())
                right_val = builder->create_sitofp(right_val, FLOAT_T);
            switch (node.op) {
                case OP_LE:
                    ret_val = builder->create_fcmp_le(left_val, right_val);
                    break;
                case OP_LT:
                    ret_val = builder->create_fcmp_lt(left_val, right_val);
                    break;
                case OP_GT:
                    ret_val = builder->create_fcmp_gt(left_val, right_val);
                    break;
                case OP_GE:
                    ret_val = builder->create_fcmp_ge(left_val, right_val);
                    break;
                case OP_EQ:
                    ret_val = builder->create_fcmp_eq(left_val, right_val);
                    break;
                case OP_NEQ:
                    ret_val = builder->create_fcmp_ne(left_val, right_val);
                    break;
                default: ret_val = nullptr;
            }
        }



        //强制类型转换为i32 ?需要吗
        //ret_val = builder->create_zext(ret_val, INT32_T);
    }
    return ret_val;
}

Value* CminusfBuilder::visit(ASTAdditiveExpression &node) {
    // TODO: This function is empty now.
    // Add some code here.
    Value* ret_val;
    if (node.additive_expression == nullptr)
        ret_val = node.term->accept(*this);
    else {
        Value* add_expression;
        Value* term;
        add_expression = node.additive_expression->accept(*this);
        term = node.term->accept(*this);;
        if (add_expression->get_type()->is_integer_type() && term->get_type()->is_integer_type()) {
            switch (node.op) {
                case OP_PLUS:
                    ret_val = builder->create_iadd(add_expression, term);
                    break;
                case OP_MINUS:
                    ret_val = builder->create_isub(add_expression, term);
                    break;
                default: ret_val = nullptr;
            }
        }
        else {
            if (add_expression->get_type()->is_integer_type())
                add_expression = builder->create_sitofp(add_expression, FLOAT_T);
            if (term->get_type()->is_integer_type())
                term = builder->create_sitofp(term, FLOAT_T);
            switch (node.op) {
                case OP_PLUS:
                    ret_val = builder->create_fadd(add_expression, term);
                    break;
                case OP_MINUS:
                    ret_val = builder->create_fsub(add_expression, term);
                    break;
                default: ret_val = nullptr;
            }
        }
    }
    return ret_val;
}

Value* CminusfBuilder::visit(ASTTerm &node) {
    // TODO: This function is empty now.
    // Add some code here.
    Value* ret_val;
    if (node.term == nullptr)
        ret_val = node.factor->accept(*this);
    else {
        Value* term;
        Value* factor;
        term = node.term->accept(*this);
        factor = node.factor->accept(*this);;
        if (term->get_type()->is_integer_type() && factor->get_type()->is_integer_type()) {
            switch (node.op) {
                case OP_MUL:
                    ret_val = builder->create_imul(term, factor);
                    break;
                case OP_DIV:
                    ret_val = builder->create_isdiv(term, factor);
                    break;
                default: ret_val = nullptr;
            }
        }
        else {
            if (term->get_type()->is_integer_type())
                term = builder->create_sitofp(term, FLOAT_T);
            if (factor->get_type()->is_integer_type())
                factor = builder->create_sitofp(factor, FLOAT_T);
            switch (node.op) {
                case OP_MUL:
                    ret_val = builder->create_fmul(term, factor);
                    break;
                case OP_DIV:
                    ret_val = builder->create_fdiv(term, factor);
                    break;
                default: ret_val = nullptr;
            }
        }
    }
            //std::cerr << ret_val->print() << std::endl;
    return ret_val;
}

Value* CminusfBuilder::visit(ASTCall &node) {
    // TODO: This function is empty now.
    // Add some code here.
    auto function = scope.find(node.id);
    auto fun_type=static_cast<FunctionType*>(function->get_type());
    std::vector<Value*> args;
    int paramIndex = 0;

    // 遍历实参并处理类型
    for (auto &arg : node.args) {
        Value* arg_val;
        arg_val = arg->accept(*this);

        auto param_type = fun_type->get_param_type(paramIndex);
        auto arg_val_type = arg_val->get_type();

        // 如果形参是指针类型，传递地址
        if (param_type->is_pointer_type()) {
if(arg_val->get_type()->is_integer_type())
    arg_val = builder->create_icmp_ne(arg_val, CONST_ZERO(INT32_T));
            args.push_back(var_location);
        } else {
            // 实参类型与形参类型不匹配时进行转换
            if (param_type != arg_val_type) {
                if (param_type->is_int32_type()) {
                    if (arg_val_type->is_float_type())
                        arg_val = builder->create_fptosi(arg_val, INT32_T);
                    else if (arg_val_type->is_int1_type())
                        arg_val = builder->create_zext(arg_val, INT32_T);
                }
                else if (param_type->is_float_type()) {
                    arg_val = builder->create_sitofp(arg_val, FLOAT_T);
                }
                else if (param_type->is_int1_type()) {
                    if (arg_val_type->is_float_type())
                        arg_val = builder->create_fptosi(arg_val, INT1_T);
                    else if (arg_val_type->is_int32_type())
                        arg_val = builder->create_icmp_ne(arg_val, CONST_ZERO(INT32_T));
                }
            }
            // 传递转换后的值
            
            args.push_back(arg_val);
        }
        paramIndex++;
    }
    auto ret_val = builder->create_call(function, args);
    return ret_val;
}
