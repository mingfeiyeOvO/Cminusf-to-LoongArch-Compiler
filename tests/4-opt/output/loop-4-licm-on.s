	.text
	.globl main
	.type main, @function
main:
	st.d $ra, $sp, -8
	st.d $fp, $sp, -16
	addi.d $fp, $sp, 0
	addi.d $sp, $sp, -240
.main_label_entry:
# br label %label67
	b .main_label67
.main_label0:
# %op1 = phi i32 [ %op9, %label15 ], [ undef, %label67 ]
# %op2 = phi i32 [ 0, %label67 ], [ %op16, %label15 ]
# %op3 = icmp slt i32 %op2, 1000000
	ld.w $t0, $fp, -24
	lu12i.w $t1, 244
	ori $t1, $t1, 576
	slt $t0, $t0, $t1
	st.b $t0, $fp, -25
# %op4 = zext i1 %op3 to i32
	ld.b $t0, $fp, -25
	bstrpick.w $t1, $t0, 0, 0
	st.w $t1, $fp, -29
# %op5 = icmp ne i32 %op4, 0
	ld.w $t0, $fp, -29
	addi.w $t1, $zero, 0
	slt $t2, $t0, $t1
	slt $t3, $t1, $t0
	or $t0, $t2, $t3
	st.b $t0, $fp, -30
# br i1 %op5, label %label6, label %label7
	ld.b $t0, $fp, -30
	bstrpick.d $t1, $t0, 0, 0
	bnez $t1, .main_label6
	b .main_label7
.main_label6:
# br label %label66
	b .main_label66
.main_label7:
# call void @output(i32 %op1)
	ld.w $a0, $fp, -20
	bl output
# ret void
	add.d $a0, $zero, $zero
	addi.d $sp, $sp, 240
	ld.d $ra, $sp, -8
	ld.d $fp, $sp, -16
	jr $ra
	jr $ra
.main_label8:
# %op9 = phi i32 [ %op1, %label66 ], [ %op18, %label25 ]
# %op10 = phi i32 [ 0, %label66 ], [ %op26, %label25 ]
# %op11 = icmp slt i32 %op10, 2
	ld.w $t0, $fp, -38
	addi.w $t1, $zero, 2
	slt $t0, $t0, $t1
	st.b $t0, $fp, -39
# %op12 = zext i1 %op11 to i32
	ld.b $t0, $fp, -39
	bstrpick.w $t1, $t0, 0, 0
	st.w $t1, $fp, -43
# %op13 = icmp ne i32 %op12, 0
	ld.w $t0, $fp, -43
	addi.w $t1, $zero, 0
	slt $t2, $t0, $t1
	slt $t3, $t1, $t0
	or $t0, $t2, $t3
	st.b $t0, $fp, -44
# br i1 %op13, label %label14, label %label15
	ld.b $t0, $fp, -44
	bstrpick.d $t1, $t0, 0, 0
	bnez $t1, .main_label14
	b .main_label15
.main_label14:
# br label %label65
	b .main_label65
.main_label15:
# %op16 = add i32 %op2, 1
	ld.w $t0, $fp, -24
	addi.w $t1, $zero, 1
	add.w $t2, $t0, $t1
	st.w $t2, $fp, -48
# br label %label0
	ld.w $a0, $fp, -34
	st.w $a0, $fp, -20
	ld.w $a0, $fp, -48
	st.w $a0, $fp, -24
	b .main_label0
.main_label17:
# %op18 = phi i32 [ %op9, %label65 ], [ %op28, %label35 ]
# %op19 = phi i32 [ %op10, %label65 ], [ %op29, %label35 ]
# %op20 = phi i32 [ 0, %label65 ], [ %op36, %label35 ]
# %op21 = icmp slt i32 %op20, 2
	ld.w $t0, $fp, -60
	addi.w $t1, $zero, 2
	slt $t0, $t0, $t1
	st.b $t0, $fp, -61
# %op22 = zext i1 %op21 to i32
	ld.b $t0, $fp, -61
	bstrpick.w $t1, $t0, 0, 0
	st.w $t1, $fp, -65
# %op23 = icmp ne i32 %op22, 0
	ld.w $t0, $fp, -65
	addi.w $t1, $zero, 0
	slt $t2, $t0, $t1
	slt $t3, $t1, $t0
	or $t0, $t2, $t3
	st.b $t0, $fp, -66
