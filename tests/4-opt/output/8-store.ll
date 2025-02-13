; ModuleID = 'cminus'
source_filename = "/home/ymf/Desktop/Compiler/2024ustc-jianmu-compiler/tests/4-opt/testcases/functional-cases/8-store.cminus"

declare i32 @input()

declare void @output(i32)

declare void @outputFloat(float)

declare void @neg_idx_except()

define i32 @store(i32* %arg0, i32 %arg1, i32 %arg2) {
label_entry:
  %op3 = icmp slt i32 %arg1, 0
  br i1 %op3, label %label4, label %label5
label4:                                                ; preds = %label_entry
  call void @neg_idx_except()
  ret i32 0
label5:                                                ; preds = %label_entry
  %op6 = getelementptr i32, i32* %arg0, i32 %arg1
  store i32 %arg2, i32* %op6
  ret i32 %arg2
}
define i32 @main() {
label_entry:
  %op0 = alloca [10 x i32]
  br label %label26
label1:                                                ; preds = %label6, %label26
  %op2 = phi i32 [ 0, %label26 ], [ %op9, %label6 ]
  %op3 = icmp slt i32 %op2, 10
  %op4 = zext i1 %op3 to i32
  %op5 = icmp ne i32 %op4, 0
  br i1 %op5, label %label6, label %label10
label6:                                                ; preds = %label1
  %op7 = mul i32 %op2, 2
  %op8 = call i32 @store(i32* %op27, i32 %op2, i32 %op7)
  %op9 = add i32 %op2, 1
  br label %label1
label10:                                                ; preds = %label1
  br label %label11
label11:                                                ; preds = %label10, %label21
  %op12 = phi i32 [ 0, %label10 ], [ %op24, %label21 ]
  %op13 = phi i32 [ 0, %label10 ], [ %op25, %label21 ]
  %op14 = icmp slt i32 %op13, 10
  %op15 = zext i1 %op14 to i32
  %op16 = icmp ne i32 %op15, 0
  br i1 %op16, label %label17, label %label19
label17:                                                ; preds = %label11
  %op18 = icmp slt i32 %op13, 0
  br i1 %op18, label %label20, label %label21
label19:                                                ; preds = %label11
  call void @output(i32 %op12)
  ret i32 0
label20:                                                ; preds = %label17
  call void @neg_idx_except()
  ret i32 0
label21:                                                ; preds = %label17
  %op22 = getelementptr [10 x i32], [10 x i32]* %op0, i32 0, i32 %op13
  %op23 = load i32, i32* %op22
  %op24 = add i32 %op12, %op23
  %op25 = add i32 %op13, 1
  br label %label11
label26:                                                ; preds = %label_entry
  %op27 = getelementptr [10 x i32], [10 x i32]* %op0, i32 0, i32 0
  br label %label1
}
