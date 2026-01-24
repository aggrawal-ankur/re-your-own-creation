; ModuleID = 'dynstr/dynstr.c'
source_filename = "dynstr/dynstr.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

%struct.DynString = type { ptr, i64, i64 }
%struct.kmp_result = type { i64, ptr }

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @init(ptr noundef %0, i64 noundef %1) #0 {
  %3 = alloca i32, align 4
  %4 = alloca ptr, align 8
  %5 = alloca i64, align 8
  store ptr %0, ptr %4, align 8
  store i64 %1, ptr %5, align 8
  %6 = load ptr, ptr %4, align 8
  %7 = getelementptr inbounds %struct.DynString, ptr %6, i32 0, i32 2
  %8 = load i64, ptr %7, align 8
  %9 = icmp ne i64 %8, 0
  br i1 %9, label %10, label %11

10:                                               ; preds = %2
  store i32 -1, ptr %3, align 4
  br label %35

11:                                               ; preds = %2
  %12 = load i64, ptr %5, align 8
  %13 = icmp eq i64 %12, 0
  br i1 %13, label %14, label %15

14:                                               ; preds = %11
  store i32 -2, ptr %3, align 4
  br label %35

15:                                               ; preds = %11
  %16 = load i64, ptr %5, align 8
  %17 = call noalias ptr @malloc(i64 noundef %16) #7
  %18 = load ptr, ptr %4, align 8
  %19 = getelementptr inbounds %struct.DynString, ptr %18, i32 0, i32 0
  store ptr %17, ptr %19, align 8
  %20 = load ptr, ptr %4, align 8
  %21 = getelementptr inbounds %struct.DynString, ptr %20, i32 0, i32 0
  %22 = load ptr, ptr %21, align 8
  %23 = icmp ne ptr %22, null
  br i1 %23, label %25, label %24

24:                                               ; preds = %15
  store i32 -3, ptr %3, align 4
  br label %35

25:                                               ; preds = %15
  %26 = load ptr, ptr %4, align 8
  %27 = getelementptr inbounds %struct.DynString, ptr %26, i32 0, i32 1
  store i64 0, ptr %27, align 8
  %28 = load i64, ptr %5, align 8
  %29 = load ptr, ptr %4, align 8
  %30 = getelementptr inbounds %struct.DynString, ptr %29, i32 0, i32 2
  store i64 %28, ptr %30, align 8
  %31 = load ptr, ptr %4, align 8
  %32 = getelementptr inbounds %struct.DynString, ptr %31, i32 0, i32 0
  %33 = load ptr, ptr %32, align 8
  %34 = getelementptr inbounds i8, ptr %33, i64 0
  store i8 0, ptr %34, align 1
  store i32 0, ptr %3, align 4
  br label %35

35:                                               ; preds = %25, %24, %14, %10
  %36 = load i32, ptr %3, align 4
  ret i32 %36
}

; Function Attrs: nounwind allocsize(0)
declare noalias ptr @malloc(i64 noundef) #1

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @extendCap(ptr noundef %0, i64 noundef %1) #0 {
  %3 = alloca i32, align 4
  %4 = alloca ptr, align 8
  %5 = alloca i64, align 8
  %6 = alloca i64, align 8
  %7 = alloca ptr, align 8
  store ptr %0, ptr %4, align 8
  store i64 %1, ptr %5, align 8
  %8 = load ptr, ptr %4, align 8
  %9 = icmp ne ptr %8, null
  br i1 %9, label %10, label %15

10:                                               ; preds = %2
  %11 = load ptr, ptr %4, align 8
  %12 = getelementptr inbounds %struct.DynString, ptr %11, i32 0, i32 0
  %13 = load ptr, ptr %12, align 8
  %14 = icmp ne ptr %13, null
  br i1 %14, label %16, label %15

15:                                               ; preds = %10, %2
  store i32 -4, ptr %3, align 4
  br label %51

16:                                               ; preds = %10
  %17 = load ptr, ptr %4, align 8
  %18 = getelementptr inbounds %struct.DynString, ptr %17, i32 0, i32 2
  %19 = load i64, ptr %18, align 8
  %20 = load i64, ptr %5, align 8
  %21 = icmp uge i64 %19, %20
  br i1 %21, label %22, label %23

22:                                               ; preds = %16
  store i32 0, ptr %3, align 4
  br label %51

23:                                               ; preds = %16
  %24 = load ptr, ptr %4, align 8
  %25 = getelementptr inbounds %struct.DynString, ptr %24, i32 0, i32 2
  %26 = load i64, ptr %25, align 8
  store i64 %26, ptr %6, align 8
  br label %27

27:                                               ; preds = %32, %23
  %28 = load i64, ptr %6, align 8
  %29 = load i64, ptr %5, align 8
  %30 = add i64 %29, 1
  %31 = icmp ult i64 %28, %30
  br i1 %31, label %32, label %35

32:                                               ; preds = %27
  %33 = load i64, ptr %6, align 8
  %34 = mul i64 %33, 2
  store i64 %34, ptr %6, align 8
  br label %27, !llvm.loop !6

35:                                               ; preds = %27
  %36 = load ptr, ptr %4, align 8
  %37 = getelementptr inbounds %struct.DynString, ptr %36, i32 0, i32 0
  %38 = load ptr, ptr %37, align 8
  %39 = load i64, ptr %6, align 8
  %40 = call ptr @realloc(ptr noundef %38, i64 noundef %39) #8
  store ptr %40, ptr %7, align 8
  %41 = load ptr, ptr %7, align 8
  %42 = icmp ne ptr %41, null
  br i1 %42, label %44, label %43

43:                                               ; preds = %35
  store i32 -5, ptr %3, align 4
  br label %51

44:                                               ; preds = %35
  %45 = load ptr, ptr %7, align 8
  %46 = load ptr, ptr %4, align 8
  %47 = getelementptr inbounds %struct.DynString, ptr %46, i32 0, i32 0
  store ptr %45, ptr %47, align 8
  %48 = load i64, ptr %6, align 8
  %49 = load ptr, ptr %4, align 8
  %50 = getelementptr inbounds %struct.DynString, ptr %49, i32 0, i32 2
  store i64 %48, ptr %50, align 8
  store i32 0, ptr %3, align 4
  br label %51

51:                                               ; preds = %44, %43, %22, %15
  %52 = load i32, ptr %3, align 4
  ret i32 %52
}

; Function Attrs: nounwind allocsize(1)
declare ptr @realloc(ptr noundef, i64 noundef) #2

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @lenstr(ptr noundef %0) #0 {
  %2 = alloca i32, align 4
  %3 = alloca ptr, align 8
  %4 = alloca i32, align 4
  store ptr %0, ptr %3, align 8
  %5 = load ptr, ptr %3, align 8
  %6 = icmp ne ptr %5, null
  br i1 %6, label %8, label %7

7:                                                ; preds = %1
  store i32 -1, ptr %2, align 4
  br label %20

8:                                                ; preds = %1
  store i32 0, ptr %4, align 4
  br label %9

9:                                                ; preds = %15, %8
  %10 = load ptr, ptr %3, align 8
  %11 = getelementptr inbounds i8, ptr %10, i32 1
  store ptr %11, ptr %3, align 8
  %12 = load i8, ptr %10, align 1
  %13 = sext i8 %12 to i32
  %14 = icmp ne i32 %13, 0
  br i1 %14, label %15, label %18

15:                                               ; preds = %9
  %16 = load i32, ptr %4, align 4
  %17 = add nsw i32 %16, 1
  store i32 %17, ptr %4, align 4
  br label %9, !llvm.loop !8

18:                                               ; preds = %9
  %19 = load i32, ptr %4, align 4
  store i32 %19, ptr %2, align 4
  br label %20

20:                                               ; preds = %18, %7
  %21 = load i32, ptr %2, align 4
  ret i32 %21
}

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @populate(ptr noundef %0, ptr noundef %1) #0 {
  %3 = alloca i32, align 4
  %4 = alloca ptr, align 8
  %5 = alloca ptr, align 8
  %6 = alloca i32, align 4
  %7 = alloca i64, align 8
  %8 = alloca i32, align 4
  store ptr %0, ptr %4, align 8
  store ptr %1, ptr %5, align 8
  %9 = load ptr, ptr %4, align 8
  %10 = icmp ne ptr %9, null
  br i1 %10, label %11, label %16

