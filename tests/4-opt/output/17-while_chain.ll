; ModuleID = 'cminus'
source_filename = "/home/ymf/Desktop/Compiler/2024ustc-jianmu-compiler/tests/testcases_general/17-while_chain.cminus"

declare i32 @input()

declare void @output(i32)

declare void @outputFloat(float)

declare void @neg_idx_except()

define i32 @main() {
label_entry:
  br label %label0
label0:                                                ; preds = %label_entry, %label13
  %op1 = phi i32 [ %op9, %label13 ], [ undef, %label_entry ]
  %op2 = phi i32 [ 10, %label_entry ], [ %op5, %label13 ]
  %op3 = icmp ne i32 %op2, 0
  br i1 %op3, label %label4, label %label6
label4:                                                ; preds = %label0
  %op5 = sub i32 %op2, 1
  br label %label8
label6:                                                ; preds = %label0
  %op7 = add i32 %op2, %op1
  ret i32 %op7
label8:                                                ; preds = %label4, %label11
  %op9 = phi i32 [ %op5, %label4 ], [ %op12, %label11 ]
  %op10 = icmp ne i32 %op9, 0
  br i1 %op10, label %label11, label %label13
label11:                                                ; preds = %label8
  %op12 = sub i32 %op9, 1
  br label %label8
label13:                                                ; preds = %label8
  br label %label0
}
