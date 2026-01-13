; ModuleID = 'dynarr/dynarr.c'
source_filename = "dynarr/dynarr.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

%struct.DynArr = type { ptr, i64, i64, i64 }

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @init(ptr noundef %0, i64 noundef %1, i64 noundef %2) #0 {
  %4 = alloca i32, align 4      ; ret
  %5 = alloca ptr, align 8      ; arr
  %6 = alloca i64, align 8      ; elem_size
  %7 = alloca i64, align 8      ; cap
  %8 = alloca ptr, align 8      ; ptr
  store ptr %0, ptr %5, align 8
  store i64 %1, ptr %6, align 8
  store i64 %2, ptr %7, align 8
  %9 = load i64, ptr %7, align 8      ; cap
  %10 = load i64, ptr %6, align 8     ; elem_size
  %11 = udiv i64 -1, %10              ; (SIZE_MAX/elem_size)
  %12 = icmp ugt i64 %9, %11
  br i1 %12, label %13, label %14

13:                                               ; preds = %3
  store i32 -6, ptr %4, align 4
  br label %40    ; exit

14:                                               ; preds = %3
  %15 = load ptr, ptr %5, align 8     ; arr
  %16 = getelementptr inbounds %struct.DynArr, ptr %15, i32 0, i32 3
  %17 = load i64, ptr %16, align 8
  %18 = icmp ne i64 %17, 0
  br i1 %18, label %19, label %20

19:                                               ; preds = %14
  store i32 -7, ptr %4, align 4
  br label %40    ; exit

20:                                               ; preds = %14
  %21 = load i64, ptr %7, align 8    ; cap
  %22 = load i64, ptr %6, align 8    ; elem_size
  %23 = mul i64 %21, %22
  %24 = call noalias ptr @malloc(i64 noundef %23) #5
  store ptr %24, ptr %8, align 8     ; ptr
  %25 = load ptr, ptr %8, align 8    ; ptr
  %26 = icmp ne ptr %25, null
  br i1 %26, label %28, label %27

27:                                               ; preds = %20
  store i32 -1, ptr %4, align 4
  br label %40    ; exit

28:                                               ; preds = %20
  %29 = load ptr, ptr %8, align 8   ; ptr
  %30 = load ptr, ptr %5, align 8   ; arr
  %31 = getelementptr inbounds %struct.DynArr, ptr %30, i32 0, i32 0
  store ptr %29, ptr %31, align 8   ; arr.ptr = ptr
  %32 = load i64, ptr %6, align 8
  %33 = load ptr, ptr %5, align 8
  %34 = getelementptr inbounds %struct.DynArr, ptr %33, i32 0, i32 1
  store i64 %32, ptr %34, align 8
  %35 = load i64, ptr %7, align 8
  %36 = load ptr, ptr %5, align 8
  %37 = getelementptr inbounds %struct.DynArr, ptr %36, i32 0, i32 3
  store i64 %35, ptr %37, align 8
  %38 = load ptr, ptr %5, align 8
  %39 = getelementptr inbounds %struct.DynArr, ptr %38, i32 0, i32 2
  store i64 0, ptr %39, align 8
  store i32 0, ptr %4, align 4
  br label %40

40:                                               ; preds = %28, %27, %19, %13
  %41 = load i32, ptr %4, align 4
  ret i32 %41
}

; Function Attrs: nounwind allocsize(0)
declare noalias ptr @malloc(i64 noundef) #1

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @extend(ptr noundef %0, i64 noundef %1) #0 {
  %3 = alloca i32, align 4
  %4 = alloca ptr, align 8
  %5 = alloca i64, align 8
  %6 = alloca i64, align 8
  %7 = alloca i64, align 8
  %8 = alloca ptr, align 8
  store ptr %0, ptr %4, align 8
  store i64 %1, ptr %5, align 8
  %9 = load ptr, ptr %4, align 8
  %10 = icmp ne ptr %9, null
  br i1 %10, label %11, label %16

11:                                               ; preds = %2
  %12 = load ptr, ptr %4, align 8
  %13 = getelementptr inbounds %struct.DynArr, ptr %12, i32 0, i32 3
  %14 = load i64, ptr %13, align 8
  %15 = icmp ne i64 %14, 0
  br i1 %15, label %17, label %16

16:                                               ; preds = %11, %2
  store i32 -3, ptr %3, align 4
  br label %64

17:                                               ; preds = %11
  %18 = load ptr, ptr %4, align 8
  %19 = getelementptr inbounds %struct.DynArr, ptr %18, i32 0, i32 2
  %20 = load i64, ptr %19, align 8
  %21 = load i64, ptr %5, align 8
  %22 = add i64 %20, %21
  %23 = load ptr, ptr %4, align 8
  %24 = getelementptr inbounds %struct.DynArr, ptr %23, i32 0, i32 3
  %25 = load i64, ptr %24, align 8
  %26 = icmp ule i64 %22, %25
  br i1 %26, label %27, label %28

27:                                               ; preds = %17
  store i32 0, ptr %3, align 4
  br label %64

28:                                               ; preds = %17
  %29 = load ptr, ptr %4, align 8
  %30 = getelementptr inbounds %struct.DynArr, ptr %29, i32 0, i32 2
  %31 = load i64, ptr %30, align 8
  %32 = load i64, ptr %5, align 8
  %33 = add i64 %31, %32
  store i64 %33, ptr %6, align 8
  %34 = load ptr, ptr %4, align 8
  %35 = getelementptr inbounds %struct.DynArr, ptr %34, i32 0, i32 3
  %36 = load i64, ptr %35, align 8
  store i64 %36, ptr %7, align 8
  br label %37