11:                                               ; preds = %2
  %12 = load ptr, ptr %4, align 8
  %13 = getelementptr inbounds %struct.DynString, ptr %12, i32 0, i32 0
  %14 = load ptr, ptr %13, align 8
  %15 = icmp ne ptr %14, null
  br i1 %15, label %17, label %16

16:                                               ; preds = %11, %2
  store i32 -4, ptr %3, align 4
  br label %61

17:                                               ; preds = %11
  %18 = load ptr, ptr %5, align 8
  %19 = icmp ne ptr %18, null
  br i1 %19, label %21, label %20

20:                                               ; preds = %17
  store i32 -6, ptr %3, align 4
  br label %61

21:                                               ; preds = %17
  %22 = load ptr, ptr %5, align 8
  %23 = call i32 @lenstr(ptr noundef %22)
  store i32 %23, ptr %6, align 4
  %24 = load i32, ptr %6, align 4
  %25 = icmp eq i32 %24, -1
  br i1 %25, label %26, label %27

26:                                               ; preds = %21
  store i32 -6, ptr %3, align 4
  br label %61

27:                                               ; preds = %21
  %28 = load ptr, ptr %4, align 8
  %29 = getelementptr inbounds %struct.DynString, ptr %28, i32 0, i32 1
  %30 = load i64, ptr %29, align 8
  %31 = load i32, ptr %6, align 4
  %32 = sext i32 %31 to i64
  %33 = add i64 %30, %32
  store i64 %33, ptr %7, align 8
  %34 = load ptr, ptr %4, align 8
  %35 = load i64, ptr %7, align 8
  %36 = add i64 %35, 1
  %37 = call i32 @extendCap(ptr noundef %34, i64 noundef %36)
  store i32 %37, ptr %8, align 4
  %38 = load i32, ptr %8, align 4
  %39 = icmp ne i32 %38, 0
  br i1 %39, label %40, label %42

40:                                               ; preds = %27
  %41 = load i32, ptr %8, align 4
  store i32 %41, ptr %3, align 4
  br label %61

42:                                               ; preds = %27
  %43 = load ptr, ptr %4, align 8
  %44 = getelementptr inbounds %struct.DynString, ptr %43, i32 0, i32 0
  %45 = load ptr, ptr %44, align 8
  %46 = load ptr, ptr %4, align 8
  %47 = getelementptr inbounds %struct.DynString, ptr %46, i32 0, i32 1
  %48 = load i64, ptr %47, align 8
  %49 = getelementptr inbounds i8, ptr %45, i64 %48
  %50 = load ptr, ptr %5, align 8
  %51 = load i32, ptr %6, align 4
  %52 = sext i32 %51 to i64
  call void @llvm.memcpy.p0.p0.i64(ptr align 1 %49, ptr align 1 %50, i64 %52, i1 false)
  %53 = load i64, ptr %7, align 8
  %54 = load ptr, ptr %4, align 8
  %55 = getelementptr inbounds %struct.DynString, ptr %54, i32 0, i32 1
  store i64 %53, ptr %55, align 8
  %56 = load ptr, ptr %4, align 8
  %57 = getelementptr inbounds %struct.DynString, ptr %56, i32 0, i32 0
  %58 = load ptr, ptr %57, align 8
  %59 = load i64, ptr %7, align 8
  %60 = getelementptr inbounds i8, ptr %58, i64 %59
  store i8 0, ptr %60, align 1
  store i32 0, ptr %3, align 4
  br label %61

61:                                               ; preds = %42, %40, %26, %20, %16
  %62 = load i32, ptr %3, align 4
  ret i32 %62
}

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias nocapture writeonly, ptr noalias nocapture readonly, i64, i1 immarg) #3

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @boundcheck(i64 noundef %0, i64 noundef %1, i64 noundef %2) #0 {
  %4 = alloca i64, align 8
  %5 = alloca i64, align 8
  %6 = alloca i64, align 8
  store i64 %0, ptr %4, align 8
  store i64 %1, ptr %5, align 8
  store i64 %2, ptr %6, align 8
  %7 = load i64, ptr %6, align 8
  %8 = load i64, ptr %4, align 8
  %9 = icmp uge i64 %7, %8
  br i1 %9, label %10, label %14

10:                                               ; preds = %3
  %11 = load i64, ptr %6, align 8
  %12 = load i64, ptr %5, align 8
  %13 = icmp ult i64 %11, %12
  br label %14

14:                                               ; preds = %10, %3
  %15 = phi i1 [ false, %3 ], [ %13, %10 ]
  %16 = zext i1 %15 to i64
  %17 = select i1 %15, i32 0, i32 -7
  ret i32 %17
}

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @getstr(ptr noundef %0, i64 noundef %1, ptr noundef %2) #0 {
  %4 = alloca i32, align 4
  %5 = alloca ptr, align 8
  %6 = alloca i64, align 8
  %7 = alloca ptr, align 8
  store ptr %0, ptr %5, align 8
  store i64 %1, ptr %6, align 8
  store ptr %2, ptr %7, align 8
  %8 = load ptr, ptr %5, align 8
  %9 = icmp ne ptr %8, null
  br i1 %9, label %10, label %15

10:                                               ; preds = %3
  %11 = load ptr, ptr %5, align 8
  %12 = getelementptr inbounds %struct.DynString, ptr %11, i32 0, i32 0
  %13 = load ptr, ptr %12, align 8
  %14 = icmp ne ptr %13, null
  br i1 %14, label %16, label %15

15:                                               ; preds = %10, %3
  store i32 -4, ptr %4, align 4
  br label %31

16:                                               ; preds = %10
  %17 = load ptr, ptr %5, align 8
  %18 = getelementptr inbounds %struct.DynString, ptr %17, i32 0, i32 1
  %19 = load i64, ptr %18, align 8
  %20 = load i64, ptr %6, align 8
  %21 = call i32 @boundcheck(i64 noundef 0, i64 noundef %19, i64 noundef %20)
  %22 = icmp ne i32 %21, 0
  br i1 %22, label %23, label %24

23:                                               ; preds = %16
  store i32 -7, ptr %4, align 4
  br label %31

24:                                               ; preds = %16
  %25 = load ptr, ptr %5, align 8
  %26 = getelementptr inbounds %struct.DynString, ptr %25, i32 0, i32 0
  %27 = load ptr, ptr %26, align 8
  %28 = load i64, ptr %6, align 8
  %29 = getelementptr inbounds i8, ptr %27, i64 %28
  %30 = load ptr, ptr %7, align 8
  store ptr %29, ptr %30, align 8
  store i32 0, ptr %4, align 4
  br label %31

31:                                               ; preds = %24, %23, %15
  %32 = load i32, ptr %4, align 4
  ret i32 %32
}

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @getslicedstr(ptr noundef %0, i64 noundef %1, i64 noundef %2, ptr noundef %3) #0 {
  %5 = alloca i32, align 4
  %6 = alloca ptr, align 8
  %7 = alloca i64, align 8
  %8 = alloca i64, align 8
  %9 = alloca ptr, align 8
  %10 = alloca i64, align 8
  store ptr %0, ptr %6, align 8
  store i64 %1, ptr %7, align 8
  store i64 %2, ptr %8, align 8
  store ptr %3, ptr %9, align 8
  %11 = load ptr, ptr %6, align 8
  %12 = icmp ne ptr %11, null
  br i1 %12, label %13, label %18

13:                                               ; preds = %4
  %14 = load ptr, ptr %6, align 8
  %15 = getelementptr inbounds %struct.DynString, ptr %14, i32 0, i32 0
  %16 = load ptr, ptr %15, align 8
  %17 = icmp ne ptr %16, null
  br i1 %17, label %19, label %18

18:                                               ; preds = %13, %4
  store i32 -4, ptr %5, align 4
  br label %46

19:                                               ; preds = %13
  %20 = load i64, ptr %7, align 8
  %21 = load ptr, ptr %6, align 8
  %22 = getelementptr inbounds %struct.DynString, ptr %21, i32 0, i32 1
  %23 = load i64, ptr %22, align 8
  %24 = icmp uge i64 %20, %23
  br i1 %24, label %31, label %25

