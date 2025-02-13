	.text
	.globl main
	.type main, @function
main:
	st.d $ra, $sp, -8
	st.d $fp, $sp, -16
	addi.d $fp, $sp, 0
	addi.d $sp, $sp, -256
.main_label_entry:
# %op0 = alloca i32
	addi.d $t1, $fp, -28
	st.d $t1, $fp, -24
# %op1 = alloca i32
	addi.d $t1, $fp, -40
	st.d $t1, $fp, -36
# %op2 = alloca i32
	addi.d $t1, $fp, -52
	st.d $t1, $fp, -48
# store i32 1, i32* %op0
	ld.d $t0, $fp, -24
	addi.w $t1, $zero, 1
	st.w $t1, $t0, 0
# br label %label3
	b .main_label3
.main_label3:
# %op4 = load i32, i32* %op0
	ld.d $t0, $fp, -24
	ld.w $t1, $t0, 0
	st.w $t1, $fp, -56
# %op5 = icmp slt i32 %op4, 10000
	ld.w $t0, $fp, -56
	lu12i.w $t1, 2
	ori $t1, $t1, 1808
	slt $t0, $t0, $t1
	st.b $t0, $fp, -57
# %op6 = zext i1 %op5 to i32
	ld.b $t0, $fp, -57
	bstrpick.w $t1, $t0, 0, 0
	st.w $t1, $fp, -61
# %op7 = icmp ne i32 %op6, 0
	ld.w $t0, $fp, -61
	addi.w $t1, $zero, 0
	slt $t2, $t0, $t1
	slt $t3, $t1, $t0
	or $t0, $t2, $t3
	st.b $t0, $fp, -62
# br i1 %op7, label %label8, label %label9
	ld.b $t0, $fp, -62
	bstrpick.d $t1, $t0, 0, 0
	bnez $t1, .main_label8
	b .main_label9
.main_label8:
# store i32 0, i32* %op1
	ld.d $t0, $fp, -36
	addi.w $t1, $zero, 0
	st.w $t1, $t0, 0
# br label %label11
	b .main_label11
.main_label9:
# %op10 = load i32, i32* %op2
	ld.d $t0, $fp, -48
	ld.w $t1, $t0, 0
	st.w $t1, $fp, -66
# call void @output(i32 %op10)
	ld.w $a0, $fp, -66
	bl output
# ret void
	add.d $a0, $zero, $zero
	addi.d $sp, $sp, 256
	ld.d $ra, $sp, -8
	ld.d $fp, $sp, -16
	jr $ra
	jr $ra
.main_label11:
# %op12 = load i32, i32* %op1
	ld.d $t0, $fp, -36
	ld.w $t1, $t0, 0
	st.w $t1, $fp, -70
# %op13 = icmp slt i32 %op12, 10000
	ld.w $t0, $fp, -70
	lu12i.w $t1, 2
	ori $t1, $t1, 1808
	slt $t0, $t0, $t1
	st.b $t0, $fp, -71
# %op14 = zext i1 %op13 to i32
	ld.b $t0, $fp, -71
	bstrpick.w $t1, $t0, 0, 0
	st.w $t1, $fp, -75
# %op15 = icmp ne i32 %op14, 0
	ld.w $t0, $fp, -75
	addi.w $t1, $zero, 0
	slt $t2, $t0, $t1
	slt $t3, $t1, $t0
	or $t0, $t2, $t3
	st.b $t0, $fp, -76
# br i1 %op15, label %label16, label %label58
	ld.b $t0, $fp, -76
	bstrpick.d $t1, $t0, 0, 0
	bnez $t1, .main_label16
	b .main_label58
.main_label16:
# %op17 = load i32, i32* %op0
	ld.d $t0, $fp, -24
	ld.w $t1, $t0, 0
	st.w $t1, $fp, -80
# %op18 = load i32, i32* %op0
	ld.d $t0, $fp, -24
	ld.w $t1, $t0, 0
	st.w $t1, $fp, -84
# %op19 = mul i32 %op17, %op18
	ld.w $t0, $fp, -80
	ld.w $t1, $fp, -84
	mul.w $t2, $t0, $t1
	st.w $t2, $fp, -88
