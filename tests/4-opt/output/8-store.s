	.text
	.globl store
	.type store, @function
store:
	st.d $ra, $sp, -8
	st.d $fp, $sp, -16
	addi.d $fp, $sp, 0
	addi.d $sp, $sp, -48
	st.d $a0, $fp, -24
	st.w $a1, $fp, -28
	st.w $a2, $fp, -32
.store_label_entry:
# %op3 = icmp slt i32 %arg1, 0
	ld.w $t0, $fp, -28
	addi.w $t1, $zero, 0
	slt $t0, $t0, $t1
	st.b $t0, $fp, -33
# br i1 %op3, label %label4, label %label5
	ld.b $t0, $fp, -33
	bstrpick.d $t1, $t0, 0, 0
	bnez $t1, .store_label4
	b .store_label5
.store_label4:
# call void @neg_idx_except()
	bl neg_idx_except
# ret i32 0
	addi.w $a0, $zero, 0
	addi.d $sp, $sp, 48
	ld.d $ra, $sp, -8
	ld.d $fp, $sp, -16
	jr $ra
	jr $ra
.store_label5:
# %op6 = getelementptr i32, i32* %arg0, i32 %arg1
	ld.d $t0, $fp, -24
	ld.w $t1, $fp, -28
	lu12i.w $t3, 0
	ori $t3, $t3, 4
	mul.w $t1, $t1, $t3
	bstrpick.d $t1, $t1, 31, 0
	add.d $t0, $t0, $t1
	st.d $t0, $fp, -41
# store i32 %arg2, i32* %op6
	ld.d $t0, $fp, -41
	ld.w $t1, $fp, -32
	st.w $t1, $t0, 0
# ret i32 %arg2
	ld.w $a0, $fp, -32
	addi.d $sp, $sp, 48
	ld.d $ra, $sp, -8
	ld.d $fp, $sp, -16
	jr $ra
	jr $ra
	addi.d $sp, $sp, 48
	ld.d $ra, $sp, -8
	ld.d $fp, $sp, -16
	jr $ra
	.globl main
	.type main, @function
main:
	st.d $ra, $sp, -8
	st.d $fp, $sp, -16
	addi.d $fp, $sp, 0
	addi.d $sp, $sp, -144
.main_label_entry:
# %op0 = alloca [10 x i32]
	addi.d $t1, $fp, -64
	st.d $t1, $fp, -24
# br label %label26
	b .main_label26
.main_label1:
# %op2 = phi i32 [ 0, %label26 ], [ %op9, %label6 ]
# %op3 = icmp slt i32 %op2, 10
	ld.w $t0, $fp, -68
	addi.w $t1, $zero, 10
	slt $t0, $t0, $t1
	st.b $t0, $fp, -69
# %op4 = zext i1 %op3 to i32
	ld.b $t0, $fp, -69
	bstrpick.w $t1, $t0, 0, 0
	st.w $t1, $fp, -73
# %op5 = icmp ne i32 %op4, 0
	ld.w $t0, $fp, -73
	addi.w $t1, $zero, 0
	slt $t2, $t0, $t1
	slt $t3, $t1, $t0
	or $t0, $t2, $t3
	st.b $t0, $fp, -74
# br i1 %op5, label %label6, label %label10
	ld.b $t0, $fp, -74
	bstrpick.d $t1, $t0, 0, 0
	bnez $t1, .main_label6
	b .main_label10
.main_label6:
# %op7 = mul i32 %op2, 2
	ld.w $t0, $fp, -68
	addi.w $t1, $zero, 2
	mul.w $t2, $t0, $t1
	st.w $t2, $fp, -78
# %op8 = call i32 @store(i32* %op27, i32 %op2, i32 %op7)
	ld.d $a0, $fp, -129
	ld.w $a1, $fp, -68
	ld.w $a2, $fp, -78
	bl store
	st.w $a0, $fp, -82
# %op9 = add i32 %op2, 1
	ld.w $t0, $fp, -68
	addi.w $t1, $zero, 1
	add.w $t2, $t0, $t1
	st.w $t2, $fp, -86
# br label %label1
	ld.w $a0, $fp, -86
	st.w $a0, $fp, -68
	b .main_label1
.main_label10:
# br label %label11
	addi.w $a0, $zero, 0
	st.w $a0, $fp, -90
	addi.w $a0, $zero, 0
	st.w $a0, $fp, -94
	b .main_label11