25:                                               ; preds = %19
  %26 = load i64, ptr %8, align 8
  %27 = load ptr, ptr %6, align 8
  %28 = getelementptr inbounds %struct.DynString, ptr %27, i32 0, i32 1
  %29 = load i64, ptr %28, align 8
  %30 = icmp uge i64 %26, %29
  br i1 %30, label %31, label %32

31:                                               ; preds = %25, %19
  store i32 -8, ptr %5, align 4
  br label %46

32:                                               ; preds = %25
  %33 = load i64, ptr %8, align 8
  %34 = load i64, ptr %7, align 8
  %35 = sub i64 %33, %34
  store i64 %35, ptr %10, align 8
  %36 = load ptr, ptr %9, align 8
  %37 = load ptr, ptr %6, align 8
  %38 = getelementptr inbounds %struct.DynString, ptr %37, i32 0, i32 0
  %39 = load ptr, ptr %38, align 8
  %40 = load i64, ptr %7, align 8
  %41 = getelementptr inbounds i8, ptr %39, i64 %40
  %42 = load i64, ptr %10, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 1 %36, ptr align 1 %41, i64 %42, i1 false)
  %43 = load ptr, ptr %9, align 8
  %44 = load i64, ptr %10, align 8
  %45 = getelementptr inbounds i8, ptr %43, i64 %44
  store i8 0, ptr %45, align 1
  store i32 0, ptr %5, align 4
  br label %46

46:                                               ; preds = %32, %31, %18
  %47 = load i32, ptr %5, align 4
  ret i32 %47
}

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @copystr(ptr noundef %0, ptr noundef %1) #0 {
  %3 = alloca i32, align 4
  %4 = alloca ptr, align 8
  %5 = alloca ptr, align 8
  %6 = alloca i32, align 4
  store ptr %0, ptr %4, align 8
  store ptr %1, ptr %5, align 8
  %7 = load ptr, ptr %4, align 8
  %8 = icmp ne ptr %7, null
  br i1 %8, label %10, label %9

9:                                                ; preds = %2
  store i32 -6, ptr %3, align 4
  br label %25

10:                                               ; preds = %2
  %11 = load ptr, ptr %4, align 8
  %12 = call i32 @lenstr(ptr noundef %11)
  store i32 %12, ptr %6, align 4
  %13 = load i32, ptr %6, align 4
  %14 = icmp eq i32 %13, -1
  br i1 %14, label %15, label %16

15:                                               ; preds = %10
  store i32 6, ptr %3, align 4
  br label %25

16:                                               ; preds = %10
  %17 = load ptr, ptr %5, align 8
  %18 = load ptr, ptr %4, align 8
  %19 = load i32, ptr %6, align 4
  %20 = sext i32 %19 to i64
  call void @llvm.memcpy.p0.p0.i64(ptr align 1 %17, ptr align 1 %18, i64 %20, i1 false)
  %21 = load ptr, ptr %5, align 8
  %22 = load i32, ptr %6, align 4
  %23 = sext i32 %22 to i64
  %24 = getelementptr inbounds i8, ptr %21, i64 %23
  store i8 0, ptr %24, align 1
  store i32 0, ptr %3, align 4
  br label %25

25:                                               ; preds = %16, %15, %9
  %26 = load i32, ptr %3, align 4
  ret i32 %26
}

; Function Attrs: noinline nounwind optnone uwtable
define dso_local signext i8 @char2lcase(i8 noundef signext %0) #0 {
  %2 = alloca i8, align 1
  %3 = alloca i8, align 1
  store i8 %0, ptr %3, align 1
  %4 = load i8, ptr %3, align 1
  %5 = sext i8 %4 to i32
  %6 = icmp sge i32 %5, 65
  br i1 %6, label %7, label %16

7:                                                ; preds = %1
  %8 = load i8, ptr %3, align 1
  %9 = sext i8 %8 to i32
  %10 = icmp sle i32 %9, 90
  br i1 %10, label %11, label %16

11:                                               ; preds = %7
  %12 = load i8, ptr %3, align 1
  %13 = sext i8 %12 to i32
  %14 = or i32 %13, 32
  %15 = trunc i32 %14 to i8
  store i8 %15, ptr %2, align 1
  br label %18

16:                                               ; preds = %7, %1
  %17 = load i8, ptr %3, align 1
  store i8 %17, ptr %2, align 1
  br label %18

18:                                               ; preds = %16, %11
  %19 = load i8, ptr %2, align 1
  ret i8 %19
}

; Function Attrs: noinline nounwind optnone uwtable
define dso_local signext i8 @char2ucase(i8 noundef signext %0) #0 {
  %2 = alloca i8, align 1
  %3 = alloca i8, align 1
  store i8 %0, ptr %3, align 1
  %4 = load i8, ptr %3, align 1
  %5 = sext i8 %4 to i32
  %6 = icmp sge i32 %5, 97
  br i1 %6, label %7, label %16

7:                                                ; preds = %1
  %8 = load i8, ptr %3, align 1
  %9 = sext i8 %8 to i32
  %10 = icmp sle i32 %9, 122
  br i1 %10, label %11, label %16

11:                                               ; preds = %7
  %12 = load i8, ptr %3, align 1
  %13 = sext i8 %12 to i32
  %14 = and i32 %13, -33
  %15 = trunc i32 %14 to i8
  store i8 %15, ptr %2, align 1
  br label %18

16:                                               ; preds = %7, %1
  %17 = load i8, ptr %3, align 1
  store i8 %17, ptr %2, align 1
  br label %18

18:                                               ; preds = %16, %11
  %19 = load i8, ptr %2, align 1
  ret i8 %19
}

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @islcase(ptr noundef %0) #0 {
  %2 = alloca i32, align 4
  %3 = alloca ptr, align 8
  %4 = alloca i64, align 8
  store ptr %0, ptr %3, align 8
  %5 = load ptr, ptr %3, align 8
  %6 = icmp ne ptr %5, null
  br i1 %6, label %8, label %7

7:                                                ; preds = %1
  store i32 -6, ptr %2, align 4
  br label %36

8:                                                ; preds = %1
  store i64 0, ptr %4, align 8
  br label %9

9:                                                ; preds = %32, %8
  %10 = load ptr, ptr %3, align 8
  %11 = load i64, ptr %4, align 8
  %12 = getelementptr inbounds i8, ptr %10, i64 %11
  %13 = load i8, ptr %12, align 1
  %14 = sext i8 %13 to i32
  %15 = icmp ne i32 %14, 0
  br i1 %15, label %16, label %35

16:                                               ; preds = %9
  %17 = load ptr, ptr %3, align 8
  %18 = load i64, ptr %4, align 8
  %19 = getelementptr inbounds i8, ptr %17, i64 %18
  %20 = load i8, ptr %19, align 1
  %21 = sext i8 %20 to i32
  %22 = icmp sge i32 %21, 65
  br i1 %22, label %23, label %31

23:                                               ; preds = %16
  %24 = load ptr, ptr %3, align 8
  %25 = load i64, ptr %4, align 8
  %26 = getelementptr inbounds i8, ptr %24, i64 %25
  %27 = load i8, ptr %26, align 1
  %28 = sext i8 %27 to i32
  %29 = icmp sle i32 %28, 90
  br i1 %29, label %30, label %31

30:                                               ; preds = %23
  store i32 -9, ptr %2, align 4
  br label %36

31:                                               ; preds = %23, %16
  br label %32

32:                                               ; preds = %31
  %33 = load i64, ptr %4, align 8
  %34 = add i64 %33, 1
  store i64 %34, ptr %4, align 8
  br label %9, !llvm.loop !9

35:                                               ; preds = %9
  store i32 0, ptr %2, align 4
  br label %36

36:                                               ; preds = %35, %30, %7
  %37 = load i32, ptr %2, align 4
  ret i32 %37
}

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @isucase(ptr noundef %0) #0 {
  %2 = alloca i32, align 4
  %3 = alloca ptr, align 8
  %4 = alloca i64, align 8
  store ptr %0, ptr %3, align 8
  %5 = load ptr, ptr %3, align 8
  %6 = icmp ne ptr %5, null
  br i1 %6, label %8, label %7

7:                                                ; preds = %1
  store i32 -6, ptr %2, align 4
  br label %36

