define dso_local i32 @main() #0 {
    %1 = alloca i32
    %2 = alloca i32
    store i32 10, i32* %1
    store i32 0, i32* %2
    br label %loop
loop:    
    %3 = load i32, i32* %2
    %4 = icmp slt i32 %3, 10
    br i1 %4, label %con, label %end
con:
    %5 = add i32 %3, 1
    store i32 %5, i32* %2
    %6 = load i32, i32* %2
    %7 = load i32, i32* %1
    %8 = add i32 %6, %7
    store i32 %8, i32* %1
    br label %loop
end:
    %9 = load i32, i32* %1
    ret i32 %9
}