37:                                               ; preds = %41, %28
  %38 = load i64, ptr %7, align 8
  %39 = load i64, ptr %6, align 8
  %40 = icmp ult i64 %38, %39
  br i1 %40, label %41, label %44

41:                                               ; preds = %37
  %42 = load i64, ptr %7, align 8
  %43 = mul i64 %42, 2
  store i64 %43, ptr %7, align 8
  br label %37, !llvm.loop !6

44:                                               ; preds = %37
  %45 = load ptr, ptr %4, align 8
  %46 = getelementptr inbounds %struct.DynArr, ptr %45, i32 0, i32 0
  %47 = load ptr, ptr %46, align 8
  %48 = load i64, ptr %7, align 8
  %49 = load ptr, ptr %4, align 8
  %50 = getelementptr inbounds %struct.DynArr, ptr %49, i32 0, i32 1
  %51 = load i64, ptr %50, align 8
  %52 = mul i64 %48, %51
  %53 = call ptr @realloc(ptr noundef %47, i64 noundef %52) #6
  store ptr %53, ptr %8, align 8
  %54 = load ptr, ptr %8, align 8
  %55 = icmp ne ptr %54, null
  br i1 %55, label %57, label %56

56:                                               ; preds = %44
  store i32 -4, ptr %3, align 4
  br label %64

57:                                               ; preds = %44
  %58 = load ptr, ptr %8, align 8
  %59 = load ptr, ptr %4, align 8
  %60 = getelementptr inbounds %struct.DynArr, ptr %59, i32 0, i32 0
  store ptr %58, ptr %60, align 8
  %61 = load i64, ptr %7, align 8
  %62 = load ptr, ptr %4, align 8
  %63 = getelementptr inbounds %struct.DynArr, ptr %62, i32 0, i32 3
  store i64 %61, ptr %63, align 8
  store i32 0, ptr %3, align 4
  br label %64

64:                                               ; preds = %57, %56, %27, %16
  %65 = load i32, ptr %3, align 4
  ret i32 %65
}

; Function Attrs: nounwind allocsize(1)
declare ptr @realloc(ptr noundef, i64 noundef) #2

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @pushOne(ptr noundef %0, ptr noundef %1) #0 {
  %3 = alloca i32, align 4
  %4 = alloca ptr, align 8
  %5 = alloca ptr, align 8
  %6 = alloca i32, align 4
  %7 = alloca ptr, align 8
  store ptr %0, ptr %4, align 8
  store ptr %1, ptr %5, align 8
  %8 = load ptr, ptr %4, align 8
  %9 = icmp ne ptr %8, null
  br i1 %9, label %11, label %10

10:                                               ; preds = %2
  store i32 -2, ptr %3, align 4
  br label %55

11:                                               ; preds = %2
  %12 = load ptr, ptr %4, align 8
  %13 = getelementptr inbounds %struct.DynArr, ptr %12, i32 0, i32 1
  %14 = load i64, ptr %13, align 8
  %15 = icmp ne i64 %14, 0
  br i1 %15, label %17, label %16

16:                                               ; preds = %11
  store i32 -3, ptr %3, align 4
  br label %55

17:                                               ; preds = %11
  %18 = load ptr, ptr %4, align 8
  %19 = getelementptr inbounds %struct.DynArr, ptr %18, i32 0, i32 2
  %20 = load i64, ptr %19, align 8
  %21 = add i64 %20, 1
  %22 = load ptr, ptr %4, align 8
  %23 = getelementptr inbounds %struct.DynArr, ptr %22, i32 0, i32 3
  %24 = load i64, ptr %23, align 8
  %25 = icmp ugt i64 %21, %24
  br i1 %25, label %26, label %34

26:                                               ; preds = %17
  %27 = load ptr, ptr %4, align 8
  %28 = call i32 @extend(ptr noundef %27, i64 noundef 1)
  store i32 %28, ptr %6, align 4
  %29 = load i32, ptr %6, align 4
  %30 = icmp ne i32 %29, 0
  br i1 %30, label %31, label %33

31:                                               ; preds = %26
  %32 = load i32, ptr %6, align 4
  store i32 %32, ptr %3, align 4
  br label %55

33:                                               ; preds = %26
  br label %34

34:                                               ; preds = %33, %17
  %35 = load ptr, ptr %4, align 8
  %36 = getelementptr inbounds %struct.DynArr, ptr %35, i32 0, i32 0
  %37 = load ptr, ptr %36, align 8
  %38 = load ptr, ptr %4, align 8
  %39 = getelementptr inbounds %struct.DynArr, ptr %38, i32 0, i32 2
  %40 = load i64, ptr %39, align 8
  %41 = load ptr, ptr %4, align 8
  %42 = getelementptr inbounds %struct.DynArr, ptr %41, i32 0, i32 1
  %43 = load i64, ptr %42, align 8
  %44 = mul i64 %40, %43
  %45 = getelementptr inbounds i8, ptr %37, i64 %44
  store ptr %45, ptr %7, align 8
  %46 = load ptr, ptr %7, align 8
  %47 = load ptr, ptr %5, align 8
  %48 = load ptr, ptr %4, align 8
  %49 = getelementptr inbounds %struct.DynArr, ptr %48, i32 0, i32 1
  %50 = load i64, ptr %49, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 1 %46, ptr align 1 %47, i64 %50, i1 false)
  %51 = load ptr, ptr %4, align 8
  %52 = getelementptr inbounds %struct.DynArr, ptr %51, i32 0, i32 2
  %53 = load i64, ptr %52, align 8
  %54 = add i64 %53, 1
  store i64 %54, ptr %52, align 8
  store i32 0, ptr %3, align 4
  br label %55