8:                                                ; preds = %1
  store i64 0, ptr %4, align 8
  br label %9

9:                                                ; preds = %32, %8
  %10 = load ptr, ptr %3, align 8
  %11 = load i64, ptr %4, align 8
  %12 = getelementptr inbounds i8, ptr %10, i64 %11
  %13 = load i8, ptr %12, align 1
  %14 = sext i8 %13 to i32
  %15 = icmp ne i32 %14, 0
  br i1 %15, label %16, label %35

16:                                               ; preds = %9
  %17 = load ptr, ptr %3, align 8
  %18 = load i64, ptr %4, align 8
  %19 = getelementptr inbounds i8, ptr %17, i64 %18
  %20 = load i8, ptr %19, align 1
  %21 = sext i8 %20 to i32
  %22 = icmp sge i32 %21, 97
  br i1 %22, label %23, label %31

23:                                               ; preds = %16
  %24 = load ptr, ptr %3, align 8
  %25 = load i64, ptr %4, align 8
  %26 = getelementptr inbounds i8, ptr %24, i64 %25
  %27 = load i8, ptr %26, align 1
  %28 = sext i8 %27 to i32
  %29 = icmp sle i32 %28, 122
  br i1 %29, label %30, label %31

30:                                               ; preds = %23
  store i32 -10, ptr %2, align 4
  br label %36

31:                                               ; preds = %23, %16
  br label %32

32:                                               ; preds = %31
  %33 = load i64, ptr %4, align 8
  %34 = add i64 %33, 1
  store i64 %34, ptr %4, align 8
  br label %9, !llvm.loop !10

35:                                               ; preds = %9
  store i32 0, ptr %2, align 4
  br label %36

36:                                               ; preds = %35, %30, %7
  %37 = load i32, ptr %2, align 4
  ret i32 %37
}

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @tolcase(ptr noundef %0, ptr noundef %1) #0 {
  %3 = alloca i32, align 4
  %4 = alloca ptr, align 8
  %5 = alloca ptr, align 8
  %6 = alloca i32, align 4
  %7 = alloca i32, align 4
  store ptr %0, ptr %4, align 8
  store ptr %1, ptr %5, align 8
  %8 = load ptr, ptr %4, align 8
  %9 = icmp ne ptr %8, null
  br i1 %9, label %11, label %10

10:                                               ; preds = %2
  store i32 -6, ptr %3, align 4
  br label %47

11:                                               ; preds = %2
  %12 = load ptr, ptr %4, align 8
  %13 = load ptr, ptr %5, align 8
  %14 = call i32 @copystr(ptr noundef %12, ptr noundef %13)
  store i32 %14, ptr %6, align 4
  %15 = load i32, ptr %6, align 4
  %16 = icmp ne i32 %15, 0
  br i1 %16, label %17, label %19

17:                                               ; preds = %11
  %18 = load i32, ptr %6, align 4
  store i32 %18, ptr %3, align 4
  br label %47

19:                                               ; preds = %11
  store i32 0, ptr %7, align 4
  br label %20

20:                                               ; preds = %28, %19
  %21 = load ptr, ptr %5, align 8
  %22 = load i32, ptr %7, align 4
  %23 = sext i32 %22 to i64
  %24 = getelementptr inbounds i8, ptr %21, i64 %23
  %25 = load i8, ptr %24, align 1
  %26 = sext i8 %25 to i32
  %27 = icmp ne i32 %26, 0
  br i1 %27, label %28, label %41

28:                                               ; preds = %20
  %29 = load ptr, ptr %5, align 8
  %30 = load i32, ptr %7, align 4
  %31 = sext i32 %30 to i64
  %32 = getelementptr inbounds i8, ptr %29, i64 %31
  %33 = load i8, ptr %32, align 1
  %34 = call signext i8 @char2lcase(i8 noundef signext %33)
  %35 = load ptr, ptr %5, align 8
  %36 = load i32, ptr %7, align 4
  %37 = sext i32 %36 to i64
  %38 = getelementptr inbounds i8, ptr %35, i64 %37
  store i8 %34, ptr %38, align 1
  %39 = load i32, ptr %7, align 4
  %40 = add nsw i32 %39, 1
  store i32 %40, ptr %7, align 4
  br label %20, !llvm.loop !11

41:                                               ; preds = %20
  %42 = load ptr, ptr %5, align 8
  %43 = call i32 @islcase(ptr noundef %42)
  %44 = icmp eq i32 %43, 0
  br i1 %44, label %45, label %46

45:                                               ; preds = %41
  store i32 0, ptr %3, align 4
  br label %47

46:                                               ; preds = %41
  store i32 -11, ptr %3, align 4
  br label %47

47:                                               ; preds = %46, %45, %17, %10
  %48 = load i32, ptr %3, align 4
  ret i32 %48
}

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @toucase(ptr noundef %0, ptr noundef %1) #0 {
  %3 = alloca i32, align 4
  %4 = alloca ptr, align 8
  %5 = alloca ptr, align 8
  %6 = alloca i32, align 4
  %7 = alloca i32, align 4
  store ptr %0, ptr %4, align 8
  store ptr %1, ptr %5, align 8
  %8 = load ptr, ptr %4, align 8
  %9 = icmp ne ptr %8, null
  br i1 %9, label %11, label %10

10:                                               ; preds = %2
  store i32 -6, ptr %3, align 4
  br label %51

11:                                               ; preds = %2
  %12 = load ptr, ptr %4, align 8
  %13 = load ptr, ptr %5, align 8
  %14 = call i32 @copystr(ptr noundef %12, ptr noundef %13)
  store i32 %14, ptr %6, align 4
  %15 = load i32, ptr %6, align 4
  %16 = icmp ne i32 %15, 0
  br i1 %16, label %17, label %19

17:                                               ; preds = %11
  %18 = load i32, ptr %6, align 4
  store i32 %18, ptr %3, align 4
  br label %51

19:                                               ; preds = %11
  store i32 0, ptr %7, align 4
  br label %20

20:                                               ; preds = %28, %19
  %21 = load ptr, ptr %5, align 8
  %22 = load i32, ptr %7, align 4
  %23 = sext i32 %22 to i64
  %24 = getelementptr inbounds i8, ptr %21, i64 %23
  %25 = load i8, ptr %24, align 1
  %26 = sext i8 %25 to i32
  %27 = icmp ne i32 %26, 0
  br i1 %27, label %28, label %41

28:                                               ; preds = %20
  %29 = load ptr, ptr %5, align 8
  %30 = load i32, ptr %7, align 4
  %31 = sext i32 %30 to i64
  %32 = getelementptr inbounds i8, ptr %29, i64 %31
  %33 = load i8, ptr %32, align 1
  %34 = call signext i8 @char2ucase(i8 noundef signext %33)
  %35 = load ptr, ptr %5, align 8
  %36 = load i32, ptr %7, align 4
  %37 = sext i32 %36 to i64
  %38 = getelementptr inbounds i8, ptr %35, i64 %37
  store i8 %34, ptr %38, align 1
  %39 = load i32, ptr %7, align 4
  %40 = add nsw i32 %39, 1
  store i32 %40, ptr %7, align 4
  br label %20, !llvm.loop !12

41:                                               ; preds = %20
  %42 = load ptr, ptr %5, align 8
  %43 = load i32, ptr %7, align 4
  %44 = sext i32 %43 to i64
  %45 = getelementptr inbounds i8, ptr %42, i64 %44
  store i8 0, ptr %45, align 1
  %46 = load ptr, ptr %5, align 8
  %47 = call i32 @isucase(ptr noundef %46)
  %48 = icmp eq i32 %47, 0
  br i1 %48, label %49, label %50

49:                                               ; preds = %41
  store i32 0, ptr %3, align 4
  br label %51

50:                                               ; preds = %41
  store i32 -12, ptr %3, align 4
  br label %51

