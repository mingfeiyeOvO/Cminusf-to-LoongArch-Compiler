; ModuleID = 'cminus'
source_filename = "/home/ymf/Desktop/Compiler/2024ustc-jianmu-compiler/tests/testcases_general/12-funcall_recursion.cminus"

declare i32 @input()

declare void @output(i32)

declare void @outputFloat(float)

declare void @neg_idx_except()

define i32 @factorial(i32 %arg0) {
label_entry:
  %op1 = icmp eq i32 %arg0, 0
  %op2 = zext i1 %op1 to i32
  %op3 = icmp ne i32 %op2, 0
  br i1 %op3, label %label4, label %label5
label4:                                                ; preds = %label_entry
  ret i32 1
label5:                                                ; preds = %label_entry
  %op6 = sub i32 %arg0, 1
  %op7 = call i32 @factorial(i32 %op6)
  %op8 = mul i32 %arg0, %op7
  ret i32 %op8
}
define i32 @main() {
label_entry:
  %op0 = call i32 @factorial(i32 10)
  ret i32 %op0
}