55:                                               ; preds = %34, %31, %16, %10
  %56 = load i32, ptr %3, align 4
  ret i32 %56
}

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias nocapture writeonly, ptr noalias nocapture readonly, i64, i1 immarg) #3

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @pushMany(ptr noundef %0, ptr noundef %1, i64 noundef %2) #0 {
  %4 = alloca i32, align 4
  %5 = alloca ptr, align 8
  %6 = alloca ptr, align 8
  %7 = alloca i64, align 8
  %8 = alloca i32, align 4
  %9 = alloca ptr, align 8
  store ptr %0, ptr %5, align 8
  store ptr %1, ptr %6, align 8
  store i64 %2, ptr %7, align 8
  %10 = load ptr, ptr %5, align 8
  %11 = icmp ne ptr %10, null
  br i1 %11, label %13, label %12

12:                                               ; preds = %3
  store i32 -2, ptr %4, align 4
  br label %51

13:                                               ; preds = %3
  %14 = load ptr, ptr %5, align 8
  %15 = getelementptr inbounds %struct.DynArr, ptr %14, i32 0, i32 1
  %16 = load i64, ptr %15, align 8
  %17 = icmp ne i64 %16, 0
  br i1 %17, label %19, label %18

18:                                               ; preds = %13
  store i32 -3, ptr %4, align 4
  br label %51

19:                                               ; preds = %13
  %20 = load ptr, ptr %5, align 8
  %21 = load i64, ptr %7, align 8
  %22 = call i32 @extend(ptr noundef %20, i64 noundef %21)
  store i32 %22, ptr %8, align 4
  %23 = load i32, ptr %8, align 4
  %24 = icmp ne i32 %23, 0
  br i1 %24, label %25, label %27

25:                                               ; preds = %19
  %26 = load i32, ptr %8, align 4
  store i32 %26, ptr %4, align 4
  br label %51

27:                                               ; preds = %19
  %28 = load ptr, ptr %5, align 8
  %29 = getelementptr inbounds %struct.DynArr, ptr %28, i32 0, i32 0
  %30 = load ptr, ptr %29, align 8
  %31 = load ptr, ptr %5, align 8
  %32 = getelementptr inbounds %struct.DynArr, ptr %31, i32 0, i32 2
  %33 = load i64, ptr %32, align 8
  %34 = load ptr, ptr %5, align 8
  %35 = getelementptr inbounds %struct.DynArr, ptr %34, i32 0, i32 1
  %36 = load i64, ptr %35, align 8
  %37 = mul i64 %33, %36
  %38 = getelementptr inbounds i8, ptr %30, i64 %37
  store ptr %38, ptr %9, align 8
  %39 = load ptr, ptr %9, align 8
  %40 = load ptr, ptr %6, align 8
  %41 = load i64, ptr %7, align 8
  %42 = load ptr, ptr %5, align 8
  %43 = getelementptr inbounds %struct.DynArr, ptr %42, i32 0, i32 1
  %44 = load i64, ptr %43, align 8
  %45 = mul i64 %41, %44
  call void @llvm.memcpy.p0.p0.i64(ptr align 1 %39, ptr align 1 %40, i64 %45, i1 false)
  %46 = load i64, ptr %7, align 8
  %47 = load ptr, ptr %5, align 8
  %48 = getelementptr inbounds %struct.DynArr, ptr %47, i32 0, i32 2
  %49 = load i64, ptr %48, align 8
  %50 = add i64 %49, %46
  store i64 %50, ptr %48, align 8
  store i32 0, ptr %4, align 4
  br label %51

51:                                               ; preds = %27, %25, %18, %12
  %52 = load i32, ptr %4, align 4
  ret i32 %52
}

; Function Attrs: noinline nounwind optnone uwtable
define dso_local ptr @getelement(ptr noundef %0, i64 noundef %1) #0 {
  %3 = alloca ptr, align 8
  %4 = alloca ptr, align 8
  %5 = alloca i64, align 8
  store ptr %0, ptr %4, align 8
  store i64 %1, ptr %5, align 8
  %6 = load ptr, ptr %4, align 8
  %7 = icmp ne ptr %6, null
  br i1 %7, label %8, label %13

8:                                                ; preds = %2
  %9 = load ptr, ptr %4, align 8
  %10 = getelementptr inbounds %struct.DynArr, ptr %9, i32 0, i32 0
  %11 = load ptr, ptr %10, align 8
  %12 = icmp ne ptr %11, null
  br i1 %12, label %14, label %13

13:                                               ; preds = %8, %2
  store ptr null, ptr %3, align 8
  br label %31

14:                                               ; preds = %8
  %15 = load i64, ptr %5, align 8
  %16 = load ptr, ptr %4, align 8
  %17 = getelementptr inbounds %struct.DynArr, ptr %16, i32 0, i32 2
  %18 = load i64, ptr %17, align 8
  %19 = icmp uge i64 %15, %18
  br i1 %19, label %20, label %21

20:                                               ; preds = %14
  store ptr null, ptr %3, align 8
  br label %31