# br i1 %op23, label %label24, label %label25
	ld.b $t0, $fp, -66
	bstrpick.d $t1, $t0, 0, 0
	bnez $t1, .main_label24
	b .main_label25
.main_label24:
# br label %label64
	b .main_label64
.main_label25:
# %op26 = add i32 %op19, 1
	ld.w $t0, $fp, -56
	addi.w $t1, $zero, 1
	add.w $t2, $t0, $t1
	st.w $t2, $fp, -70
# br label %label8
	ld.w $a0, $fp, -52
	st.w $a0, $fp, -34
	ld.w $a0, $fp, -70
	st.w $a0, $fp, -38
	b .main_label8
.main_label27:
# %op28 = phi i32 [ %op18, %label64 ], [ %op38, %label45 ]
# %op29 = phi i32 [ %op19, %label64 ], [ %op39, %label45 ]
# %op30 = phi i32 [ 0, %label64 ], [ %op46, %label45 ]
# %op31 = icmp slt i32 %op30, 2
	ld.w $t0, $fp, -82
	addi.w $t1, $zero, 2
	slt $t0, $t0, $t1
	st.b $t0, $fp, -83
# %op32 = zext i1 %op31 to i32
	ld.b $t0, $fp, -83
	bstrpick.w $t1, $t0, 0, 0
	st.w $t1, $fp, -87
# %op33 = icmp ne i32 %op32, 0
	ld.w $t0, $fp, -87
	addi.w $t1, $zero, 0
	slt $t2, $t0, $t1
	slt $t3, $t1, $t0
	or $t0, $t2, $t3
	st.b $t0, $fp, -88
# br i1 %op33, label %label34, label %label35
	ld.b $t0, $fp, -88
	bstrpick.d $t1, $t0, 0, 0
	bnez $t1, .main_label34
	b .main_label35
.main_label34:
# br label %label63
	b .main_label63
.main_label35:
# %op36 = add i32 %op20, 1
	ld.w $t0, $fp, -60
	addi.w $t1, $zero, 1
	add.w $t2, $t0, $t1
	st.w $t2, $fp, -92
# br label %label17
	ld.w $a0, $fp, -74
	st.w $a0, $fp, -52
	ld.w $a0, $fp, -78
	st.w $a0, $fp, -56
	ld.w $a0, $fp, -92
	st.w $a0, $fp, -60
	b .main_label17
.main_label37:
# %op38 = phi i32 [ %op28, %label63 ], [ %op48, %label55 ]
# %op39 = phi i32 [ %op29, %label63 ], [ %op49, %label55 ]
# %op40 = phi i32 [ 0, %label63 ], [ %op56, %label55 ]
# %op41 = icmp slt i32 %op40, 2
	ld.w $t0, $fp, -104
	addi.w $t1, $zero, 2
	slt $t0, $t0, $t1
	st.b $t0, $fp, -105
# %op42 = zext i1 %op41 to i32
	ld.b $t0, $fp, -105
	bstrpick.w $t1, $t0, 0, 0
	st.w $t1, $fp, -109
# %op43 = icmp ne i32 %op42, 0
	ld.w $t0, $fp, -109
	addi.w $t1, $zero, 0
	slt $t2, $t0, $t1
	slt $t3, $t1, $t0
	or $t0, $t2, $t3
	st.b $t0, $fp, -110
# br i1 %op43, label %label44, label %label45
	ld.b $t0, $fp, -110
	bstrpick.d $t1, $t0, 0, 0
	bnez $t1, .main_label44
	b .main_label45
.main_label44:
# br label %label62
	b .main_label62
.main_label45:
# %op46 = add i32 %op30, 1
	ld.w $t0, $fp, -82
	addi.w $t1, $zero, 1
	add.w $t2, $t0, $t1
	st.w $t2, $fp, -114
# br label %label27
	ld.w $a0, $fp, -96
	st.w $a0, $fp, -74
	ld.w $a0, $fp, -100
	st.w $a0, $fp, -78
	ld.w $a0, $fp, -114
	st.w $a0, $fp, -82
	b .main_label27
.main_label47:
# %op48 = phi i32 [ %op38, %label62 ], [ %op89, %label59 ]
# %op49 = phi i32 [ %op39, %label62 ], [ %op60, %label59 ]
# %op50 = phi i32 [ 0, %label62 ], [ %op61, %label59 ]
# %op51 = icmp slt i32 %op50, 2
	ld.w $t0, $fp, -126
	addi.w $t1, $zero, 2
	slt $t0, $t0, $t1
	st.b $t0, $fp, -127
