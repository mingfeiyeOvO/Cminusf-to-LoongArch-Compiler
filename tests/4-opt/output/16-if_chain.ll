; ModuleID = 'cminus'
source_filename = "/home/ymf/Desktop/Compiler/2024ustc-jianmu-compiler/tests/testcases_general/16-if_chain.cminus"

declare i32 @input()

declare void @output(i32)

declare void @outputFloat(float)

declare void @neg_idx_except()

define i32 @main() {
label_entry:
  %op0 = icmp ne i32 1, 0
  br i1 %op0, label %label1, label %label3
label1:                                                ; preds = %label_entry
  %op2 = icmp ne i32 0, 0
  br i1 %op2, label %label5, label %label8
label3:                                                ; preds = %label_entry, %label6
  %op4 = phi i32 [ 2, %label_entry ], [ %op7, %label6 ]
  ret i32 %op4
label5:                                                ; preds = %label1
  br label %label6
label6:                                                ; preds = %label5, %label8
  %op7 = phi i32 [ 4, %label5 ], [ 3, %label8 ]
  br label %label3
label8:                                                ; preds = %label1
  br label %label6
}