21:                                               ; preds = %14
  %22 = load ptr, ptr %4, align 8
  %23 = getelementptr inbounds %struct.DynArr, ptr %22, i32 0, i32 0
  %24 = load ptr, ptr %23, align 8
  %25 = load i64, ptr %5, align 8
  %26 = load ptr, ptr %4, align 8
  %27 = getelementptr inbounds %struct.DynArr, ptr %26, i32 0, i32 1
  %28 = load i64, ptr %27, align 8
  %29 = mul i64 %25, %28
  %30 = getelementptr inbounds i8, ptr %24, i64 %29
  store ptr %30, ptr %3, align 8
  br label %31

31:                                               ; preds = %21, %20, %13
  %32 = load ptr, ptr %3, align 8
  ret ptr %32
}

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i64 @getarrlen(ptr noundef %0) #0 {
  %2 = alloca ptr, align 8
  store ptr %0, ptr %2, align 8
  %3 = load ptr, ptr %2, align 8
  %4 = getelementptr inbounds %struct.DynArr, ptr %3, i32 0, i32 2
  %5 = load i64, ptr %4, align 8
  ret i64 %5
}

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i64 @getcap(ptr noundef %0) #0 {
  %2 = alloca ptr, align 8
  store ptr %0, ptr %2, align 8
  %3 = load ptr, ptr %2, align 8
  %4 = getelementptr inbounds %struct.DynArr, ptr %3, i32 0, i32 3
  %5 = load i64, ptr %4, align 8
  ret i64 %5
}

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @isempty(ptr noundef %0) #0 {
  %2 = alloca ptr, align 8
  store ptr %0, ptr %2, align 8
  %3 = load ptr, ptr %2, align 8
  %4 = getelementptr inbounds %struct.DynArr, ptr %3, i32 0, i32 2
  %5 = load i64, ptr %4, align 8
  %6 = icmp eq i64 %5, 0
  %7 = zext i1 %6 to i64
  %8 = select i1 %6, i32 -8, i32 -9
  ret i32 %8
}

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
  %16 = zext i1 %15 to i32
  ret i32 %16
}

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @setidx(ptr noundef %0, ptr noundef %1, i64 noundef %2) #0 {
  %4 = alloca i32, align 4
  %5 = alloca ptr, align 8
  %6 = alloca ptr, align 8
  %7 = alloca i64, align 8
  %8 = alloca ptr, align 8
  store ptr %0, ptr %5, align 8
  store ptr %1, ptr %6, align 8
  store i64 %2, ptr %7, align 8
  %9 = load ptr, ptr %5, align 8
  %10 = call i32 @isempty(ptr noundef %9)
  %11 = icmp ne i32 %10, -9
  br i1 %11, label %12, label %13

12:                                               ; preds = %3
  store i32 -2, ptr %4, align 4
  br label %36

13:                                               ; preds = %3
  %14 = load ptr, ptr %5, align 8
  %15 = getelementptr inbounds %struct.DynArr, ptr %14, i32 0, i32 2
  %16 = load i64, ptr %15, align 8
  %17 = load i64, ptr %7, align 8
  %18 = call i32 @boundcheck(i64 noundef 0, i64 noundef %16, i64 noundef %17)
  %19 = icmp ne i32 %18, 1
  br i1 %19, label %20, label %21

20:                                               ; preds = %13
  store i32 -5, ptr %4, align 4
  br label %36

21:                                               ; preds = %13
  %22 = load ptr, ptr %5, align 8
  %23 = getelementptr inbounds %struct.DynArr, ptr %22, i32 0, i32 0
  %24 = load ptr, ptr %23, align 8
  %25 = load i64, ptr %7, align 8
  %26 = load ptr, ptr %5, align 8
  %27 = getelementptr inbounds %struct.DynArr, ptr %26, i32 0, i32 1
  %28 = load i64, ptr %27, align 8
  %29 = mul i64 %25, %28
  %30 = getelementptr inbounds i8, ptr %24, i64 %29
  store ptr %30, ptr %8, align 8
  %31 = load ptr, ptr %8, align 8
  %32 = load ptr, ptr %6, align 8
  %33 = load ptr, ptr %5, align 8
  %34 = getelementptr inbounds %struct.DynArr, ptr %33, i32 0, i32 1
  %35 = load i64, ptr %34, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 1 %31, ptr align 1 %32, i64 %35, i1 false)
  store i32 0, ptr %4, align 4
  br label %36

36:                                               ; preds = %21, %20, %12
  %37 = load i32, ptr %4, align 4
  ret i32 %37
}

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @bytecopy(ptr noundef %0, ptr noundef %1) #0 {
  %3 = alloca i32, align 4
  %4 = alloca ptr, align 8
  %5 = alloca ptr, align 8
  store ptr %0, ptr %4, align 8
  store ptr %1, ptr %5, align 8
  %6 = load ptr, ptr %4, align 8
  %7 = icmp ne ptr %6, null
  br i1 %7, label %8, label %16

8:                                                ; preds = %2
  %9 = load ptr, ptr %5, align 8
  %10 = icmp ne ptr %9, null
  br i1 %10, label %11, label %16

11:                                               ; preds = %8
  %12 = load ptr, ptr %4, align 8
  %13 = getelementptr inbounds %struct.DynArr, ptr %12, i32 0, i32 0
  %14 = load ptr, ptr %13, align 8
  %15 = icmp ne ptr %14, null
  br i1 %15, label %17, label %16

16:                                               ; preds = %11, %8, %2
  store i32 -2, ptr %3, align 4
  br label %53