# %op52 = zext i1 %op51 to i32
	ld.b $t0, $fp, -127
	bstrpick.w $t1, $t0, 0, 0
	st.w $t1, $fp, -131
# %op53 = icmp ne i32 %op52, 0
	ld.w $t0, $fp, -131
	addi.w $t1, $zero, 0
	slt $t2, $t0, $t1
	slt $t3, $t1, $t0
	or $t0, $t2, $t3
	st.b $t0, $fp, -132
# br i1 %op53, label %label54, label %label55
	ld.b $t0, $fp, -132
	bstrpick.d $t1, $t0, 0, 0
	bnez $t1, .main_label54
	b .main_label55
.main_label54:
# br i1 %op72, label %label57, label %label59
	ld.w $a0, $fp, -122
	st.w $a0, $fp, -144
	ld.b $t0, $fp, -162
	bstrpick.d $t1, $t0, 0, 0
	bnez $t1, .main_label57
	b .main_label59
.main_label55:
# %op56 = add i32 %op40, 1
	ld.w $t0, $fp, -104
	addi.w $t1, $zero, 1
	add.w $t2, $t0, $t1
	st.w $t2, $fp, -136
# br label %label37
	ld.w $a0, $fp, -118
	st.w $a0, $fp, -96
	ld.w $a0, $fp, -122
	st.w $a0, $fp, -100
	ld.w $a0, $fp, -136
	st.w $a0, $fp, -104
	b .main_label37
.main_label57:
# %op58 = add i32 %op49, 1
	ld.w $t0, $fp, -122
	addi.w $t1, $zero, 1
	add.w $t2, $t0, $t1
	st.w $t2, $fp, -140
# br label %label59
	ld.w $a0, $fp, -140
	st.w $a0, $fp, -144
	b .main_label59
.main_label59:
# %op60 = phi i32 [ %op49, %label54 ], [ %op58, %label57 ]
# %op61 = add i32 %op50, 1
	ld.w $t0, $fp, -126
	addi.w $t1, $zero, 1
	add.w $t2, $t0, $t1
	st.w $t2, $fp, -148
# br label %label47
	ld.w $a0, $fp, -230
	st.w $a0, $fp, -118
	ld.w $a0, $fp, -144
	st.w $a0, $fp, -122
	ld.w $a0, $fp, -148
	st.w $a0, $fp, -126
	b .main_label47
.main_label62:
# br label %label47
	ld.w $a0, $fp, -96
	st.w $a0, $fp, -118
	ld.w $a0, $fp, -100
	st.w $a0, $fp, -122
	addi.w $a0, $zero, 0
	st.w $a0, $fp, -126
	b .main_label47
.main_label63:
# br label %label37
	ld.w $a0, $fp, -74
	st.w $a0, $fp, -96
	ld.w $a0, $fp, -78
	st.w $a0, $fp, -100
	addi.w $a0, $zero, 0
	st.w $a0, $fp, -104
	b .main_label37
.main_label64:
# br label %label27
	ld.w $a0, $fp, -52
	st.w $a0, $fp, -74
	ld.w $a0, $fp, -56
	st.w $a0, $fp, -78
	addi.w $a0, $zero, 0
	st.w $a0, $fp, -82
	b .main_label27
.main_label65:
# br label %label17
	ld.w $a0, $fp, -34
	st.w $a0, $fp, -52
	ld.w $a0, $fp, -38
	st.w $a0, $fp, -56
	addi.w $a0, $zero, 0
	st.w $a0, $fp, -60
	b .main_label17
.main_label66:
# br label %label8
	ld.w $a0, $fp, -20
	st.w $a0, $fp, -34
	addi.w $a0, $zero, 0
	st.w $a0, $fp, -38
	b .main_label8
.main_label67:
# %op68 = icmp sgt i32 2, 1
	addi.w $t0, $zero, 2
	addi.w $t1, $zero, 1
	slt $t0, $t1, $t0
	st.b $t0, $fp, -149
# %op69 = mul i32 2, 2
	addi.w $t0, $zero, 2
	addi.w $t1, $zero, 2
	mul.w $t2, $t0, $t1
	st.w $t2, $fp, -153
