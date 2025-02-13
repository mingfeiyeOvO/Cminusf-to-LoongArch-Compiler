; ModuleID = 'cminus'
source_filename = "/home/ymf/Desktop/Compiler/2024ustc-jianmu-compiler/tests/4-opt/testcases/functional-cases/4-if.cminus"

declare i32 @input()

declare void @output(i32)

declare void @outputFloat(float)

declare void @neg_idx_except()

define i32 @main() {
label_entry:
  %op0 = icmp sgt i32 11, 22
  %op1 = zext i1 %op0 to i32
  %op2 = icmp ne i32 %op1, 0
  br i1 %op2, label %label3, label %label8
label3:                                                ; preds = %label_entry
  %op4 = icmp sgt i32 11, 33
  %op5 = zext i1 %op4 to i32
  %op6 = icmp ne i32 %op5, 0
  br i1 %op6, label %label12, label %label14
label7:                                                ; preds = %label13, %label16
  ret i32 0
label8:                                                ; preds = %label_entry
  %op9 = icmp slt i32 33, 22
  %op10 = zext i1 %op9 to i32
  %op11 = icmp ne i32 %op10, 0
  br i1 %op11, label %label15, label %label17
label12:                                                ; preds = %label3
  call void @output(i32 11)
  br label %label13
label13:                                                ; preds = %label12, %label14
  br label %label7
label14:                                                ; preds = %label3
  call void @output(i32 33)
  br label %label13
label15:                                                ; preds = %label8
  call void @output(i32 22)
  br label %label16
label16:                                                ; preds = %label15, %label17
  br label %label7
label17:                                                ; preds = %label8
  call void @output(i32 33)
  br label %label16
}