17:                                               ; preds = %11
  %18 = load ptr, ptr %5, align 8
  %19 = load ptr, ptr %4, align 8
  %20 = getelementptr inbounds %struct.DynArr, ptr %19, i32 0, i32 2
  %21 = load i64, ptr %20, align 8
  %22 = call i32 @extend(ptr noundef %18, i64 noundef %21)
  %23 = icmp ne i32 %22, 0
  br i1 %23, label %24, label %25

24:                                               ; preds = %17
  store i32 -4, ptr %3, align 4
  br label %53

25:                                               ; preds = %17
  %26 = load ptr, ptr %4, align 8
  %27 = getelementptr inbounds %struct.DynArr, ptr %26, i32 0, i32 1
  %28 = load i64, ptr %27, align 8
  %29 = load ptr, ptr %5, align 8
  %30 = getelementptr inbounds %struct.DynArr, ptr %29, i32 0, i32 1
  %31 = load i64, ptr %30, align 8
  %32 = icmp ne i64 %28, %31
  br i1 %32, label %33, label %34

33:                                               ; preds = %25
  store i32 -10, ptr %3, align 4
  br label %53

34:                                               ; preds = %25
  %35 = load ptr, ptr %5, align 8
  %36 = getelementptr inbounds %struct.DynArr, ptr %35, i32 0, i32 0
  %37 = load ptr, ptr %36, align 8
  %38 = load ptr, ptr %4, align 8
  %39 = getelementptr inbounds %struct.DynArr, ptr %38, i32 0, i32 0
  %40 = load ptr, ptr %39, align 8
  %41 = load ptr, ptr %4, align 8
  %42 = getelementptr inbounds %struct.DynArr, ptr %41, i32 0, i32 2
  %43 = load i64, ptr %42, align 8
  %44 = load ptr, ptr %4, align 8
  %45 = getelementptr inbounds %struct.DynArr, ptr %44, i32 0, i32 1
  %46 = load i64, ptr %45, align 8
  %47 = mul i64 %43, %46
  call void @llvm.memcpy.p0.p0.i64(ptr align 1 %37, ptr align 1 %40, i64 %47, i1 false)
  %48 = load ptr, ptr %4, align 8
  %49 = getelementptr inbounds %struct.DynArr, ptr %48, i32 0, i32 2
  %50 = load i64, ptr %49, align 8
  %51 = load ptr, ptr %5, align 8
  %52 = getelementptr inbounds %struct.DynArr, ptr %51, i32 0, i32 2
  store i64 %50, ptr %52, align 8
  store i32 0, ptr %3, align 4
  br label %53

53:                                               ; preds = %34, %33, %24, %16
  %54 = load i32, ptr %3, align 4
  ret i32 %54
}

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @merge(ptr noundef %0, ptr noundef %1) #0 {
  %3 = alloca i32, align 4
  %4 = alloca ptr, align 8
  %5 = alloca ptr, align 8
  %6 = alloca ptr, align 8
  store ptr %0, ptr %4, align 8
  store ptr %1, ptr %5, align 8
  %7 = load ptr, ptr %4, align 8
  %8 = icmp ne ptr %7, null
  br i1 %8, label %9, label %22

9:                                                ; preds = %2
  %10 = load ptr, ptr %4, align 8
  %11 = getelementptr inbounds %struct.DynArr, ptr %10, i32 0, i32 0
  %12 = load ptr, ptr %11, align 8
  %13 = icmp ne ptr %12, null
  br i1 %13, label %14, label %22

14:                                               ; preds = %9
  %15 = load ptr, ptr %5, align 8
  %16 = icmp ne ptr %15, null
  br i1 %16, label %17, label %22

17:                                               ; preds = %14
  %18 = load ptr, ptr %5, align 8
  %19 = getelementptr inbounds %struct.DynArr, ptr %18, i32 0, i32 0
  %20 = load ptr, ptr %19, align 8
  %21 = icmp ne ptr %20, null
  br i1 %21, label %23, label %22

22:                                               ; preds = %17, %14, %9, %2
  store i32 -2, ptr %3, align 4
  br label %61

23:                                               ; preds = %17
  %24 = load ptr, ptr %4, align 8
  %25 = load ptr, ptr %5, align 8
  %26 = getelementptr inbounds %struct.DynArr, ptr %25, i32 0, i32 2
  %27 = load i64, ptr %26, align 8
  %28 = call i32 @extend(ptr noundef %24, i64 noundef %27)
  %29 = icmp ne i32 %28, 0
  br i1 %29, label %30, label %31

30:                                               ; preds = %23
  store i32 -4, ptr %3, align 4
  br label %61