# %op20 = load i32, i32* %op0
	ld.d $t0, $fp, -24
	ld.w $t1, $t0, 0
	st.w $t1, $fp, -92
# %op21 = mul i32 %op19, %op20
	ld.w $t0, $fp, -88
	ld.w $t1, $fp, -92
	mul.w $t2, $t0, $t1
	st.w $t2, $fp, -96
# %op22 = load i32, i32* %op0
	ld.d $t0, $fp, -24
	ld.w $t1, $t0, 0
	st.w $t1, $fp, -100
# %op23 = mul i32 %op21, %op22
	ld.w $t0, $fp, -96
	ld.w $t1, $fp, -100
	mul.w $t2, $t0, $t1
	st.w $t2, $fp, -104
# %op24 = load i32, i32* %op0
	ld.d $t0, $fp, -24
	ld.w $t1, $t0, 0
	st.w $t1, $fp, -108
# %op25 = mul i32 %op23, %op24
	ld.w $t0, $fp, -104
	ld.w $t1, $fp, -108
	mul.w $t2, $t0, $t1
	st.w $t2, $fp, -112
# %op26 = load i32, i32* %op0
	ld.d $t0, $fp, -24
	ld.w $t1, $t0, 0
	st.w $t1, $fp, -116
# %op27 = mul i32 %op25, %op26
	ld.w $t0, $fp, -112
	ld.w $t1, $fp, -116
	mul.w $t2, $t0, $t1
	st.w $t2, $fp, -120
# %op28 = load i32, i32* %op0
	ld.d $t0, $fp, -24
	ld.w $t1, $t0, 0
	st.w $t1, $fp, -124
# %op29 = mul i32 %op27, %op28
	ld.w $t0, $fp, -120
	ld.w $t1, $fp, -124
	mul.w $t2, $t0, $t1
	st.w $t2, $fp, -128
# %op30 = load i32, i32* %op0
	ld.d $t0, $fp, -24
	ld.w $t1, $t0, 0
	st.w $t1, $fp, -132
# %op31 = mul i32 %op29, %op30
	ld.w $t0, $fp, -128
	ld.w $t1, $fp, -132
	mul.w $t2, $t0, $t1
	st.w $t2, $fp, -136
# %op32 = load i32, i32* %op0
	ld.d $t0, $fp, -24
	ld.w $t1, $t0, 0
	st.w $t1, $fp, -140
# %op33 = mul i32 %op31, %op32
	ld.w $t0, $fp, -136
	ld.w $t1, $fp, -140
	mul.w $t2, $t0, $t1
	st.w $t2, $fp, -144
# %op34 = load i32, i32* %op0
	ld.d $t0, $fp, -24
	ld.w $t1, $t0, 0
	st.w $t1, $fp, -148
# %op35 = mul i32 %op33, %op34
	ld.w $t0, $fp, -144
	ld.w $t1, $fp, -148
	mul.w $t2, $t0, $t1
	st.w $t2, $fp, -152
# %op36 = load i32, i32* %op0
	ld.d $t0, $fp, -24
	ld.w $t1, $t0, 0
	st.w $t1, $fp, -156
# %op37 = sdiv i32 %op35, %op36
	ld.w $t0, $fp, -152
	ld.w $t1, $fp, -156
	div.w $t2, $t0, $t1
	st.w $t2, $fp, -160
# %op38 = load i32, i32* %op0
	ld.d $t0, $fp, -24
	ld.w $t1, $t0, 0
	st.w $t1, $fp, -164
# %op39 = sdiv i32 %op37, %op38
	ld.w $t0, $fp, -160
	ld.w $t1, $fp, -164
	div.w $t2, $t0, $t1
	st.w $t2, $fp, -168
# %op40 = load i32, i32* %op0
	ld.d $t0, $fp, -24
	ld.w $t1, $t0, 0
	st.w $t1, $fp, -172
# %op41 = sdiv i32 %op39, %op40
	ld.w $t0, $fp, -168
	ld.w $t1, $fp, -172
	div.w $t2, $t0, $t1
	st.w $t2, $fp, -176