51:                                               ; preds = %50, %49, %17, %10
  %52 = load i32, ptr %3, align 4
  ret i32 %52
}

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @cmp2strs(ptr noundef %0, ptr noundef %1, i32 noundef %2) #0 {
  %4 = alloca i32, align 4
  %5 = alloca ptr, align 8
  %6 = alloca ptr, align 8
  %7 = alloca i32, align 4
  %8 = alloca i32, align 4
  %9 = alloca ptr, align 8
  %10 = alloca i64, align 8
  %11 = alloca i64, align 8
  %12 = alloca i32, align 4
  store ptr %0, ptr %5, align 8
  store ptr %1, ptr %6, align 8
  store i32 %2, ptr %7, align 4
  %13 = load ptr, ptr %5, align 8
  %14 = icmp ne ptr %13, null
  br i1 %14, label %15, label %28

15:                                               ; preds = %3
  %16 = load ptr, ptr %5, align 8
  %17 = getelementptr inbounds %struct.DynString, ptr %16, i32 0, i32 0
  %18 = load ptr, ptr %17, align 8
  %19 = icmp ne ptr %18, null
  br i1 %19, label %20, label %28

20:                                               ; preds = %15
  %21 = load ptr, ptr %6, align 8
  %22 = getelementptr inbounds %struct.DynString, ptr %21, i32 0, i32 0
  %23 = load ptr, ptr %22, align 8
  %24 = icmp ne ptr %23, null
  br i1 %24, label %25, label %28

25:                                               ; preds = %20
  %26 = load ptr, ptr %6, align 8
  %27 = icmp ne ptr %26, null
  br i1 %27, label %29, label %28

28:                                               ; preds = %25, %20, %15, %3
  store i32 -4, ptr %4, align 4
  br label %91

29:                                               ; preds = %25
  %30 = load ptr, ptr %5, align 8
  %31 = getelementptr inbounds %struct.DynString, ptr %30, i32 0, i32 1
  %32 = load i64, ptr %31, align 8
  %33 = load ptr, ptr %6, align 8
  %34 = getelementptr inbounds %struct.DynString, ptr %33, i32 0, i32 1
  %35 = load i64, ptr %34, align 8
  %36 = icmp ne i64 %32, %35
  br i1 %36, label %37, label %38

37:                                               ; preds = %29
  store i32 -13, ptr %4, align 4
  br label %91

38:                                               ; preds = %29
  %39 = load i32, ptr %7, align 4
  %40 = icmp eq i32 %39, 0
  br i1 %40, label %41, label %56

41:                                               ; preds = %38
  %42 = load ptr, ptr %5, align 8
  %43 = getelementptr inbounds %struct.DynString, ptr %42, i32 0, i32 0
  %44 = load ptr, ptr %43, align 8
  %45 = load ptr, ptr %6, align 8
  %46 = getelementptr inbounds %struct.DynString, ptr %45, i32 0, i32 0
  %47 = load ptr, ptr %46, align 8
  %48 = load ptr, ptr %5, align 8
  %49 = getelementptr inbounds %struct.DynString, ptr %48, i32 0, i32 1
  %50 = load i64, ptr %49, align 8
  %51 = call i32 @memcmp(ptr noundef %44, ptr noundef %47, i64 noundef %50) #9
  store i32 %51, ptr %8, align 4
  %52 = load i32, ptr %8, align 4
  %53 = icmp eq i32 %52, 0
  br i1 %53, label %54, label %55

54:                                               ; preds = %41
  store i32 0, ptr %4, align 4
  br label %91

55:                                               ; preds = %41
  store i32 -13, ptr %4, align 4
  br label %91

56:                                               ; preds = %38
  %57 = load ptr, ptr %5, align 8
  %58 = getelementptr inbounds %struct.DynString, ptr %57, i32 0, i32 1
  %59 = load i64, ptr %58, align 8
  %60 = add i64 %59, 1
  %61 = call ptr @llvm.stacksave.p0()
  store ptr %61, ptr %9, align 8
  %62 = alloca i8, i64 %60, align 16
  store i64 %60, ptr %10, align 8
  %63 = load ptr, ptr %6, align 8
  %64 = getelementptr inbounds %struct.DynString, ptr %63, i32 0, i32 1
  %65 = load i64, ptr %64, align 8
  %66 = add i64 %65, 1
  %67 = alloca i8, i64 %66, align 16
  store i64 %66, ptr %11, align 8
  %68 = load ptr, ptr %5, align 8
  %69 = getelementptr inbounds %struct.DynString, ptr %68, i32 0, i32 0
  %70 = load ptr, ptr %69, align 8
  %71 = call i32 @tolcase(ptr noundef %70, ptr noundef %62)
  %72 = icmp ne i32 %71, 0
  br i1 %72, label %73, label %74

73:                                               ; preds = %56
  store i32 -14, ptr %4, align 4
  store i32 1, ptr %12, align 4
  br label %89

74:                                               ; preds = %56
  %75 = load ptr, ptr %6, align 8
  %76 = getelementptr inbounds %struct.DynString, ptr %75, i32 0, i32 0
  %77 = load ptr, ptr %76, align 8
  %78 = call i32 @tolcase(ptr noundef %77, ptr noundef %67)
  %79 = icmp ne i32 %78, 0
  br i1 %79, label %80, label %81

80:                                               ; preds = %74
  store i32 -14, ptr %4, align 4
  store i32 1, ptr %12, align 4
  br label %89

81:                                               ; preds = %74
  %82 = load ptr, ptr %5, align 8
  %83 = getelementptr inbounds %struct.DynString, ptr %82, i32 0, i32 1
  %84 = load i64, ptr %83, align 8
  %85 = call i32 @memcmp(ptr noundef %62, ptr noundef %67, i64 noundef %84) #9
  %86 = icmp eq i32 %85, 0
  br i1 %86, label %87, label %88

87:                                               ; preds = %81
  store i32 0, ptr %4, align 4
  store i32 1, ptr %12, align 4
  br label %89

88:                                               ; preds = %81
  store i32 -13, ptr %4, align 4
  store i32 1, ptr %12, align 4
  br label %89

89:                                               ; preds = %88, %87, %80, %73
  %90 = load ptr, ptr %9, align 8
  call void @llvm.stackrestore.p0(ptr %90)
  br label %91

91:                                               ; preds = %89, %55, %54, %37, %28
  %92 = load i32, ptr %4, align 4
  ret i32 %92
}

; Function Attrs: nounwind willreturn memory(read)
declare i32 @memcmp(ptr noundef, ptr noundef, i64 noundef) #4

; Function Attrs: nocallback nofree nosync nounwind willreturn
declare ptr @llvm.stacksave.p0() #5

; Function Attrs: nocallback nofree nosync nounwind willreturn
declare void @llvm.stackrestore.p0(ptr) #5

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @findchar(ptr noundef %0, i8 noundef signext %1, i32 noundef %2, ptr noundef %3) #0 {
  %5 = alloca i32, align 4
  %6 = alloca ptr, align 8
  %7 = alloca i8, align 1
  %8 = alloca i32, align 4
  %9 = alloca ptr, align 8
  %10 = alloca i32, align 4
  %11 = alloca i32, align 4
  %12 = alloca i32, align 4
  store ptr %0, ptr %6, align 8
  store i8 %1, ptr %7, align 1
  store i32 %2, ptr %8, align 4
  store ptr %3, ptr %9, align 8
  %13 = load ptr, ptr %6, align 8
  %14 = icmp ne ptr %13, null
  br i1 %14, label %16, label %15

15:                                               ; preds = %4
  store i32 -6, ptr %5, align 4
  br label %82

16:                                               ; preds = %4
  store i32 0, ptr %10, align 4
  %17 = load i32, ptr %8, align 4
  %18 = icmp ne i32 %17, 0
  br i1 %18, label %19, label %48

19:                                               ; preds = %16
  store i32 0, ptr %11, align 4
  br label %20

20:                                               ; preds = %44, %19
  %21 = load ptr, ptr %6, align 8
  %22 = load i32, ptr %11, align 4
  %23 = sext i32 %22 to i64
  %24 = getelementptr inbounds i8, ptr %21, i64 %23
  %25 = load i8, ptr %24, align 1
  %26 = sext i8 %25 to i32
  %27 = icmp ne i32 %26, 0
  br i1 %27, label %28, label %47