31:                                               ; preds = %23
  %32 = load ptr, ptr %4, align 8
  %33 = getelementptr inbounds %struct.DynArr, ptr %32, i32 0, i32 0
  %34 = load ptr, ptr %33, align 8
  %35 = load ptr, ptr %4, align 8
  %36 = getelementptr inbounds %struct.DynArr, ptr %35, i32 0, i32 2
  %37 = load i64, ptr %36, align 8
  %38 = load ptr, ptr %4, align 8
  %39 = getelementptr inbounds %struct.DynArr, ptr %38, i32 0, i32 1
  %40 = load i64, ptr %39, align 8
  %41 = mul i64 %37, %40
  %42 = getelementptr inbounds i8, ptr %34, i64 %41
  store ptr %42, ptr %6, align 8
  %43 = load ptr, ptr %6, align 8
  %44 = load ptr, ptr %5, align 8
  %45 = getelementptr inbounds %struct.DynArr, ptr %44, i32 0, i32 0
  %46 = load ptr, ptr %45, align 8
  %47 = load ptr, ptr %5, align 8
  %48 = getelementptr inbounds %struct.DynArr, ptr %47, i32 0, i32 2
  %49 = load i64, ptr %48, align 8
  %50 = load ptr, ptr %5, align 8
  %51 = getelementptr inbounds %struct.DynArr, ptr %50, i32 0, i32 1
  %52 = load i64, ptr %51, align 8
  %53 = mul i64 %49, %52
  call void @llvm.memcpy.p0.p0.i64(ptr align 1 %43, ptr align 1 %46, i64 %53, i1 false)
  %54 = load ptr, ptr %5, align 8
  %55 = getelementptr inbounds %struct.DynArr, ptr %54, i32 0, i32 2
  %56 = load i64, ptr %55, align 8
  %57 = load ptr, ptr %4, align 8
  %58 = getelementptr inbounds %struct.DynArr, ptr %57, i32 0, i32 2
  %59 = load i64, ptr %58, align 8
  %60 = add i64 %59, %56
  store i64 %60, ptr %58, align 8
  store i32 0, ptr %3, align 4
  br label %61

61:                                               ; preds = %31, %30, %22
  %62 = load i32, ptr %3, align 4
  ret i32 %62
}

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @export2stack(ptr noundef %0, ptr noundef %1) #0 {
  %3 = alloca i32, align 4
  %4 = alloca ptr, align 8
  %5 = alloca ptr, align 8
  store ptr %0, ptr %4, align 8
  store ptr %1, ptr %5, align 8
  %6 = load ptr, ptr %4, align 8
  %7 = icmp ne ptr %6, null
  br i1 %7, label %8, label %13

8:                                                ; preds = %2
  %9 = load ptr, ptr %4, align 8
  %10 = getelementptr inbounds %struct.DynArr, ptr %9, i32 0, i32 0
  %11 = load ptr, ptr %10, align 8
  %12 = icmp ne ptr %11, null
  br i1 %12, label %14, label %13

13:                                               ; preds = %8, %2
  store i32 -2, ptr %3, align 4
  br label %27

14:                                               ; preds = %8
  %15 = load ptr, ptr %5, align 8
  %16 = load ptr, ptr %15, align 8
  %17 = load ptr, ptr %4, align 8
  %18 = getelementptr inbounds %struct.DynArr, ptr %17, i32 0, i32 0
  %19 = load ptr, ptr %18, align 8
  %20 = load ptr, ptr %4, align 8
  %21 = getelementptr inbounds %struct.DynArr, ptr %20, i32 0, i32 2
  %22 = load i64, ptr %21, align 8
  %23 = load ptr, ptr %4, align 8
  %24 = getelementptr inbounds %struct.DynArr, ptr %23, i32 0, i32 1
  %25 = load i64, ptr %24, align 8
  %26 = mul i64 %22, %25
  call void @llvm.memcpy.p0.p0.i64(ptr align 1 %16, ptr align 1 %19, i64 %26, i1 false)
  store i32 0, ptr %3, align 4
  br label %27

27:                                               ; preds = %14, %13
  %28 = load i32, ptr %3, align 4
  ret i32 %28
}

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @insertidx(ptr noundef %0, ptr noundef %1, i64 noundef %2) #0 {
  %4 = alloca i32, align 4
  %5 = alloca ptr, align 8
  %6 = alloca ptr, align 8
  %7 = alloca i64, align 8
  %8 = alloca ptr, align 8
  %9 = alloca ptr, align 8
  %10 = alloca i64, align 8
  store ptr %0, ptr %5, align 8
  store ptr %1, ptr %6, align 8
  store i64 %2, ptr %7, align 8
  %11 = load ptr, ptr %5, align 8
  %12 = icmp ne ptr %11, null
  br i1 %12, label %13, label %18

13:                                               ; preds = %3
  %14 = load ptr, ptr %5, align 8
  %15 = getelementptr inbounds %struct.DynArr, ptr %14, i32 0, i32 0
  %16 = load ptr, ptr %15, align 8
  %17 = icmp ne ptr %16, null
  br i1 %17, label %19, label %18

18:                                               ; preds = %13, %3
  store i32 -2, ptr %4, align 4
  br label %81

19:                                               ; preds = %13
  %20 = load ptr, ptr %5, align 8
  %21 = getelementptr inbounds %struct.DynArr, ptr %20, i32 0, i32 2
  %22 = load i64, ptr %21, align 8
  %23 = load i64, ptr %7, align 8
  %24 = call i32 @boundcheck(i64 noundef 0, i64 noundef %22, i64 noundef %23)
  %25 = icmp ne i32 %24, 1
  br i1 %25, label %26, label %27

26:                                               ; preds = %19
  store i32 -5, ptr %4, align 4
  br label %81

27:                                               ; preds = %19
  %28 = load ptr, ptr %5, align 8
  %29 = getelementptr inbounds %struct.DynArr, ptr %28, i32 0, i32 2
  %30 = load i64, ptr %29, align 8
  %31 = load ptr, ptr %5, align 8
  %32 = getelementptr inbounds %struct.DynArr, ptr %31, i32 0, i32 3
  %33 = load i64, ptr %32, align 8
  %34 = icmp eq i64 %30, %33
  br i1 %34, label %35, label %41

35:                                               ; preds = %27
  %36 = load ptr, ptr %5, align 8
  %37 = call i32 @extend(ptr noundef %36, i64 noundef 1)
  %38 = icmp ne i32 %37, 0
  br i1 %38, label %39, label %40