# %op70 = zext i1 %op68 to i32
	ld.b $t0, $fp, -149
	bstrpick.w $t1, $t0, 0, 0
	st.w $t1, $fp, -157
# %op71 = mul i32 %op69, 2
	ld.w $t0, $fp, -153
	addi.w $t1, $zero, 2
	mul.w $t2, $t0, $t1
	st.w $t2, $fp, -161
# %op72 = icmp ne i32 %op70, 0
	ld.w $t0, $fp, -157
	addi.w $t1, $zero, 0
	slt $t2, $t0, $t1
	slt $t3, $t1, $t0
	or $t0, $t2, $t3
	st.b $t0, $fp, -162
# %op73 = mul i32 %op71, 2
	ld.w $t0, $fp, -161
	addi.w $t1, $zero, 2
	mul.w $t2, $t0, $t1
	st.w $t2, $fp, -166
# %op74 = mul i32 %op73, 2
	ld.w $t0, $fp, -166
	addi.w $t1, $zero, 2
	mul.w $t2, $t0, $t1
	st.w $t2, $fp, -170
# %op75 = mul i32 %op74, 2
	ld.w $t0, $fp, -170
	addi.w $t1, $zero, 2
	mul.w $t2, $t0, $t1
	st.w $t2, $fp, -174
# %op76 = mul i32 %op75, 2
	ld.w $t0, $fp, -174
	addi.w $t1, $zero, 2
	mul.w $t2, $t0, $t1
	st.w $t2, $fp, -178
# %op77 = mul i32 %op76, 2
	ld.w $t0, $fp, -178
	addi.w $t1, $zero, 2
	mul.w $t2, $t0, $t1
	st.w $t2, $fp, -182
# %op78 = mul i32 %op77, 2
	ld.w $t0, $fp, -182
	addi.w $t1, $zero, 2
	mul.w $t2, $t0, $t1
	st.w $t2, $fp, -186
# %op79 = mul i32 %op78, 2
	ld.w $t0, $fp, -186
	addi.w $t1, $zero, 2
	mul.w $t2, $t0, $t1
	st.w $t2, $fp, -190
# %op80 = sdiv i32 %op79, 2
	ld.w $t0, $fp, -190
	addi.w $t1, $zero, 2
	div.w $t2, $t0, $t1
	st.w $t2, $fp, -194
# %op81 = sdiv i32 %op80, 2
	ld.w $t0, $fp, -194
	addi.w $t1, $zero, 2
	div.w $t2, $t0, $t1
	st.w $t2, $fp, -198
# %op82 = sdiv i32 %op81, 2
	ld.w $t0, $fp, -198
	addi.w $t1, $zero, 2
	div.w $t2, $t0, $t1
	st.w $t2, $fp, -202
# %op83 = sdiv i32 %op82, 2
	ld.w $t0, $fp, -202
	addi.w $t1, $zero, 2
	div.w $t2, $t0, $t1
	st.w $t2, $fp, -206
# %op84 = sdiv i32 %op83, 2
	ld.w $t0, $fp, -206
	addi.w $t1, $zero, 2
	div.w $t2, $t0, $t1
	st.w $t2, $fp, -210
# %op85 = sdiv i32 %op84, 2
	ld.w $t0, $fp, -210
	addi.w $t1, $zero, 2
	div.w $t2, $t0, $t1
	st.w $t2, $fp, -214
# %op86 = sdiv i32 %op85, 2
	ld.w $t0, $fp, -214
	addi.w $t1, $zero, 2
	div.w $t2, $t0, $t1
	st.w $t2, $fp, -218
# %op87 = sdiv i32 %op86, 2
	ld.w $t0, $fp, -218
	addi.w $t1, $zero, 2
	div.w $t2, $t0, $t1
	st.w $t2, $fp, -222
# %op88 = sdiv i32 %op87, 2
	ld.w $t0, $fp, -222
	addi.w $t1, $zero, 2
	div.w $t2, $t0, $t1
	st.w $t2, $fp, -226
# %op89 = sdiv i32 %op88, 2
	ld.w $t0, $fp, -226
	addi.w $t1, $zero, 2
	div.w $t2, $t0, $t1
	st.w $t2, $fp, -230
# br label %label0
	addi.w $a0, $zero, 0
	st.w $a0, $fp, -24
	b .main_label0
	addi.d $sp, $sp, 240
	ld.d $ra, $sp, -8
	ld.d $fp, $sp, -16
	jr $ra
