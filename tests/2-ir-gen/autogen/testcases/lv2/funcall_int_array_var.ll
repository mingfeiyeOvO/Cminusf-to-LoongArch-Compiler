; ModuleID = 'cminus'
source_filename = "/home/ymf/Desktop/Compiler/2024ustc-jianmu-compiler/tests/2-ir-gen/autogen/testcases/lv2/funcall_int_array.cminus"

declare i32 @input()

declare void @output(i32)

declare void @outputFloat(float)

declare void @neg_idx_except()

define void @test(i32* %arg0) {
label1:
  %op2 = alloca i32*
  store i32* %arg0, i32** %op2
  %op3 = load i32*, i32** %op2
  %op4 = icmp slt i32 3, zeroinitializer
  br i1 %op4, label %label5, label %label6
label5:                                                ; preds = %label1
  call void @neg_idx_except()
  br label %label6
label6:                                                ; preds = %label1, %label5
  %op7 = getelementptr i32, i32* %op3, i32 3
  %op8 = load i32, i32* %op7
  call void @output(i32 %op8)
  ret void
}
define void @main() {
label0:
  %op1 = alloca [10 x i32]
  %op2 = icmp slt i32 3, zeroinitializer
  br i1 %op2, label %label3, label %label4
label3:                                                ; preds = %label0
  call void @neg_idx_except()
  br label %label4
label4:                                                ; preds = %label0, %label3
  %op5 = getelementptr [10 x i32], [10 x i32]* %op1, i32 0, i32 3
  %op6 = load i32, i32* %op5
  store i32 10, i32* %op5
  %op7 = getelementptr [10 x i32], [10 x i32]* %op1, i32 0, i32 0
  %op8 = load i32, i32* %op7
  call void @test(i32* %op5)
  ret void
}
