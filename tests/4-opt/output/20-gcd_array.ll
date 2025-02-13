; ModuleID = 'cminus'
source_filename = "/home/ymf/Desktop/Compiler/2024ustc-jianmu-compiler/tests/testcases_general/20-gcd_array.cminus"

@x = global [1 x i32] zeroinitializer
@y = global [1 x i32] zeroinitializer
declare i32 @input()

declare void @output(i32)

declare void @outputFloat(float)

declare void @neg_idx_except()

define i32 @gcd(i32 %arg0, i32 %arg1) {
label_entry:
  %op2 = icmp eq i32 %arg1, 0
  %op3 = zext i1 %op2 to i32
  %op4 = icmp ne i32 %op3, 0
  br i1 %op4, label %label5, label %label6
label5:                                                ; preds = %label_entry
  ret i32 %arg0
label6:                                                ; preds = %label_entry
  %op7 = sdiv i32 %arg0, %arg1
  %op8 = mul i32 %op7, %arg1
  %op9 = sub i32 %arg0, %op8
  %op10 = call i32 @gcd(i32 %arg1, i32 %op9)
  ret i32 %op10
}
define i32 @funArray(i32* %arg0, i32* %arg1) {
label_entry:
  %op2 = icmp slt i32 0, 0
  br i1 %op2, label %label3, label %label4
label3:                                                ; preds = %label_entry
  call void @neg_idx_except()
  ret i32 0
label4:                                                ; preds = %label_entry
  %op5 = getelementptr i32, i32* %arg0, i32 0
  %op6 = load i32, i32* %op5
  %op7 = icmp slt i32 0, 0
  br i1 %op7, label %label8, label %label9
label8:                                                ; preds = %label4
  call void @neg_idx_except()
  ret i32 0
label9:                                                ; preds = %label4
  %op10 = getelementptr i32, i32* %arg1, i32 0
  %op11 = load i32, i32* %op10
  %op12 = icmp slt i32 %op6, %op11
  %op13 = zext i1 %op12 to i32
  %op14 = icmp ne i32 %op13, 0
  br i1 %op14, label %label15, label %label16
label15:                                                ; preds = %label9
  br label %label16
label16:                                                ; preds = %label9, %label15
  %op17 = phi i32 [ %op11, %label9 ], [ %op6, %label15 ]
  %op18 = phi i32 [ %op6, %label9 ], [ %op11, %label15 ]
  %op19 = call i32 @gcd(i32 %op18, i32 %op17)
  ret i32 %op19
}
define i32 @main() {
label_entry:
  %op0 = icmp slt i32 0, 0
  br i1 %op0, label %label1, label %label2
label1:                                                ; preds = %label_entry
  call void @neg_idx_except()
  ret i32 0
label2:                                                ; preds = %label_entry
  %op3 = getelementptr [1 x i32], [1 x i32]* @x, i32 0, i32 0
  store i32 90, i32* %op3
  %op4 = icmp slt i32 0, 0
  br i1 %op4, label %label5, label %label6
label5:                                                ; preds = %label2
  call void @neg_idx_except()
  ret i32 0
label6:                                                ; preds = %label2
  %op7 = getelementptr [1 x i32], [1 x i32]* @y, i32 0, i32 0
  store i32 18, i32* %op7
  %op8 = getelementptr [1 x i32], [1 x i32]* @x, i32 0, i32 0
  %op9 = getelementptr [1 x i32], [1 x i32]* @y, i32 0, i32 0
  %op10 = call i32 @funArray(i32* %op8, i32* %op9)
  ret i32 %op10
}
