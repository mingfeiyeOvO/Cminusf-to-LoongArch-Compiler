; ModuleID = 'cminus'
source_filename = "/home/ymf/Desktop/Compiler/2024ustc-jianmu-compiler/tests/4-opt/testcases/loop/loop-1.cminus"

declare i32 @input()

declare void @output(i32)

declare void @outputFloat(float)

declare void @neg_idx_except()

define void @main() {
label_entry:
  br label %label0
label0:                                                ; preds = %label_entry, %label16
  %op1 = phi i32 [ 1, %label_entry ], [ %op17, %label16 ]
  %op2 = phi i32 [ %op10, %label16 ], [ undef, %label_entry ]
  %op3 = icmp slt i32 %op1, 10000
  %op4 = zext i1 %op3 to i32
  %op5 = icmp ne i32 %op4, 0
  br i1 %op5, label %label6, label %label7
label6:                                                ; preds = %label0
  br label %label18
label7:                                                ; preds = %label0
  call void @output(i32 %op2)
  ret void
label8:                                                ; preds = %label14, %label18
  %op9 = phi i32 [ 0, %label18 ], [ %op15, %label14 ]
  %op10 = phi i32 [ %op2, %label18 ], [ %op37, %label14 ]
  %op11 = icmp slt i32 %op9, 10000
  %op12 = zext i1 %op11 to i32
  %op13 = icmp ne i32 %op12, 0
  br i1 %op13, label %label14, label %label16
label14:                                                ; preds = %label8
  %op15 = add i32 %op9, 1
  br label %label8
label16:                                                ; preds = %label8
  %op17 = add i32 %op1, 1
  br label %label0
label18:                                                ; preds = %label6
  %op19 = mul i32 %op1, %op1
  %op20 = mul i32 %op19, %op1
  %op21 = mul i32 %op20, %op1
  %op22 = mul i32 %op21, %op1
  %op23 = mul i32 %op22, %op1
  %op24 = mul i32 %op23, %op1
  %op25 = mul i32 %op24, %op1
  %op26 = mul i32 %op25, %op1
  %op27 = mul i32 %op26, %op1
  %op28 = sdiv i32 %op27, %op1
  %op29 = sdiv i32 %op28, %op1
  %op30 = sdiv i32 %op29, %op1
  %op31 = sdiv i32 %op30, %op1
  %op32 = sdiv i32 %op31, %op1
  %op33 = sdiv i32 %op32, %op1
  %op34 = sdiv i32 %op33, %op1
  %op35 = sdiv i32 %op34, %op1
  %op36 = sdiv i32 %op35, %op1
  %op37 = sdiv i32 %op36, %op1
  br label %label8
}