28:                                               ; preds = %20
  %29 = load ptr, ptr %6, align 8
  %30 = load i32, ptr %11, align 4
  %31 = sext i32 %30 to i64
  %32 = getelementptr inbounds i8, ptr %29, i64 %31
  %33 = load i8, ptr %32, align 1
  %34 = call signext i8 @char2lcase(i8 noundef signext %33)
  %35 = sext i8 %34 to i32
  %36 = load i8, ptr %7, align 1
  %37 = call signext i8 @char2lcase(i8 noundef signext %36)
  %38 = sext i8 %37 to i32
  %39 = icmp eq i32 %35, %38
  br i1 %39, label %40, label %43

40:                                               ; preds = %28
  %41 = load i32, ptr %10, align 4
  %42 = add nsw i32 %41, 1
  store i32 %42, ptr %10, align 4
  br label %43

43:                                               ; preds = %40, %28
  br label %44

44:                                               ; preds = %43
  %45 = load i32, ptr %11, align 4
  %46 = add nsw i32 %45, 1
  store i32 %46, ptr %11, align 4
  br label %20, !llvm.loop !13

47:                                               ; preds = %20
  br label %75

48:                                               ; preds = %16
  store i32 0, ptr %12, align 4
  br label %49

49:                                               ; preds = %71, %48
  %50 = load ptr, ptr %6, align 8
  %51 = load i32, ptr %12, align 4
  %52 = sext i32 %51 to i64
  %53 = getelementptr inbounds i8, ptr %50, i64 %52
  %54 = load i8, ptr %53, align 1
  %55 = sext i8 %54 to i32
  %56 = icmp ne i32 %55, 0
  br i1 %56, label %57, label %74

57:                                               ; preds = %49
  %58 = load ptr, ptr %6, align 8
  %59 = load i32, ptr %12, align 4
  %60 = sext i32 %59 to i64
  %61 = getelementptr inbounds i8, ptr %58, i64 %60
  %62 = load i8, ptr %61, align 1
  %63 = sext i8 %62 to i32
  %64 = load i8, ptr %7, align 1
  %65 = sext i8 %64 to i32
  %66 = icmp eq i32 %63, %65
  br i1 %66, label %67, label %70

67:                                               ; preds = %57
  %68 = load i32, ptr %10, align 4
  %69 = add nsw i32 %68, 1
  store i32 %69, ptr %10, align 4
  br label %70

70:                                               ; preds = %67, %57
  br label %71

71:                                               ; preds = %70
  %72 = load i32, ptr %12, align 4
  %73 = add nsw i32 %72, 1
  store i32 %73, ptr %12, align 4
  br label %49, !llvm.loop !14

74:                                               ; preds = %49
  br label %75

75:                                               ; preds = %74, %47
  %76 = load i32, ptr %10, align 4
  %77 = icmp ne i32 %76, 0
  br i1 %77, label %79, label %78

78:                                               ; preds = %75
  store i32 17, ptr %5, align 4
  br label %82

79:                                               ; preds = %75
  %80 = load i32, ptr %10, align 4
  %81 = load ptr, ptr %9, align 8
  store i32 %80, ptr %81, align 4
  store i32 0, ptr %5, align 4
  br label %82

82:                                               ; preds = %79, %78, %15
  %83 = load i32, ptr %5, align 4
  ret i32 %83
}

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @clearStr(ptr noundef %0) #0 {
  %2 = alloca i32, align 4
  %3 = alloca ptr, align 8
  store ptr %0, ptr %3, align 8
  %4 = load ptr, ptr %3, align 8
  %5 = icmp ne ptr %4, null
  br i1 %5, label %6, label %11

6:                                                ; preds = %1
  %7 = load ptr, ptr %3, align 8
  %8 = getelementptr inbounds %struct.DynString, ptr %7, i32 0, i32 0
  %9 = load ptr, ptr %8, align 8
  %10 = icmp ne ptr %9, null
  br i1 %10, label %12, label %11

11:                                               ; preds = %6, %1
  store i32 -4, ptr %2, align 4
  br label %25

12:                                               ; preds = %6
  %13 = load ptr, ptr %3, align 8
  %14 = getelementptr inbounds %struct.DynString, ptr %13, i32 0, i32 1
  store i64 0, ptr %14, align 8
  %15 = load ptr, ptr %3, align 8
  %16 = getelementptr inbounds %struct.DynString, ptr %15, i32 0, i32 0
  %17 = load ptr, ptr %16, align 8
  %18 = icmp ne ptr %17, null
  br i1 %18, label %19, label %24

19:                                               ; preds = %12
  %20 = load ptr, ptr %3, align 8
  %21 = getelementptr inbounds %struct.DynString, ptr %20, i32 0, i32 0
  %22 = load ptr, ptr %21, align 8
  %23 = getelementptr inbounds i8, ptr %22, i64 0
  store i8 0, ptr %23, align 1
  br label %24

24:                                               ; preds = %19, %12
  store i32 0, ptr %2, align 4
  br label %25

25:                                               ; preds = %24, %11
  %26 = load i32, ptr %2, align 4
  ret i32 %26
}

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @freeStr(ptr noundef %0) #0 {
  %2 = alloca i32, align 4
  %3 = alloca ptr, align 8
  store ptr %0, ptr %3, align 8
  %4 = load ptr, ptr %3, align 8
  %5 = icmp ne ptr %4, null
  br i1 %5, label %6, label %11

6:                                                ; preds = %1
  %7 = load ptr, ptr %3, align 8
  %8 = getelementptr inbounds %struct.DynString, ptr %7, i32 0, i32 0
  %9 = load ptr, ptr %8, align 8
  %10 = icmp ne ptr %9, null
  br i1 %10, label %12, label %11

11:                                               ; preds = %6, %1
  store i32 -4, ptr %2, align 4
  br label %20

12:                                               ; preds = %6
  %13 = load ptr, ptr %3, align 8
  %14 = getelementptr inbounds %struct.DynString, ptr %13, i32 0, i32 0
  %15 = load ptr, ptr %14, align 8
  call void @free(ptr noundef %15) #10
  %16 = load ptr, ptr %3, align 8
  %17 = getelementptr inbounds %struct.DynString, ptr %16, i32 0, i32 2
  store i64 0, ptr %17, align 8
  %18 = load ptr, ptr %3, align 8
  %19 = getelementptr inbounds %struct.DynString, ptr %18, i32 0, i32 1
  store i64 0, ptr %19, align 8
  store i32 0, ptr %2, align 4
  br label %20

20:                                               ; preds = %12, %11
  %21 = load i32, ptr %2, align 4
  ret i32 %21
}

; Function Attrs: nounwind
declare void @free(ptr noundef) #6

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @kmp_search(ptr noundef %0, ptr noundef %1, ptr noundef %2) #0 {
  %4 = alloca i32, align 4
  %5 = alloca ptr, align 8
  %6 = alloca ptr, align 8
  %7 = alloca ptr, align 8
  %8 = alloca i32, align 4
  %9 = alloca i32, align 4
  %10 = alloca ptr, align 8
  %11 = alloca i64, align 8
  %12 = alloca i32, align 4
  %13 = alloca i32, align 4
  %14 = alloca i64, align 8
  %15 = alloca i64, align 8
  %16 = alloca i64, align 8
  store ptr %0, ptr %5, align 8
  store ptr %1, ptr %6, align 8
  store ptr %2, ptr %7, align 8
  %17 = load ptr, ptr %5, align 8
  %18 = icmp ne ptr %17, null
  br i1 %18, label %19, label %22

19:                                               ; preds = %3
  %20 = load ptr, ptr %6, align 8
  %21 = icmp ne ptr %20, null
  br i1 %21, label %23, label %22

22:                                               ; preds = %19, %3
  store i32 -6, ptr %4, align 4
  br label %122

23:                                               ; preds = %19
  %24 = load ptr, ptr %5, align 8
  %25 = call i32 @lenstr(ptr noundef %24)
  store i32 %25, ptr %8, align 4
  %26 = load ptr, ptr %6, align 8
  %27 = call i32 @lenstr(ptr noundef %26)
  store i32 %27, ptr %9, align 4
  %28 = load i32, ptr %9, align 4
  %29 = icmp eq i32 %28, -1
  br i1 %29, label %37, label %30

30:                                               ; preds = %23
  %31 = load i32, ptr %8, align 4
  %32 = icmp eq i32 %31, -1
  br i1 %32, label %37, label %33

