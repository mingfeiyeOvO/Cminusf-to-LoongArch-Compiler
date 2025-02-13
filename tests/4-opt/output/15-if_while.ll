; ModuleID = 'cminus'
source_filename = "/home/ymf/Desktop/Compiler/2024ustc-jianmu-compiler/tests/testcases_general/15-if_while.cminus"

declare i32 @input()

declare void @output(i32)

declare void @outputFloat(float)

declare void @neg_idx_except()

define i32 @main() {
label_entry:
  br label %label0
label0:                                                ; preds = %label_entry, %label14
  %op1 = phi i32 [ 0, %label_entry ], [ %op15, %label14 ]
  %op2 = phi i32 [ 10, %label_entry ], [ %op6, %label14 ]
  %op3 = phi i32 [ 0, %label_entry ], [ %op16, %label14 ]
  %op4 = icmp ne i32 %op2, 0
  br i1 %op4, label %label5, label %label10
label5:                                                ; preds = %label0
  %op6 = sub i32 %op2, 1
  %op7 = icmp slt i32 %op6, 5
  %op8 = zext i1 %op7 to i32
  %op9 = icmp ne i32 %op8, 0
  br i1 %op9, label %label12, label %label17
label10:                                                ; preds = %label0
  %op11 = add i32 %op1, %op3
  ret i32 %op11
label12:                                                ; preds = %label5
  %op13 = add i32 %op1, %op6
  br label %label14
label14:                                                ; preds = %label12, %label17
  %op15 = phi i32 [ %op13, %label12 ], [ %op1, %label17 ]
  %op16 = phi i32 [ %op3, %label12 ], [ %op18, %label17 ]
  br label %label0
label17:                                                ; preds = %label5
  %op18 = add i32 %op3, %op6
  br label %label14
}