# %op42 = load i32, i32* %op0
	ld.d $t0, $fp, -24
	ld.w $t1, $t0, 0
	st.w $t1, $fp, -180
# %op43 = sdiv i32 %op41, %op42
	ld.w $t0, $fp, -176
	ld.w $t1, $fp, -180
	div.w $t2, $t0, $t1
	st.w $t2, $fp, -184
# %op44 = load i32, i32* %op0
	ld.d $t0, $fp, -24
	ld.w $t1, $t0, 0
	st.w $t1, $fp, -188
# %op45 = sdiv i32 %op43, %op44
	ld.w $t0, $fp, -184
	ld.w $t1, $fp, -188
	div.w $t2, $t0, $t1
	st.w $t2, $fp, -192
# %op46 = load i32, i32* %op0
	ld.d $t0, $fp, -24
	ld.w $t1, $t0, 0
	st.w $t1, $fp, -196
# %op47 = sdiv i32 %op45, %op46
	ld.w $t0, $fp, -192
	ld.w $t1, $fp, -196
	div.w $t2, $t0, $t1
	st.w $t2, $fp, -200
# %op48 = load i32, i32* %op0
	ld.d $t0, $fp, -24
	ld.w $t1, $t0, 0
	st.w $t1, $fp, -204
# %op49 = sdiv i32 %op47, %op48
	ld.w $t0, $fp, -200
	ld.w $t1, $fp, -204
	div.w $t2, $t0, $t1
	st.w $t2, $fp, -208
# %op50 = load i32, i32* %op0
	ld.d $t0, $fp, -24
	ld.w $t1, $t0, 0
	st.w $t1, $fp, -212
# %op51 = sdiv i32 %op49, %op50
	ld.w $t0, $fp, -208
	ld.w $t1, $fp, -212
	div.w $t2, $t0, $t1
	st.w $t2, $fp, -216
# %op52 = load i32, i32* %op0
	ld.d $t0, $fp, -24
	ld.w $t1, $t0, 0
	st.w $t1, $fp, -220
# %op53 = sdiv i32 %op51, %op52
	ld.w $t0, $fp, -216
	ld.w $t1, $fp, -220
	div.w $t2, $t0, $t1
	st.w $t2, $fp, -224
# %op54 = load i32, i32* %op0
	ld.d $t0, $fp, -24
	ld.w $t1, $t0, 0
	st.w $t1, $fp, -228
# %op55 = sdiv i32 %op53, %op54
	ld.w $t0, $fp, -224
	ld.w $t1, $fp, -228
	div.w $t2, $t0, $t1
	st.w $t2, $fp, -232
# store i32 %op55, i32* %op2
	ld.d $t0, $fp, -48
	ld.w $t1, $fp, -232
	st.w $t1, $t0, 0
# %op56 = load i32, i32* %op1
	ld.d $t0, $fp, -36
	ld.w $t1, $t0, 0
	st.w $t1, $fp, -236
# %op57 = add i32 %op56, 1
	ld.w $t0, $fp, -236
	addi.w $t1, $zero, 1
	add.w $t2, $t0, $t1
	st.w $t2, $fp, -240
# store i32 %op57, i32* %op1
	ld.d $t0, $fp, -36
	ld.w $t1, $fp, -240
	st.w $t1, $t0, 0
# br label %label11
	b .main_label11
.main_label58:
# %op59 = load i32, i32* %op0
	ld.d $t0, $fp, -24
	ld.w $t1, $t0, 0
	st.w $t1, $fp, -244
# %op60 = add i32 %op59, 1
	ld.w $t0, $fp, -244
	addi.w $t1, $zero, 1
	add.w $t2, $t0, $t1
	st.w $t2, $fp, -248
# store i32 %op60, i32* %op0
	ld.d $t0, $fp, -24
	ld.w $t1, $fp, -248
	st.w $t1, $t0, 0
# br label %label3
	b .main_label3
	addi.d $sp, $sp, 256
	ld.d $ra, $sp, -8
	ld.d $fp, $sp, -16
	jr $ra