33:                                               ; preds = %30
  %34 = load i32, ptr %9, align 4
  %35 = load i32, ptr %8, align 4
  %36 = icmp sgt i32 %34, %35
  br i1 %36, label %37, label %38

37:                                               ; preds = %33, %30, %23
  store i32 -6, ptr %4, align 4
  br label %122

38:                                               ; preds = %33
  %39 = load i32, ptr %9, align 4
  %40 = zext i32 %39 to i64
  %41 = call ptr @llvm.stacksave.p0()
  store ptr %41, ptr %10, align 8
  %42 = alloca i64, i64 %40, align 16
  store i64 %40, ptr %11, align 8
  %43 = load ptr, ptr %6, align 8
  %44 = load i32, ptr %9, align 4
  %45 = sext i32 %44 to i64
  %46 = call i32 @kmp_build_lps(ptr noundef %43, i64 noundef %45, ptr noundef %42)
  store i32 %46, ptr %12, align 4
  %47 = load i32, ptr %12, align 4
  %48 = icmp ne i32 %47, 0
  br i1 %48, label %49, label %51

49:                                               ; preds = %38
  %50 = load i32, ptr %12, align 4
  store i32 %50, ptr %4, align 4
  store i32 1, ptr %13, align 4
  br label %120

51:                                               ; preds = %38
  store i64 0, ptr %14, align 8
  store i64 0, ptr %15, align 8
  store i64 0, ptr %16, align 8
  br label %52

52:                                               ; preds = %107, %51
  %53 = load i64, ptr %14, align 8
  %54 = load i32, ptr %8, align 4
  %55 = sext i32 %54 to i64
  %56 = icmp ult i64 %53, %55
  br i1 %56, label %57, label %108

57:                                               ; preds = %52
  %58 = load ptr, ptr %5, align 8
  %59 = load i64, ptr %14, align 8
  %60 = getelementptr inbounds i8, ptr %58, i64 %59
  %61 = load i8, ptr %60, align 1
  %62 = sext i8 %61 to i32
  %63 = load ptr, ptr %6, align 8
  %64 = load i64, ptr %15, align 8
  %65 = getelementptr inbounds i8, ptr %63, i64 %64
  %66 = load i8, ptr %65, align 1
  %67 = sext i8 %66 to i32
  %68 = icmp eq i32 %62, %67
  br i1 %68, label %69, label %95

69:                                               ; preds = %57
  %70 = load i64, ptr %14, align 8
  %71 = add i64 %70, 1
  store i64 %71, ptr %14, align 8
  %72 = load i64, ptr %15, align 8
  %73 = add i64 %72, 1
  store i64 %73, ptr %15, align 8
  %74 = load i64, ptr %15, align 8
  %75 = load i32, ptr %9, align 4
  %76 = sext i32 %75 to i64
  %77 = icmp eq i64 %74, %76
  br i1 %77, label %78, label %94

78:                                               ; preds = %69
  %79 = load i64, ptr %14, align 8
  %80 = load i64, ptr %15, align 8
  %81 = sub i64 %79, %80
  %82 = load ptr, ptr %7, align 8
  %83 = getelementptr inbounds %struct.kmp_result, ptr %82, i32 0, i32 1
  %84 = load ptr, ptr %83, align 8
  %85 = load i64, ptr %16, align 8
  %86 = getelementptr inbounds i64, ptr %84, i64 %85
  store i64 %81, ptr %86, align 8
  %87 = load i64, ptr %16, align 8
  %88 = add i64 %87, 1
  store i64 %88, ptr %16, align 8
  %89 = load i32, ptr %9, align 4
  %90 = sub nsw i32 %89, 1
  %91 = sext i32 %90 to i64
  %92 = getelementptr inbounds i64, ptr %42, i64 %91
  %93 = load i64, ptr %92, align 8
  store i64 %93, ptr %15, align 8
  br label %94

94:                                               ; preds = %78, %69
  br label %107

95:                                               ; preds = %57
  %96 = load i64, ptr %15, align 8
  %97 = icmp ne i64 %96, 0
  br i1 %97, label %98, label %103

98:                                               ; preds = %95
  %99 = load i64, ptr %15, align 8
  %100 = sub i64 %99, 1
  %101 = getelementptr inbounds i64, ptr %42, i64 %100
  %102 = load i64, ptr %101, align 8
  store i64 %102, ptr %15, align 8
  br label %106

103:                                              ; preds = %95
  %104 = load i64, ptr %14, align 8
  %105 = add i64 %104, 1
  store i64 %105, ptr %14, align 8
  br label %106

106:                                              ; preds = %103, %98
  br label %107

107:                                              ; preds = %106, %94
  br label %52, !llvm.loop !15

108:                                              ; preds = %52
  %109 = load i64, ptr %16, align 8
  %110 = icmp ne i64 %109, 0
  br i1 %110, label %116, label %111

111:                                              ; preds = %108
  %112 = load ptr, ptr %7, align 8
  %113 = getelementptr inbounds %struct.kmp_result, ptr %112, i32 0, i32 1
  store ptr null, ptr %113, align 8
  %114 = load ptr, ptr %7, align 8
  %115 = getelementptr inbounds %struct.kmp_result, ptr %114, i32 0, i32 0
  store i64 0, ptr %115, align 8
  store i32 -16, ptr %4, align 4
  store i32 1, ptr %13, align 4
  br label %120

116:                                              ; preds = %108
  %117 = load i64, ptr %16, align 8
  %118 = load ptr, ptr %7, align 8
  %119 = getelementptr inbounds %struct.kmp_result, ptr %118, i32 0, i32 0
  store i64 %117, ptr %119, align 8
  store i32 0, ptr %4, align 4
  store i32 1, ptr %13, align 4
  br label %120

120:                                              ; preds = %116, %111, %49
  %121 = load ptr, ptr %10, align 8
  call void @llvm.stackrestore.p0(ptr %121)
  br label %122

122:                                              ; preds = %120, %37, %22
  %123 = load i32, ptr %4, align 4
  ret i32 %123
}

; Function Attrs: noinline nounwind optnone uwtable
define internal i32 @kmp_build_lps(ptr noundef %0, i64 noundef %1, ptr noundef %2) #0 {
  %4 = alloca i32, align 4
  %5 = alloca ptr, align 8
  %6 = alloca i64, align 8
  %7 = alloca ptr, align 8
  %8 = alloca i64, align 8
  %9 = alloca i64, align 8
  store ptr %0, ptr %5, align 8
  store i64 %1, ptr %6, align 8
  store ptr %2, ptr %7, align 8
  %10 = load ptr, ptr %5, align 8
  %11 = icmp ne ptr %10, null
  br i1 %11, label %12, label %15

12:                                               ; preds = %3
  %13 = load i64, ptr %6, align 8
  %14 = icmp eq i64 %13, 0
  br i1 %14, label %15, label %16

15:                                               ; preds = %12, %3
  store i32 -6, ptr %4, align 4
  br label %62

16:                                               ; preds = %12
  store i64 0, ptr %8, align 8
  %17 = load ptr, ptr %7, align 8
  %18 = getelementptr inbounds i64, ptr %17, i64 0
  store i64 0, ptr %18, align 8
  store i64 1, ptr %9, align 8
  br label %19

19:                                               ; preds = %60, %16
  %20 = load i64, ptr %9, align 8
  %21 = load i64, ptr %6, align 8
  %22 = icmp ult i64 %20, %21
  br i1 %22, label %23, label %61

23:                                               ; preds = %19
  %24 = load ptr, ptr %5, align 8
  %25 = load i64, ptr %9, align 8
  %26 = getelementptr inbounds i8, ptr %24, i64 %25
  %27 = load i8, ptr %26, align 1
  %28 = sext i8 %27 to i32
  %29 = load ptr, ptr %5, align 8
  %30 = load i64, ptr %8, align 8
  %31 = getelementptr inbounds i8, ptr %29, i64 %30
  %32 = load i8, ptr %31, align 1
  %33 = sext i8 %32 to i32
  %34 = icmp eq i32 %28, %33
  br i1 %34, label %35, label %44

