; ModuleID = 'cminus'
source_filename = "/home/ymf/Desktop/Compiler/2024ustc-jianmu-compiler/tests/4-opt/testcases/functional-cases/9-fibonacci.cminus"

declare i32 @input()

declare void @output(i32)

declare void @outputFloat(float)

declare void @neg_idx_except()

define i32 @fibonacci(i32 %arg0) {
label_entry:
  %op1 = icmp eq i32 %arg0, 0
  %op2 = zext i1 %op1 to i32
  %op3 = icmp ne i32 %op2, 0
  br i1 %op3, label %label4, label %label5
label4:                                                ; preds = %label_entry
  ret i32 0
label5:                                                ; preds = %label_entry
  %op6 = icmp eq i32 %arg0, 1
  %op7 = zext i1 %op6 to i32
  %op8 = icmp ne i32 %op7, 0
  br i1 %op8, label %label9, label %label10
label9:                                                ; preds = %label5
  ret i32 1
label10:                                                ; preds = %label5
  %op11 = sub i32 %arg0, 1
  %op12 = call i32 @fibonacci(i32 %op11)
  %op13 = sub i32 %arg0, 2
  %op14 = call i32 @fibonacci(i32 %op13)
  %op15 = add i32 %op12, %op14
  ret i32 %op15
}
define i32 @main() {
label_entry:
  br label %label0
label0:                                                ; preds = %label_entry, %label5
  %op1 = phi i32 [ 0, %label_entry ], [ %op7, %label5 ]
  %op2 = icmp slt i32 %op1, 10
  %op3 = zext i1 %op2 to i32
  %op4 = icmp ne i32 %op3, 0
  br i1 %op4, label %label5, label %label8
label5:                                                ; preds = %label0
  %op6 = call i32 @fibonacci(i32 %op1)
  call void @output(i32 %op6)
  %op7 = add i32 %op1, 1
  br label %label0
label8:                                                ; preds = %label0
  ret i32 0
}
