; ModuleID = 'cminus'
source_filename = "/home/ymf/Desktop/Compiler/2024ustc-jianmu-compiler/tests/4-opt/testcases/functional-cases/13-complex.cminus"

@n = global i32 zeroinitializer
@m = global i32 zeroinitializer
@w = global [5 x i32] zeroinitializer
@v = global [5 x i32] zeroinitializer
@dp = global [66 x i32] zeroinitializer
declare i32 @input()

declare void @output(i32)

declare void @outputFloat(float)

declare void @neg_idx_except()

define i32 @max(i32 %arg0, i32 %arg1) {
label_entry:
  %op2 = icmp sgt i32 %arg0, %arg1
  %op3 = zext i1 %op2 to i32
  %op4 = icmp ne i32 %op3, 0
  br i1 %op4, label %label5, label %label6
label5:                                                ; preds = %label_entry
  ret i32 %arg0
label6:                                                ; preds = %label_entry
  ret i32 %arg1
}
define i32 @knapsack(i32 %arg0, i32 %arg1) {
label_entry:
  %op2 = icmp sle i32 %arg1, 0
  %op3 = zext i1 %op2 to i32
  %op4 = icmp ne i32 %op3, 0
  br i1 %op4, label %label5, label %label6
label5:                                                ; preds = %label_entry
  ret i32 0
label6:                                                ; preds = %label_entry
  %op7 = icmp eq i32 %arg0, 0
  %op8 = zext i1 %op7 to i32
  %op9 = icmp ne i32 %op8, 0
  br i1 %op9, label %label10, label %label11
label10:                                                ; preds = %label6
  ret i32 0
label11:                                                ; preds = %label6
  %op12 = mul i32 %arg0, 11
  %op13 = add i32 %op12, %arg1
  %op14 = icmp slt i32 %op13, 0
  br i1 %op14, label %label15, label %label16
label15:                                                ; preds = %label11
  call void @neg_idx_except()
  ret i32 0
label16:                                                ; preds = %label11
  %op17 = getelementptr [66 x i32], [66 x i32]* @dp, i32 0, i32 %op13
  %op18 = load i32, i32* %op17
  %op19 = icmp sge i32 %op18, 0
  %op20 = zext i1 %op19 to i32
  %op21 = icmp ne i32 %op20, 0
  br i1 %op21, label %label22, label %label26
label22:                                                ; preds = %label16
  %op23 = mul i32 %arg0, 11
  %op24 = add i32 %op23, %arg1
  %op25 = icmp slt i32 %op24, 0
  br i1 %op25, label %label29, label %label30
label26:                                                ; preds = %label16
  %op27 = sub i32 %arg0, 1
  %op28 = icmp slt i32 %op27, 0
  br i1 %op28, label %label33, label %label34
label29:                                                ; preds = %label22
  call void @neg_idx_except()
  ret i32 0
label30:                                                ; preds = %label22
  %op31 = getelementptr [66 x i32], [66 x i32]* @dp, i32 0, i32 %op24
  %op32 = load i32, i32* %op31
  ret i32 %op32
label33:                                                ; preds = %label26
  call void @neg_idx_except()
  ret i32 0
label34:                                                ; preds = %label26
  %op35 = getelementptr [5 x i32], [5 x i32]* @w, i32 0, i32 %op27
  %op36 = load i32, i32* %op35
  %op37 = icmp slt i32 %arg1, %op36
  %op38 = zext i1 %op37 to i32
  %op39 = icmp ne i32 %op38, 0
  br i1 %op39, label %label40, label %label48
label40:                                                ; preds = %label34
  %op41 = sub i32 %arg0, 1
  %op42 = call i32 @knapsack(i32 %op41, i32 %arg1)
  br label %label43
label43:                                                ; preds = %label40, %label63
  %op44 = phi i32 [ %op42, %label40 ], [ %op67, %label63 ]
  %op45 = mul i32 %arg0, 11
  %op46 = add i32 %op45, %arg1
  %op47 = icmp slt i32 %op46, 0
  br i1 %op47, label %label68, label %label69
label48:                                                ; preds = %label34
  %op49 = sub i32 %arg0, 1
  %op50 = call i32 @knapsack(i32 %op49, i32 %arg1)
  %op51 = sub i32 %arg0, 1
  %op52 = sub i32 %arg0, 1
  %op53 = icmp slt i32 %op52, 0
  br i1 %op53, label %label54, label %label55
label54:                                                ; preds = %label48
  call void @neg_idx_except()
  ret i32 0
label55:                                                ; preds = %label48
  %op56 = getelementptr [5 x i32], [5 x i32]* @w, i32 0, i32 %op52
  %op57 = load i32, i32* %op56
  %op58 = sub i32 %arg1, %op57
  %op59 = call i32 @knapsack(i32 %op51, i32 %op58)
  %op60 = sub i32 %arg0, 1
  %op61 = icmp slt i32 %op60, 0
  br i1 %op61, label %label62, label %label63
label62:                                                ; preds = %label55
  call void @neg_idx_except()
  ret i32 0
label63:                                                ; preds = %label55
  %op64 = getelementptr [5 x i32], [5 x i32]* @v, i32 0, i32 %op60
  %op65 = load i32, i32* %op64
  %op66 = add i32 %op59, %op65
  %op67 = call i32 @max(i32 %op50, i32 %op66)
  br label %label43
label68:                                                ; preds = %label43
  call void @neg_idx_except()
  ret i32 0
label69:                                                ; preds = %label43
  %op70 = getelementptr [66 x i32], [66 x i32]* @dp, i32 0, i32 %op46
  store i32 %op44, i32* %op70
  ret i32 %op44
}
define i32 @main() {
label_entry:
  store i32 5, i32* @n
  store i32 10, i32* @m
  %op0 = icmp slt i32 0, 0
  br i1 %op0, label %label1, label %label2
label1:                                                ; preds = %label_entry
  call void @neg_idx_except()
  ret i32 0
label2:                                                ; preds = %label_entry
  %op3 = getelementptr [5 x i32], [5 x i32]* @w, i32 0, i32 0
  store i32 2, i32* %op3
  %op4 = icmp slt i32 1, 0
  br i1 %op4, label %label5, label %label6
label5:                                                ; preds = %label2
  call void @neg_idx_except()
  ret i32 0
label6:                                                ; preds = %label2
  %op7 = getelementptr [5 x i32], [5 x i32]* @w, i32 0, i32 1
  store i32 2, i32* %op7
  %op8 = icmp slt i32 2, 0
  br i1 %op8, label %label9, label %label10
label9:                                                ; preds = %label6
  call void @neg_idx_except()
  ret i32 0
label10:                                                ; preds = %label6
  %op11 = getelementptr [5 x i32], [5 x i32]* @w, i32 0, i32 2
  store i32 6, i32* %op11
  %op12 = icmp slt i32 3, 0
  br i1 %op12, label %label13, label %label14
label13:                                                ; preds = %label10
  call void @neg_idx_except()
  ret i32 0
label14:                                                ; preds = %label10
  %op15 = getelementptr [5 x i32], [5 x i32]* @w, i32 0, i32 3
  store i32 5, i32* %op15
  %op16 = icmp slt i32 4, 0
  br i1 %op16, label %label17, label %label18
label17:                                                ; preds = %label14
  call void @neg_idx_except()
  ret i32 0
label18:                                                ; preds = %label14
  %op19 = getelementptr [5 x i32], [5 x i32]* @w, i32 0, i32 4
  store i32 4, i32* %op19
  %op20 = icmp slt i32 0, 0
  br i1 %op20, label %label21, label %label22
label21:                                                ; preds = %label18
  call void @neg_idx_except()
  ret i32 0
label22:                                                ; preds = %label18
  %op23 = getelementptr [5 x i32], [5 x i32]* @v, i32 0, i32 0
  store i32 6, i32* %op23
  %op24 = icmp slt i32 1, 0
  br i1 %op24, label %label25, label %label26
label25:                                                ; preds = %label22
  call void @neg_idx_except()
  ret i32 0
label26:                                                ; preds = %label22
  %op27 = getelementptr [5 x i32], [5 x i32]* @v, i32 0, i32 1
  store i32 3, i32* %op27
  %op28 = icmp slt i32 2, 0
  br i1 %op28, label %label29, label %label30
label29:                                                ; preds = %label26
  call void @neg_idx_except()
  ret i32 0
label30:                                                ; preds = %label26
  %op31 = getelementptr [5 x i32], [5 x i32]* @v, i32 0, i32 2
  store i32 5, i32* %op31
  %op32 = icmp slt i32 3, 0
  br i1 %op32, label %label33, label %label34
label33:                                                ; preds = %label30
  call void @neg_idx_except()
  ret i32 0
label34:                                                ; preds = %label30
  %op35 = getelementptr [5 x i32], [5 x i32]* @v, i32 0, i32 3
  store i32 4, i32* %op35
  %op36 = icmp slt i32 4, 0
  br i1 %op36, label %label37, label %label38
label37:                                                ; preds = %label34
  call void @neg_idx_except()
  ret i32 0
label38:                                                ; preds = %label34
  %op39 = getelementptr [5 x i32], [5 x i32]* @v, i32 0, i32 4
  store i32 6, i32* %op39
  br label %label40
label40:                                                ; preds = %label51, %label58
  %op41 = phi i32 [ 0, %label58 ], [ %op53, %label51 ]
  %op42 = icmp slt i32 %op41, 66
  %op43 = zext i1 %op42 to i32
  %op44 = icmp ne i32 %op43, 0
  br i1 %op44, label %label45, label %label48
label45:                                                ; preds = %label40
  %op47 = icmp slt i32 %op41, 0
  br i1 %op47, label %label50, label %label51
label48:                                                ; preds = %label40
  %op49 = icmp slt i32 15, 0
  br i1 %op49, label %label54, label %label55
label50:                                                ; preds = %label45
  call void @neg_idx_except()
  ret i32 0
label51:                                                ; preds = %label45
  %op52 = getelementptr [66 x i32], [66 x i32]* @dp, i32 0, i32 %op41
  store i32 %op46, i32* %op52
  %op53 = add i32 %op41, 1
  br label %label40
label54:                                                ; preds = %label48
  call void @neg_idx_except()
  ret i32 0
label55:                                                ; preds = %label48
  %op56 = getelementptr [66 x i32], [66 x i32]* @dp, i32 0, i32 15
  %op57 = load i32, i32* %op56
  call void @output(i32 %op57)
  ret i32 0
label58:                                                ; preds = %label38
  %op46 = sub i32 0, 1
  br label %label40
}