39:                                               ; preds = %35
  store i32 -4, ptr %4, align 4
  br label %81

40:                                               ; preds = %35
  br label %41

41:                                               ; preds = %40, %27
  %42 = load ptr, ptr %5, align 8
  %43 = getelementptr inbounds %struct.DynArr, ptr %42, i32 0, i32 0
  %44 = load ptr, ptr %43, align 8
  %45 = load i64, ptr %7, align 8
  %46 = add i64 %45, 1
  %47 = load ptr, ptr %5, align 8
  %48 = getelementptr inbounds %struct.DynArr, ptr %47, i32 0, i32 1
  %49 = load i64, ptr %48, align 8
  %50 = mul i64 %46, %49
  %51 = getelementptr inbounds i8, ptr %44, i64 %50
  store ptr %51, ptr %8, align 8
  %52 = load ptr, ptr %5, align 8
  %53 = getelementptr inbounds %struct.DynArr, ptr %52, i32 0, i32 0
  %54 = load ptr, ptr %53, align 8
  %55 = load i64, ptr %7, align 8
  %56 = load ptr, ptr %5, align 8
  %57 = getelementptr inbounds %struct.DynArr, ptr %56, i32 0, i32 1
  %58 = load i64, ptr %57, align 8
  %59 = mul i64 %55, %58
  %60 = getelementptr inbounds i8, ptr %54, i64 %59
  store ptr %60, ptr %9, align 8
  %61 = load ptr, ptr %5, align 8
  %62 = getelementptr inbounds %struct.DynArr, ptr %61, i32 0, i32 2
  %63 = load i64, ptr %62, align 8
  %64 = load i64, ptr %7, align 8
  %65 = sub i64 %63, %64
  %66 = load ptr, ptr %5, align 8
  %67 = getelementptr inbounds %struct.DynArr, ptr %66, i32 0, i32 1
  %68 = load i64, ptr %67, align 8
  %69 = mul i64 %65, %68
  store i64 %69, ptr %10, align 8
  %70 = load ptr, ptr %8, align 8
  %71 = load ptr, ptr %9, align 8
  %72 = load i64, ptr %10, align 8
  call void @llvm.memmove.p0.p0.i64(ptr align 1 %70, ptr align 1 %71, i64 %72, i1 false)
  %73 = load ptr, ptr %5, align 8
  %74 = load ptr, ptr %6, align 8
  %75 = load i64, ptr %7, align 8
  %76 = call i32 @setidx(ptr noundef %73, ptr noundef %74, i64 noundef %75)
  %77 = load ptr, ptr %5, align 8
  %78 = getelementptr inbounds %struct.DynArr, ptr %77, i32 0, i32 2
  %79 = load i64, ptr %78, align 8
  %80 = add i64 %79, 1
  store i64 %80, ptr %78, align 8
  store i32 0, ptr %4, align 4
  br label %81

81:                                               ; preds = %41, %39, %26, %18
  %82 = load i32, ptr %4, align 4
  ret i32 %82
}

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memmove.p0.p0.i64(ptr nocapture writeonly, ptr nocapture readonly, i64, i1 immarg) #3

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @removeidx(ptr noundef %0, i64 noundef %1) #0 {
  %3 = alloca i32, align 4
  %4 = alloca ptr, align 8
  %5 = alloca i64, align 8
  %6 = alloca ptr, align 8
  %7 = alloca ptr, align 8
  %8 = alloca i64, align 8
  store ptr %0, ptr %4, align 8
  store i64 %1, ptr %5, align 8
  %9 = load ptr, ptr %4, align 8
  %10 = icmp ne ptr %9, null
  br i1 %10, label %11, label %16

11:                                               ; preds = %2
  %12 = load ptr, ptr %4, align 8
  %13 = getelementptr inbounds %struct.DynArr, ptr %12, i32 0, i32 0
  %14 = load ptr, ptr %13, align 8
  %15 = icmp ne ptr %14, null
  br i1 %15, label %17, label %16

16:                                               ; preds = %11, %2
  store i32 -2, ptr %3, align 4
  br label %62

17:                                               ; preds = %11
  %18 = load ptr, ptr %4, align 8
  %19 = getelementptr inbounds %struct.DynArr, ptr %18, i32 0, i32 2
  %20 = load i64, ptr %19, align 8
  %21 = load i64, ptr %5, align 8
  %22 = call i32 @boundcheck(i64 noundef 0, i64 noundef %20, i64 noundef %21)
  %23 = icmp ne i32 %22, 1
  br i1 %23, label %24, label %25

24:                                               ; preds = %17
  store i32 -5, ptr %3, align 4
  br label %62

