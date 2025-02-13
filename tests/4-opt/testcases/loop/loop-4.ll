; ModuleID = 'cminus'
source_filename = "/home/ymf/Desktop/Compiler/2024ustc-jianmu-compiler/tests/4-opt/testcases/loop/loop-4.cminus"

declare i32 @input()

declare void @output(i32)

declare void @outputFloat(float)

declare void @neg_idx_except()

define void @main() {
label_entry:
  br label %label89
label0:                                                ; preds = %label15, %label89
  %op1 = phi i32 [ %op9, %label15 ], [ undef, %label89 ]
  %op2 = phi i32 [ 0, %label89 ], [ %op16, %label15 ]
  %op3 = icmp slt i32 %op2, 1000000
  %op4 = zext i1 %op3 to i32
  %op5 = icmp ne i32 %op4, 0
  br i1 %op5, label %label6, label %label7
label6:                                                ; preds = %label0
  br label %label88
label7:                                                ; preds = %label0
  call void @output(i32 %op1)
  ret void
label8:                                                ; preds = %label25, %label88
  %op9 = phi i32 [ %op1, %label88 ], [ %op18, %label25 ]
  %op10 = phi i32 [ 0, %label88 ], [ %op26, %label25 ]
  %op11 = icmp slt i32 %op10, 2
  %op12 = zext i1 %op11 to i32
  %op13 = icmp ne i32 %op12, 0
  br i1 %op13, label %label14, label %label15
label14:                                                ; preds = %label8
  br label %label87
label15:                                                ; preds = %label8
  %op16 = add i32 %op2, 1
  br label %label0
label17:                                                ; preds = %label35, %label87
  %op18 = phi i32 [ %op9, %label87 ], [ %op28, %label35 ]
  %op19 = phi i32 [ %op10, %label87 ], [ %op29, %label35 ]
  %op20 = phi i32 [ 0, %label87 ], [ %op36, %label35 ]
  %op21 = icmp slt i32 %op20, 2
  %op22 = zext i1 %op21 to i32
  %op23 = icmp ne i32 %op22, 0
  br i1 %op23, label %label24, label %label25
label24:                                                ; preds = %label17
  br label %label86
label25:                                                ; preds = %label17
  %op26 = add i32 %op19, 1
  br label %label8
label27:                                                ; preds = %label45, %label86
  %op28 = phi i32 [ %op18, %label86 ], [ %op38, %label45 ]
  %op29 = phi i32 [ %op19, %label86 ], [ %op39, %label45 ]
  %op30 = phi i32 [ 0, %label86 ], [ %op46, %label45 ]
  %op31 = icmp slt i32 %op30, 2
  %op32 = zext i1 %op31 to i32
  %op33 = icmp ne i32 %op32, 0
  br i1 %op33, label %label34, label %label35
label34:                                                ; preds = %label27
  br label %label85
label35:                                                ; preds = %label27
  %op36 = add i32 %op20, 1
  br label %label17
label37:                                                ; preds = %label58, %label85
  %op38 = phi i32 [ %op28, %label85 ], [ %op48, %label58 ]
  %op39 = phi i32 [ %op29, %label85 ], [ %op49, %label58 ]
  %op40 = phi i32 [ 0, %label85 ], [ %op59, %label58 ]
  %op41 = icmp slt i32 %op40, 2
  %op42 = zext i1 %op41 to i32
  %op43 = icmp ne i32 %op42, 0
  br i1 %op43, label %label44, label %label45
label44:                                                ; preds = %label37
  br label %label84
label45:                                                ; preds = %label37
  %op46 = add i32 %op30, 1
  br label %label27
label47:                                                ; preds = %label62, %label84
  %op48 = phi i32 [ %op38, %label84 ], [ %op82, %label62 ]
  %op49 = phi i32 [ %op39, %label84 ], [ %op63, %label62 ]
  %op50 = phi i32 [ 0, %label84 ], [ %op83, %label62 ]
  %op51 = icmp slt i32 %op50, 2
  %op52 = zext i1 %op51 to i32
  %op53 = icmp ne i32 %op52, 0
  br i1 %op53, label %label54, label %label58
label54:                                                ; preds = %label47
  br i1 %op57, label %label60, label %label62
label58:                                                ; preds = %label47
  %op59 = add i32 %op40, 1
  br label %label37
label60:                                                ; preds = %label54
  %op61 = add i32 %op49, 1
  br label %label62
label62:                                                ; preds = %label54, %label60
  %op63 = phi i32 [ %op49, %label54 ], [ %op61, %label60 ]
  %op83 = add i32 %op50, 1
  br label %label47
label84:                                                ; preds = %label44
  br label %label47
label85:                                                ; preds = %label34
  br label %label37
label86:                                                ; preds = %label24
  br label %label27
label87:                                                ; preds = %label14
  br label %label17
label88:                                                ; preds = %label6
  br label %label8
label89:                                                ; preds = %label_entry
  %op55 = icmp sgt i32 2, 1
  %op64 = mul i32 2, 2
  %op56 = zext i1 %op55 to i32
  %op65 = mul i32 %op64, 2
  %op57 = icmp ne i32 %op56, 0
  %op66 = mul i32 %op65, 2
  %op67 = mul i32 %op66, 2
  %op68 = mul i32 %op67, 2
  %op69 = mul i32 %op68, 2
  %op70 = mul i32 %op69, 2
  %op71 = mul i32 %op70, 2
  %op72 = mul i32 %op71, 2
  %op73 = sdiv i32 %op72, 2
  %op74 = sdiv i32 %op73, 2
  %op75 = sdiv i32 %op74, 2
  %op76 = sdiv i32 %op75, 2
  %op77 = sdiv i32 %op76, 2
  %op78 = sdiv i32 %op77, 2
  %op79 = sdiv i32 %op78, 2
  %op80 = sdiv i32 %op79, 2
  %op81 = sdiv i32 %op80, 2
  %op82 = sdiv i32 %op81, 2
  br label %label0
}
