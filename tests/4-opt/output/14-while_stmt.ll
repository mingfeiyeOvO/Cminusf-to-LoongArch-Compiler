; ModuleID = 'cminus'
source_filename = "/home/ymf/Desktop/Compiler/2024ustc-jianmu-compiler/tests/testcases_general/14-while_stmt.cminus"

declare i32 @input()

declare void @output(i32)

declare void @outputFloat(float)

declare void @neg_idx_except()

define void @main() {
label_entry:
  br label %label0
label0:                                                ; preds = %label_entry, %label3
  %op1 = phi i32 [ 10, %label_entry ], [ %op4, %label3 ]
  %op2 = icmp ne i32 %op1, 0
  br i1 %op2, label %label3, label %label5
label3:                                                ; preds = %label0
  %op4 = sub i32 %op1, 1
  br label %label0
label5:                                                ; preds = %label0
  ret void
}