25:                                               ; preds = %17
  %26 = load ptr, ptr %4, align 8
  %27 = getelementptr inbounds %struct.DynArr, ptr %26, i32 0, i32 0
  %28 = load ptr, ptr %27, align 8
  %29 = load i64, ptr %5, align 8
  %30 = load ptr, ptr %4, align 8
  %31 = getelementptr inbounds %struct.DynArr, ptr %30, i32 0, i32 1
  %32 = load i64, ptr %31, align 8
  %33 = mul i64 %29, %32
  %34 = getelementptr inbounds i8, ptr %28, i64 %33
  store ptr %34, ptr %6, align 8
  %35 = load ptr, ptr %4, align 8
  %36 = getelementptr inbounds %struct.DynArr, ptr %35, i32 0, i32 0
  %37 = load ptr, ptr %36, align 8
  %38 = load i64, ptr %5, align 8
  %39 = add i64 %38, 1
  %40 = load ptr, ptr %4, align 8
  %41 = getelementptr inbounds %struct.DynArr, ptr %40, i32 0, i32 1
  %42 = load i64, ptr %41, align 8
  %43 = mul i64 %39, %42
  %44 = getelementptr inbounds i8, ptr %37, i64 %43
  store ptr %44, ptr %7, align 8
  %45 = load ptr, ptr %4, align 8
  %46 = getelementptr inbounds %struct.DynArr, ptr %45, i32 0, i32 2
  %47 = load i64, ptr %46, align 8
  %48 = load i64, ptr %5, align 8
  %49 = sub i64 %47, %48
  %50 = sub i64 %49, 1
  %51 = load ptr, ptr %4, align 8
  %52 = getelementptr inbounds %struct.DynArr, ptr %51, i32 0, i32 1
  %53 = load i64, ptr %52, align 8
  %54 = mul i64 %50, %53
  store i64 %54, ptr %8, align 8
  %55 = load ptr, ptr %6, align 8
  %56 = load ptr, ptr %7, align 8
  %57 = load i64, ptr %8, align 8
  call void @llvm.memmove.p0.p0.i64(ptr align 1 %55, ptr align 1 %56, i64 %57, i1 false)
  %58 = load ptr, ptr %4, align 8
  %59 = getelementptr inbounds %struct.DynArr, ptr %58, i32 0, i32 2
  %60 = load i64, ptr %59, align 8
  %61 = add i64 %60, -1
  store i64 %61, ptr %59, align 8
  store i32 0, ptr %3, align 4
  br label %62

62:                                               ; preds = %25, %24, %16
  %63 = load i32, ptr %3, align 4
  ret i32 %63
}

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @clearArr(ptr noundef %0) #0 {
  %2 = alloca i32, align 4
  %3 = alloca ptr, align 8
  store ptr %0, ptr %3, align 8
  %4 = load ptr, ptr %3, align 8
  %5 = icmp ne ptr %4, null
  br i1 %5, label %6, label %11

6:                                                ; preds = %1
  %7 = load ptr, ptr %3, align 8
  %8 = getelementptr inbounds %struct.DynArr, ptr %7, i32 0, i32 0
  %9 = load ptr, ptr %8, align 8
  %10 = icmp ne ptr %9, null
  br i1 %10, label %12, label %11

11:                                               ; preds = %6, %1
  store i32 -2, ptr %2, align 4
  br label %19

12:                                               ; preds = %6
  %13 = load ptr, ptr %3, align 8
  %14 = getelementptr inbounds %struct.DynArr, ptr %13, i32 0, i32 0
  store ptr null, ptr %14, align 8
  %15 = load ptr, ptr %3, align 8
  %16 = getelementptr inbounds %struct.DynArr, ptr %15, i32 0, i32 2
  store i64 0, ptr %16, align 8
  %17 = load ptr, ptr %3, align 8
  %18 = getelementptr inbounds %struct.DynArr, ptr %17, i32 0, i32 1
  store i64 0, ptr %18, align 8
  store i32 0, ptr %2, align 4
  br label %19

19:                                               ; preds = %12, %11
  %20 = load i32, ptr %2, align 4
  ret i32 %20
}

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @freeArr(ptr noundef %0) #0 {
  %2 = alloca i32, align 4
  %3 = alloca ptr, align 8
  store ptr %0, ptr %3, align 8
  %4 = load ptr, ptr %3, align 8
  %5 = getelementptr inbounds %struct.DynArr, ptr %4, i32 0, i32 0
  %6 = load ptr, ptr %5, align 8
  %7 = icmp ne ptr %6, null
  br i1 %7, label %9, label %8

8:                                                ; preds = %1
  store i32 -2, ptr %2, align 4
  br label %21

9:                                                ; preds = %1
  %10 = load ptr, ptr %3, align 8
  %11 = getelementptr inbounds %struct.DynArr, ptr %10, i32 0, i32 0
  %12 = load ptr, ptr %11, align 8
  call void @free(ptr noundef %12) #7
  %13 = load ptr, ptr %3, align 8
  %14 = getelementptr inbounds %struct.DynArr, ptr %13, i32 0, i32 0
  store ptr null, ptr %14, align 8
  %15 = load ptr, ptr %3, align 8
  %16 = getelementptr inbounds %struct.DynArr, ptr %15, i32 0, i32 3
  store i64 0, ptr %16, align 8
  %17 = load ptr, ptr %3, align 8
  %18 = getelementptr inbounds %struct.DynArr, ptr %17, i32 0, i32 2
  store i64 0, ptr %18, align 8
  %19 = load ptr, ptr %3, align 8
  %20 = getelementptr inbounds %struct.DynArr, ptr %19, i32 0, i32 1
  store i64 0, ptr %20, align 8
  store i32 0, ptr %2, align 4
  br label %21

21:                                               ; preds = %9, %8
  %22 = load i32, ptr %2, align 4
  ret i32 %22
}

; Function Attrs: nounwind
declare void @free(ptr noundef) #4

attributes #0 = { noinline nounwind optnone uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { nounwind allocsize(0) "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #2 = { nounwind allocsize(1) "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #3 = { nocallback nofree nounwind willreturn memory(argmem: readwrite) }
attributes #4 = { nounwind "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #5 = { nounwind allocsize(0) }
attributes #6 = { nounwind allocsize(1) }
attributes #7 = { nounwind }

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