.main_label11:
# %op12 = phi i32 [ 0, %label10 ], [ %op24, %label21 ]
# %op13 = phi i32 [ 0, %label10 ], [ %op25, %label21 ]
# %op14 = icmp slt i32 %op13, 10
	ld.w $t0, $fp, -94
	addi.w $t1, $zero, 10
	slt $t0, $t0, $t1
	st.b $t0, $fp, -95
# %op15 = zext i1 %op14 to i32
	ld.b $t0, $fp, -95
	bstrpick.w $t1, $t0, 0, 0
	st.w $t1, $fp, -99
# %op16 = icmp ne i32 %op15, 0
	ld.w $t0, $fp, -99
	addi.w $t1, $zero, 0
	slt $t2, $t0, $t1
	slt $t3, $t1, $t0
	or $t0, $t2, $t3
	st.b $t0, $fp, -100
# br i1 %op16, label %label17, label %label19
	ld.b $t0, $fp, -100
	bstrpick.d $t1, $t0, 0, 0
	bnez $t1, .main_label17
	b .main_label19
.main_label17:
# %op18 = icmp slt i32 %op13, 0
	ld.w $t0, $fp, -94
	addi.w $t1, $zero, 0
	slt $t0, $t0, $t1
	st.b $t0, $fp, -101
# br i1 %op18, label %label20, label %label21
	ld.b $t0, $fp, -101
	bstrpick.d $t1, $t0, 0, 0
	bnez $t1, .main_label20
	b .main_label21
.main_label19:
# call void @output(i32 %op12)
	ld.w $a0, $fp, -90
	bl output
# ret i32 0
	addi.w $a0, $zero, 0
	addi.d $sp, $sp, 144
	ld.d $ra, $sp, -8
	ld.d $fp, $sp, -16
	jr $ra
	jr $ra
.main_label20:
# call void @neg_idx_except()
	bl neg_idx_except
# ret i32 0
	addi.w $a0, $zero, 0
	addi.d $sp, $sp, 144
	ld.d $ra, $sp, -8
	ld.d $fp, $sp, -16
	jr $ra
	jr $ra
.main_label21:
# %op22 = getelementptr [10 x i32], [10 x i32]* %op0, i32 0, i32 %op13
	ld.d $t0, $fp, -24
	addi.w $t1, $zero, 0
	ld.w $t2, $fp, -94
	lu12i.w $t3, 0
	ori $t3, $t3, 40
	lu12i.w $t4, 0
	ori $t4, $t4, 4
	mul.w $t1, $t1, $t3
	mul.w $t2, $t2, $t4
	bstrpick.d $t1, $t1, 31, 0
	bstrpick.d $t2, $t2, 31, 0
	add.d $t0, $t0, $t1
	add.d $t0, $t0, $t2
	st.d $t0, $fp, -109
# %op23 = load i32, i32* %op22
	ld.d $t0, $fp, -109
	ld.w $t1, $t0, 0
	st.w $t1, $fp, -113
# %op24 = add i32 %op12, %op23
	ld.w $t0, $fp, -90
	ld.w $t1, $fp, -113
	add.w $t2, $t0, $t1
	st.w $t2, $fp, -117
# %op25 = add i32 %op13, 1
	ld.w $t0, $fp, -94
	addi.w $t1, $zero, 1
	add.w $t2, $t0, $t1
	st.w $t2, $fp, -121
# br label %label11
	ld.w $a0, $fp, -117
	st.w $a0, $fp, -90
	ld.w $a0, $fp, -121
	st.w $a0, $fp, -94
	b .main_label11
.main_label26:
# %op27 = getelementptr [10 x i32], [10 x i32]* %op0, i32 0, i32 0
	ld.d $t0, $fp, -24
	addi.w $t1, $zero, 0
	addi.w $t2, $zero, 0
	lu12i.w $t3, 0
	ori $t3, $t3, 40
	lu12i.w $t4, 0
	ori $t4, $t4, 4
	mul.w $t1, $t1, $t3
	mul.w $t2, $t2, $t4
	bstrpick.d $t1, $t1, 31, 0
	bstrpick.d $t2, $t2, 31, 0
	add.d $t0, $t0, $t1
	add.d $t0, $t0, $t2
	st.d $t0, $fp, -129
# br label %label1
	addi.w $a0, $zero, 0
	st.w $a0, $fp, -68
	b .main_label1
	addi.d $sp, $sp, 144
	ld.d $ra, $sp, -8
	ld.d $fp, $sp, -16
	jr $ra