35:                                               ; preds = %23
  %36 = load i64, ptr %8, align 8
  %37 = add i64 %36, 1
  store i64 %37, ptr %8, align 8
  %38 = load i64, ptr %8, align 8
  %39 = load ptr, ptr %7, align 8
  %40 = load i64, ptr %9, align 8
  %41 = getelementptr inbounds i64, ptr %39, i64 %40
  store i64 %38, ptr %41, align 8
  %42 = load i64, ptr %9, align 8
  %43 = add i64 %42, 1
  store i64 %43, ptr %9, align 8
  br label %60

44:                                               ; preds = %23
  %45 = load i64, ptr %8, align 8
  %46 = icmp ne i64 %45, 0
  br i1 %46, label %47, label %53

47:                                               ; preds = %44
  %48 = load ptr, ptr %7, align 8
  %49 = load i64, ptr %8, align 8
  %50 = sub i64 %49, 1
  %51 = getelementptr inbounds i64, ptr %48, i64 %50
  %52 = load i64, ptr %51, align 8
  store i64 %52, ptr %8, align 8
  br label %59

53:                                               ; preds = %44
  %54 = load ptr, ptr %7, align 8
  %55 = load i64, ptr %9, align 8
  %56 = getelementptr inbounds i64, ptr %54, i64 %55
  store i64 0, ptr %56, align 8
  %57 = load i64, ptr %9, align 8
  %58 = add i64 %57, 1
  store i64 %58, ptr %9, align 8
  br label %59

59:                                               ; preds = %53, %47
  br label %60

60:                                               ; preds = %59, %35
  br label %19, !llvm.loop !16

61:                                               ; preds = %19
  store i32 0, ptr %4, align 4
  br label %62

62:                                               ; preds = %61, %15
  %63 = load i32, ptr %4, align 4
  ret i32 %63
}

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @isin(ptr noundef %0) #0 {
  %2 = alloca i32, align 4
  %3 = alloca ptr, align 8
  store ptr %0, ptr %3, align 8
  %4 = load ptr, ptr %3, align 8
  %5 = icmp ne ptr %4, null
  br i1 %5, label %7, label %6

6:                                                ; preds = %1
  store i32 -15, ptr %2, align 4
  br label %14

7:                                                ; preds = %1
  %8 = load ptr, ptr %3, align 8
  %9 = getelementptr inbounds %struct.kmp_result, ptr %8, i32 0, i32 0
  %10 = load i64, ptr %9, align 8
  %11 = icmp eq i64 %10, 0
  br i1 %11, label %12, label %13

12:                                               ; preds = %7
  store i32 -16, ptr %2, align 4
  br label %14

13:                                               ; preds = %7
  store i32 0, ptr %2, align 4
  br label %14

14:                                               ; preds = %13, %12, %6
  %15 = load i32, ptr %2, align 4
  ret i32 %15
}

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @firstOccurrence(ptr noundef %0, ptr noundef %1) #0 {
  %3 = alloca i32, align 4
  %4 = alloca ptr, align 8
  %5 = alloca ptr, align 8
  store ptr %0, ptr %4, align 8
  store ptr %1, ptr %5, align 8
  %6 = load ptr, ptr %4, align 8
  %7 = icmp ne ptr %6, null
  br i1 %7, label %9, label %8

8:                                                ; preds = %2
  store i32 -15, ptr %3, align 4
  br label %29

9:                                                ; preds = %2
  %10 = load ptr, ptr %4, align 8
  %11 = getelementptr inbounds %struct.kmp_result, ptr %10, i32 0, i32 0
  %12 = load i64, ptr %11, align 8
  %13 = icmp eq i64 %12, 0
  br i1 %13, label %19, label %14

14:                                               ; preds = %9
  %15 = load ptr, ptr %4, align 8
  %16 = getelementptr inbounds %struct.kmp_result, ptr %15, i32 0, i32 1
  %17 = load ptr, ptr %16, align 8
  %18 = icmp eq ptr %17, null
  br i1 %18, label %19, label %21

19:                                               ; preds = %14, %9
  %20 = load ptr, ptr %5, align 8
  store i32 -1, ptr %20, align 4
  store i32 -16, ptr %3, align 4
  br label %29

21:                                               ; preds = %14
  %22 = load ptr, ptr %4, align 8
  %23 = getelementptr inbounds %struct.kmp_result, ptr %22, i32 0, i32 1
  %24 = load ptr, ptr %23, align 8
  %25 = getelementptr inbounds i64, ptr %24, i64 0
  %26 = load i64, ptr %25, align 8
  %27 = trunc i64 %26 to i32
  %28 = load ptr, ptr %5, align 8
  store i32 %27, ptr %28, align 4
  store i32 0, ptr %3, align 4
  br label %29

29:                                               ; preds = %21, %19, %8
  %30 = load i32, ptr %3, align 4
  ret i32 %30
}

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @allOccurrences(ptr noundef %0, ptr noundef %1, ptr noundef %2) #0 {
  %4 = alloca i32, align 4
  %5 = alloca ptr, align 8
  %6 = alloca ptr, align 8
  %7 = alloca ptr, align 8
  store ptr %0, ptr %5, align 8
  store ptr %1, ptr %6, align 8
  store ptr %2, ptr %7, align 8
  %8 = load ptr, ptr %5, align 8
  %9 = icmp ne ptr %8, null
  br i1 %9, label %11, label %10

10:                                               ; preds = %3
  store i32 -15, ptr %4, align 4
  br label %34

11:                                               ; preds = %3
  %12 = load ptr, ptr %5, align 8
  %13 = getelementptr inbounds %struct.kmp_result, ptr %12, i32 0, i32 0
  %14 = load i64, ptr %13, align 8
  %15 = icmp eq i64 %14, 0
  br i1 %15, label %21, label %16

16:                                               ; preds = %11
  %17 = load ptr, ptr %5, align 8
  %18 = getelementptr inbounds %struct.kmp_result, ptr %17, i32 0, i32 1
  %19 = load ptr, ptr %18, align 8
  %20 = icmp eq ptr %19, null
  br i1 %20, label %21, label %24

21:                                               ; preds = %16, %11
  %22 = load ptr, ptr %7, align 8
  store i32 -1, ptr %22, align 4
  %23 = load ptr, ptr %6, align 8
  store ptr null, ptr %23, align 8
  store i32 -16, ptr %4, align 4
  br label %34

24:                                               ; preds = %16
  %25 = load ptr, ptr %5, align 8
  %26 = getelementptr inbounds %struct.kmp_result, ptr %25, i32 0, i32 1
  %27 = load ptr, ptr %26, align 8
  %28 = load ptr, ptr %6, align 8
  store ptr %27, ptr %28, align 8
  %29 = load ptr, ptr %5, align 8
  %30 = getelementptr inbounds %struct.kmp_result, ptr %29, i32 0, i32 0
  %31 = load i64, ptr %30, align 8
  %32 = trunc i64 %31 to i32
  %33 = load ptr, ptr %7, align 8
  store i32 %32, ptr %33, align 4
  store i32 0, ptr %4, align 4
  br label %34

34:                                               ; preds = %24, %21, %10
  %35 = load i32, ptr %4, align 4
  ret i32 %35
}

attributes #0 = { noinline nounwind optnone uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { nounwind allocsize(0) "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #2 = { nounwind allocsize(1) "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #3 = { nocallback nofree nounwind willreturn memory(argmem: readwrite) }
attributes #4 = { nounwind willreturn memory(read) "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #5 = { nocallback nofree nosync nounwind willreturn }
attributes #6 = { nounwind "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #7 = { nounwind allocsize(0) }
attributes #8 = { nounwind allocsize(1) }
attributes #9 = { nounwind willreturn memory(read) }
attributes #10 = { nounwind }

!llvm.module.flags = !{!0, !1, !2, !3, !4}
!llvm.ident = !{!5}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 2}
!4 = !{i32 7, !"frame-pointer", i32 2}
!5 = !{!"Debian clang version 19.1.7 (3+b1)"}
!6 = distinct !{!6, !7}
!7 = !{!"llvm.loop.mustprogress"}
!8 = distinct !{!8, !7}
!9 = distinct !{!9, !7}
!10 = distinct !{!10, !7}
!11 = distinct !{!11, !7}
!12 = distinct !{!12, !7}
!13 = distinct !{!13, !7}
!14 = distinct !{!14, !7}
!15 = distinct !{!15, !7}
!16 = distinct !{!16, !7}
