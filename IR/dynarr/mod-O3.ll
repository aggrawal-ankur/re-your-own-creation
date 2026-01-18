; ModuleID = 'dynarr/dynarr.c'
source_filename = "dynarr/dynarr.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; Function Attrs: mustprogress nofree nounwind willreturn memory(argmem: readwrite, inaccessiblemem: readwrite) uwtable
define dso_local range(i32 -11, 1) i32 @init(ptr nocapture noundef %0, i64 noundef %1, i64 noundef %2) local_unnamed_addr #0 {
  %4 = getelementptr inbounds i8, ptr %0, i64 24
  %5 = load i64, ptr %4, align 8, !tbaa !5        ; capacity
  %6 = icmp eq i64 %5, 0        ; capacity != 0
  br i1 %6, label %7, label %21

7:                                                ; preds = %3
  %8 = icmp eq i64 %1, 0    ; elem_size == 0
  %9 = icmp eq i64 %2, 0    ; cap == 0
  %10 = or i1 %8, %9
  br i1 %10, label %21, label %11

11:                                               ; preds = %7
  %12 = tail call { i64, i1 } @llvm.umul.with.overflow.i64(i64 %1, i64 %2)
  %13 = extractvalue { i64, i1 } %12, 1
  br i1 %13, label %21, label %14

14:                                               ; preds = %11
  %15 = mul i64 %2, %1
  %16 = tail call noalias ptr @malloc(i64 noundef %15) #13
  %17 = icmp eq ptr %16, null
  br i1 %17, label %21, label %18

18:                                               ; preds = %14
  store ptr %16, ptr %0, align 8, !tbaa !11
  %19 = getelementptr inbounds i8, ptr %0, i64 8
  store i64 %1, ptr %19, align 8, !tbaa !12
  store i64 %2, ptr %4, align 8, !tbaa !5
  %20 = getelementptr inbounds i8, ptr %0, i64 16
  store i64 0, ptr %20, align 8, !tbaa !13
  br label %21

21:                                               ; preds = %18, %14, %11, %7, %3
  %22 = phi i32 [ -7, %3 ], [ -11, %7 ], [ -6, %11 ], [ 0, %18 ], [ -1, %14 ]
  ret i32 %22
}

; Function Attrs: mustprogress nofree nounwind willreturn allockind("alloc,uninitialized") allocsize(0) memory(inaccessiblemem: readwrite)
declare noalias noundef ptr @malloc(i64 noundef) local_unnamed_addr #1

; Function Attrs: nounwind uwtable
define dso_local range(i32 -4, 1) i32 @extend(ptr noundef %0, i64 noundef %1) local_unnamed_addr #2 {
  %3 = icmp eq ptr %0, null
  br i1 %3, label %25, label %4

4:                                                ; preds = %2
  %5 = getelementptr inbounds i8, ptr %0, i64 24
  %6 = load i64, ptr %5, align 8, !tbaa !5
  %7 = icmp eq i64 %6, 0
  br i1 %7, label %25, label %8

8:                                                ; preds = %4
  %9 = getelementptr inbounds i8, ptr %0, i64 16
  %10 = load i64, ptr %9, align 8, !tbaa !13
  %11 = add i64 %10, %1
  %12 = icmp ugt i64 %11, %6
  br i1 %12, label %13, label %25

13:                                               ; preds = %8, %13
  %14 = phi i64 [ %16, %13 ], [ %6, %8 ]
  %15 = icmp ult i64 %14, %11
  %16 = shl i64 %14, 1
  br i1 %15, label %13, label %17, !llvm.loop !14

17:                                               ; preds = %13
  %18 = load ptr, ptr %0, align 8, !tbaa !11
  %19 = getelementptr inbounds i8, ptr %0, i64 8
  %20 = load i64, ptr %19, align 8, !tbaa !12
  %21 = mul i64 %20, %14
  %22 = tail call ptr @realloc(ptr noundef %18, i64 noundef %21) #14
  %23 = icmp eq ptr %22, null
  br i1 %23, label %25, label %24

24:                                               ; preds = %17
  store ptr %22, ptr %0, align 8, !tbaa !11
  store i64 %14, ptr %5, align 8, !tbaa !5
  br label %25

25:                                               ; preds = %24, %17, %8, %2, %4
  %26 = phi i32 [ -3, %4 ], [ -3, %2 ], [ 0, %8 ], [ 0, %24 ], [ -4, %17 ]
  ret i32 %26
}

; Function Attrs: mustprogress nounwind willreturn allockind("realloc") allocsize(1) memory(argmem: readwrite, inaccessiblemem: readwrite)
declare noalias noundef ptr @realloc(ptr allocptr nocapture noundef, i64 noundef) local_unnamed_addr #3

; Function Attrs: nounwind uwtable
define dso_local range(i32 -4, 1) i32 @pushOne(ptr noundef %0, ptr nocapture noundef readonly %1) local_unnamed_addr #2 {
  %3 = icmp eq ptr %0, null
  br i1 %3, label %39, label %4

4:                                                ; preds = %2
  %5 = getelementptr inbounds i8, ptr %0, i64 8
  %6 = load i64, ptr %5, align 8, !tbaa !12       ; elem_size
  %7 = icmp eq i64 %6, 0        ; elem_size == 0
  br i1 %7, label %39, label %8

8:                                                ; preds = %4
  %9 = getelementptr inbounds i8, ptr %0, i64 24
  %10 = load i64, ptr %9, align 8, !tbaa !5       ; capacity
  %11 = icmp eq i64 %10, 0      ; capacity == 0
  br i1 %11, label %39, label %12

12:                                               ; preds = %8
  %13 = getelementptr inbounds i8, ptr %0, i64 16
  %14 = load i64, ptr %13, align 8, !tbaa !13     ; count
  %15 = add i64 %14, 1          ; count+1
  %16 = icmp ugt i64 %15, %10   ; count+1 > capacity
  br i1 %16, label %19, label %17

17:                                               ; preds = %12
  %18 = load ptr, ptr %0, align 8, !tbaa !11      ; preserve initi ptr
  br label %31

19:                                               ; preds = %12, %19
  %20 = phi i64 [ %22, %19 ], [ %10, %12 ]
  %21 = icmp ult i64 %20, %15
  %22 = shl i64 %20, 1
  br i1 %21, label %19, label %23, !llvm.loop !14

23:                                               ; preds = %19
  %24 = load ptr, ptr %0, align 8, !tbaa !11
  %25 = mul i64 %20, %6
  %26 = tail call ptr @realloc(ptr noundef %24, i64 noundef %25) #14
  %27 = icmp eq ptr %26, null
  br i1 %27, label %39, label %28

28:                                               ; preds = %23
  store ptr %26, ptr %0, align 8, !tbaa !11
  store i64 %20, ptr %9, align 8, !tbaa !5
  %29 = load i64, ptr %13, align 8, !tbaa !13
  %30 = load i64, ptr %5, align 8, !tbaa !12
  br label %31

31:                                               ; preds = %17, %28
  %32 = phi i64 [ %6, %17 ], [ %30, %28 ]
  %33 = phi i64 [ %14, %17 ], [ %29, %28 ]
  %34 = phi ptr [ %18, %17 ], [ %26, %28 ]
  %35 = mul i64 %32, %33
  %36 = getelementptr inbounds i8, ptr %34, i64 %35
  tail call void @llvm.memcpy.p0.p0.i64(ptr align 1 %36, ptr align 1 %1, i64 %32, i1 false)
  %37 = load i64, ptr %13, align 8, !tbaa !13
  %38 = add i64 %37, 1
  store i64 %38, ptr %13, align 8, !tbaa !13
  br label %39

39:                                               ; preds = %23, %2, %4, %8, %31
  %40 = phi i32 [ 0, %31 ], [ -3, %8 ], [ -3, %4 ], [ -3, %2 ], [ -4, %23 ]
  ret i32 %40
}

; Function Attrs: mustprogress nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias nocapture writeonly, ptr noalias nocapture readonly, i64, i1 immarg) #4

; Function Attrs: nounwind uwtable
define dso_local noundef i32 @pushMany(ptr noundef %0, ptr nocapture noundef readonly %1, i64 noundef %2) local_unnamed_addr #2 {
  %4 = icmp eq ptr %0, null       ; !arr
  br i1 %4, label %43, label %5

5:                                                ; preds = %3
  %6 = getelementptr inbounds i8, ptr %0, i64 8
  %7 = load i64, ptr %6, align 8, !tbaa !12       ; elem_size
  %8 = icmp eq i64 %7, 0       ; elem_size == 0
  br i1 %8, label %43, label %9

9:                                                ; preds = %5
  %10 = icmp eq i64 %2, 0         ; count == 0
  br i1 %10, label %43, label %11

11:                                               ; preds = %9
  %12 = getelementptr inbounds i8, ptr %0, i64 24
  %13 = load i64, ptr %12, align 8, !tbaa !5
  %14 = icmp eq i64 %13, 0
  br i1 %14, label %43, label %15

15:                                               ; preds = %11
  %16 = getelementptr inbounds i8, ptr %0, i64 16
  %17 = load i64, ptr %16, align 8, !tbaa !13
  %18 = add i64 %17, %2
  %19 = icmp ugt i64 %18, %13
  br i1 %19, label %22, label %20

20:                                               ; preds = %15
  %21 = load ptr, ptr %0, align 8, !tbaa !11
  br label %34

22:                                               ; preds = %15, %22
  %23 = phi i64 [ %25, %22 ], [ %13, %15 ]
  %24 = icmp ult i64 %23, %18
  %25 = shl i64 %23, 1
  br i1 %24, label %22, label %26, !llvm.loop !14

26:                                               ; preds = %22
  %27 = load ptr, ptr %0, align 8, !tbaa !11
  %28 = mul i64 %23, %7
  %29 = tail call ptr @realloc(ptr noundef %27, i64 noundef %28) #14
  %30 = icmp eq ptr %29, null
  br i1 %30, label %43, label %31

31:                                               ; preds = %26
  store ptr %29, ptr %0, align 8, !tbaa !11
  store i64 %23, ptr %12, align 8, !tbaa !5
  %32 = load i64, ptr %16, align 8, !tbaa !13
  %33 = load i64, ptr %6, align 8, !tbaa !12
  br label %34

34:                                               ; preds = %20, %31
  %35 = phi i64 [ %7, %20 ], [ %33, %31 ]
  %36 = phi i64 [ %17, %20 ], [ %32, %31 ]
  %37 = phi ptr [ %21, %20 ], [ %29, %31 ]
  %38 = mul i64 %35, %36
  %39 = getelementptr inbounds i8, ptr %37, i64 %38
  %40 = mul i64 %35, %2
  tail call void @llvm.memcpy.p0.p0.i64(ptr align 1 %39, ptr align 1 %1, i64 %40, i1 false)
  %41 = load i64, ptr %16, align 8, !tbaa !13
  %42 = add i64 %41, %2
  store i64 %42, ptr %16, align 8, !tbaa !13
  br label %43

43:                                               ; preds = %26, %11, %34, %9, %3, %5
  %44 = phi i32 [ -3, %5 ], [ -3, %3 ], [ -12, %9 ], [ 0, %34 ], [ -3, %11 ], [ -4, %26 ]
  ret i32 %44
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read) uwtable
define dso_local ptr @getelement(ptr noundef readonly %0, i64 noundef %1) local_unnamed_addr #5 {
  %3 = icmp eq ptr %0, null
  br i1 %3, label %16, label %4

4:                                                ; preds = %2
  %5 = load ptr, ptr %0, align 8, !tbaa !11
  %6 = icmp eq ptr %5, null
  br i1 %6, label %16, label %7

7:                                                ; preds = %4
  %8 = getelementptr inbounds i8, ptr %0, i64 16
  %9 = load i64, ptr %8, align 8, !tbaa !13
  %10 = icmp ugt i64 %9, %1
  br i1 %10, label %16, label %11

11:                                               ; preds = %7
  %12 = getelementptr inbounds i8, ptr %0, i64 8
  %13 = load i64, ptr %12, align 8, !tbaa !12
  %14 = mul i64 %13, %1
  %15 = getelementptr inbounds i8, ptr %5, i64 %14
  br label %16

16:                                               ; preds = %7, %2, %4, %11
  %17 = phi ptr [ %15, %11 ], [ null, %4 ], [ null, %2 ], [ null, %7 ]
  ret ptr %17
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none) uwtable
define dso_local range(i32 0, 2) i32 @boundcheck(i64 noundef %0, i64 noundef %1, i64 noundef %2) local_unnamed_addr #6 {
  %4 = icmp uge i64 %2, %0
  %5 = icmp ult i64 %2, %1
  %6 = and i1 %4, %5
  %7 = zext i1 %6 to i32
  ret i32 %7
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read) uwtable
define dso_local i64 @getarrlen(ptr nocapture noundef readonly %0) local_unnamed_addr #5 {
  %2 = getelementptr inbounds i8, ptr %0, i64 16
  %3 = load i64, ptr %2, align 8, !tbaa !13
  ret i64 %3
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read) uwtable
define dso_local i64 @getcap(ptr nocapture noundef readonly %0) local_unnamed_addr #5 {
  %2 = getelementptr inbounds i8, ptr %0, i64 24
  %3 = load i64, ptr %2, align 8, !tbaa !5
  ret i64 %3
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read) uwtable
define dso_local range(i32 -9, -7) i32 @isempty(ptr nocapture noundef readonly %0) local_unnamed_addr #5 {
  %2 = getelementptr inbounds i8, ptr %0, i64 16
  %3 = load i64, ptr %2, align 8, !tbaa !13
  %4 = icmp eq i64 %3, 0
  %5 = select i1 %4, i32 -8, i32 -9
  ret i32 %5
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(readwrite, inaccessiblemem: none) uwtable
define dso_local range(i32 -5, 1) i32 @setidx(ptr noundef readonly %0, ptr nocapture noundef readonly %1, i64 noundef %2) local_unnamed_addr #7 {
  %4 = icmp eq ptr %0, null       ; !arr
  br i1 %4, label %21, label %5

5:                                                ; preds = %3
  %6 = getelementptr inbounds i8, ptr %0, i64 16
  %7 = load i64, ptr %6, align 8, !tbaa !13
  %8 = icmp eq i64 %7, 0       ; !count
  br i1 %8, label %21, label %9

9:                                                ; preds = %5
  %10 = getelementptr inbounds i8, ptr %0, i64 24
  %11 = load i64, ptr %10, align 8, !tbaa !5
  %12 = icmp eq i64 %11, 0        ; !cap
  br i1 %12, label %21, label %13

13:                                               ; preds = %9
  %14 = icmp ugt i64 %7, %2       ; boundcheck
  br i1 %14, label %15, label %21

15:                                               ; preds = %13
  %16 = load ptr, ptr %0, align 8, !tbaa !11
  %17 = getelementptr inbounds i8, ptr %0, i64 8
  %18 = load i64, ptr %17, align 8, !tbaa !12
  %19 = mul i64 %18, %2
  %20 = getelementptr inbounds i8, ptr %16, i64 %19
  tail call void @llvm.memcpy.p0.p0.i64(ptr align 1 %20, ptr align 1 %1, i64 %18, i1 false)
  br label %21

21:                                               ; preds = %13, %3, %5, %9, %15
  %22 = phi i32 [ 0, %15 ], [ -3, %9 ], [ -3, %5 ], [ -3, %3 ], [ -5, %13 ]
  ret i32 %22
}

; Function Attrs: nounwind uwtable
define dso_local range(i32 -10, 1) i32 @bytecopy(ptr noundef readonly %0, ptr noundef %1) local_unnamed_addr #2 {
  %3 = icmp ne ptr %0, null
  %4 = icmp ne ptr %1, null
  %5 = and i1 %3, %4
  br i1 %5, label %6, label %44

6:                                                ; preds = %2
  %7 = load ptr, ptr %0, align 8, !tbaa !11
  %8 = icmp eq ptr %7, null
  br i1 %8, label %44, label %9

9:                                                ; preds = %6
  %10 = getelementptr inbounds i8, ptr %0, i64 16
  %11 = getelementptr inbounds i8, ptr %1, i64 24
  %12 = load i64, ptr %11, align 8, !tbaa !5
  %13 = icmp eq i64 %12, 0
  br i1 %13, label %44, label %14

14:                                               ; preds = %9
  %15 = load i64, ptr %10, align 8, !tbaa !13
  %16 = getelementptr inbounds i8, ptr %1, i64 16
  %17 = load i64, ptr %16, align 8, !tbaa !13
  %18 = add i64 %17, %15
  %19 = icmp ugt i64 %18, %12
  br i1 %19, label %20, label %32

20:                                               ; preds = %14, %20
  %21 = phi i64 [ %23, %20 ], [ %12, %14 ]
  %22 = icmp ult i64 %21, %18
  %23 = shl i64 %21, 1
  br i1 %22, label %20, label %24, !llvm.loop !14

24:                                               ; preds = %20
  %25 = load ptr, ptr %1, align 8, !tbaa !11
  %26 = getelementptr inbounds i8, ptr %1, i64 8
  %27 = load i64, ptr %26, align 8, !tbaa !12
  %28 = mul i64 %27, %21
  %29 = tail call ptr @realloc(ptr noundef %25, i64 noundef %28) #14
  %30 = icmp eq ptr %29, null
  br i1 %30, label %44, label %31

31:                                               ; preds = %24
  store ptr %29, ptr %1, align 8, !tbaa !11
  store i64 %21, ptr %11, align 8, !tbaa !5
  br label %32

32:                                               ; preds = %14, %31
  %33 = getelementptr inbounds i8, ptr %0, i64 8
  %34 = load i64, ptr %33, align 8, !tbaa !12
  %35 = getelementptr inbounds i8, ptr %1, i64 8
  %36 = load i64, ptr %35, align 8, !tbaa !12
  %37 = icmp eq i64 %34, %36
  br i1 %37, label %38, label %44

38:                                               ; preds = %32
  %39 = load ptr, ptr %1, align 8, !tbaa !11
  %40 = load ptr, ptr %0, align 8, !tbaa !11
  %41 = load i64, ptr %10, align 8, !tbaa !13
  %42 = mul i64 %41, %34
  tail call void @llvm.memcpy.p0.p0.i64(ptr align 1 %39, ptr align 1 %40, i64 %42, i1 false)
  %43 = load i64, ptr %10, align 8, !tbaa !13
  store i64 %43, ptr %16, align 8, !tbaa !13
  br label %44

44:                                               ; preds = %24, %9, %32, %2, %6, %38
  %45 = phi i32 [ 0, %38 ], [ -2, %6 ], [ -2, %2 ], [ -10, %32 ], [ -4, %9 ], [ -4, %24 ]
  ret i32 %45
}

; Function Attrs: nounwind uwtable
define dso_local range(i32 -4, 1) i32 @merge(ptr noundef %0, ptr noundef readonly %1) local_unnamed_addr #2 {
  %3 = icmp eq ptr %0, null
  br i1 %3, label %52, label %4

4:                                                ; preds = %2
  %5 = load ptr, ptr %0, align 8, !tbaa !11
  %6 = icmp ne ptr %5, null
  %7 = icmp ne ptr %1, null
  %8 = and i1 %7, %6
  br i1 %8, label %9, label %52

9:                                                ; preds = %4
  %10 = load ptr, ptr %1, align 8, !tbaa !11
  %11 = icmp eq ptr %10, null
  br i1 %11, label %52, label %12

12:                                               ; preds = %9
  %13 = getelementptr inbounds i8, ptr %1, i64 16
  %14 = getelementptr inbounds i8, ptr %0, i64 24
  %15 = load i64, ptr %14, align 8, !tbaa !5
  %16 = icmp eq i64 %15, 0
  br i1 %16, label %52, label %17

17:                                               ; preds = %12
  %18 = load i64, ptr %13, align 8, !tbaa !13
  %19 = getelementptr inbounds i8, ptr %0, i64 16
  %20 = load i64, ptr %19, align 8, !tbaa !13
  %21 = add i64 %20, %18
  %22 = icmp ugt i64 %21, %15
  br i1 %22, label %23, label %37

23:                                               ; preds = %17, %23
  %24 = phi i64 [ %26, %23 ], [ %15, %17 ]
  %25 = icmp ult i64 %24, %21
  %26 = shl i64 %24, 1
  br i1 %25, label %23, label %27, !llvm.loop !14

27:                                               ; preds = %23
  %28 = getelementptr inbounds i8, ptr %0, i64 8
  %29 = load i64, ptr %28, align 8, !tbaa !12
  %30 = mul i64 %29, %24
  %31 = tail call ptr @realloc(ptr noundef nonnull %5, i64 noundef %30) #14
  %32 = icmp eq ptr %31, null
  br i1 %32, label %52, label %33

33:                                               ; preds = %27
  store ptr %31, ptr %0, align 8, !tbaa !11
  store i64 %24, ptr %14, align 8, !tbaa !5
  %34 = load i64, ptr %19, align 8, !tbaa !13
  %35 = load ptr, ptr %1, align 8, !tbaa !11
  %36 = load i64, ptr %13, align 8, !tbaa !13
  br label %37

37:                                               ; preds = %17, %33
  %38 = phi i64 [ %18, %17 ], [ %36, %33 ]
  %39 = phi ptr [ %10, %17 ], [ %35, %33 ]
  %40 = phi i64 [ %20, %17 ], [ %34, %33 ]
  %41 = phi ptr [ %5, %17 ], [ %31, %33 ]
  %42 = getelementptr inbounds i8, ptr %0, i64 8
  %43 = load i64, ptr %42, align 8, !tbaa !12
  %44 = mul i64 %43, %40
  %45 = getelementptr inbounds i8, ptr %41, i64 %44
  %46 = getelementptr inbounds i8, ptr %1, i64 8
  %47 = load i64, ptr %46, align 8, !tbaa !12
  %48 = mul i64 %47, %38
  tail call void @llvm.memcpy.p0.p0.i64(ptr nonnull align 1 %45, ptr align 1 %39, i64 %48, i1 false)
  %49 = load i64, ptr %13, align 8, !tbaa !13
  %50 = load i64, ptr %19, align 8, !tbaa !13
  %51 = add i64 %50, %49
  store i64 %51, ptr %19, align 8, !tbaa !13
  br label %52

52:                                               ; preds = %27, %12, %2, %4, %9, %37
  %53 = phi i32 [ 0, %37 ], [ -3, %9 ], [ -3, %4 ], [ -3, %2 ], [ -4, %12 ], [ -4, %27 ]
  ret i32 %53
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(readwrite, inaccessiblemem: none) uwtable
define dso_local range(i32 -3, 1) i32 @export2stack(ptr noundef readonly %0, ptr nocapture noundef readonly %1) local_unnamed_addr #7 {
  %3 = icmp eq ptr %0, null
  br i1 %3, label %14, label %4

4:                                                ; preds = %2
  %5 = load ptr, ptr %0, align 8, !tbaa !11
  %6 = icmp eq ptr %5, null
  br i1 %6, label %14, label %7

7:                                                ; preds = %4
  %8 = load ptr, ptr %1, align 8, !tbaa !16
  %9 = getelementptr inbounds i8, ptr %0, i64 16
  %10 = load i64, ptr %9, align 8, !tbaa !13
  %11 = getelementptr inbounds i8, ptr %0, i64 8
  %12 = load i64, ptr %11, align 8, !tbaa !12
  %13 = mul i64 %12, %10
  tail call void @llvm.memcpy.p0.p0.i64(ptr align 1 %8, ptr nonnull align 1 %5, i64 %13, i1 false)
  br label %14

14:                                               ; preds = %2, %4, %7
  %15 = phi i32 [ 0, %7 ], [ -3, %4 ], [ -3, %2 ]
  ret i32 %15
}

; Function Attrs: nounwind uwtable
define dso_local range(i32 -6, 1) i32 @insertidx(ptr noundef %0, ptr nocapture noundef readonly %1, i64 noundef %2) local_unnamed_addr #2 {
  %4 = icmp eq ptr %0, null
  br i1 %4, label %58, label %5

5:                                                ; preds = %3
  %6 = load ptr, ptr %0, align 8, !tbaa !11
  %7 = icmp eq ptr %6, null
  br i1 %7, label %58, label %8

8:                                                ; preds = %5
  %9 = getelementptr inbounds i8, ptr %0, i64 16
  %10 = load i64, ptr %9, align 8, !tbaa !13
  %11 = icmp eq i64 %10, -1
  br i1 %11, label %58, label %12

12:                                               ; preds = %8
  %13 = icmp ugt i64 %10, %2
  br i1 %13, label %14, label %58

14:                                               ; preds = %12
  %15 = getelementptr inbounds i8, ptr %0, i64 24
  %16 = load i64, ptr %15, align 8, !tbaa !5
  %17 = icmp eq i64 %10, %16
  br i1 %17, label %18, label %30

18:                                               ; preds = %14, %18
  %19 = phi i64 [ %21, %18 ], [ %10, %14 ]
  %20 = icmp ugt i64 %19, %10
  %21 = shl i64 %19, 1
  br i1 %20, label %22, label %18, !llvm.loop !14

22:                                               ; preds = %18
  %23 = getelementptr inbounds i8, ptr %0, i64 8
  %24 = load i64, ptr %23, align 8, !tbaa !12
  %25 = mul i64 %24, %19
  %26 = tail call ptr @realloc(ptr noundef nonnull %6, i64 noundef %25) #14
  %27 = icmp eq ptr %26, null
  br i1 %27, label %58, label %28

28:                                               ; preds = %22
  store ptr %26, ptr %0, align 8, !tbaa !11
  store i64 %19, ptr %15, align 8, !tbaa !5
  %29 = load i64, ptr %9, align 8, !tbaa !13
  br label %30

30:                                               ; preds = %28, %14
  %31 = phi i64 [ %29, %28 ], [ %10, %14 ]
  %32 = phi ptr [ %26, %28 ], [ %6, %14 ]
  %33 = add i64 %2, 1
  %34 = getelementptr inbounds i8, ptr %0, i64 8
  %35 = load i64, ptr %34, align 8, !tbaa !12
  %36 = mul i64 %35, %33
  %37 = getelementptr inbounds i8, ptr %32, i64 %36
  %38 = mul i64 %35, %2
  %39 = getelementptr inbounds i8, ptr %32, i64 %38
  %40 = sub i64 %31, %2
  %41 = mul i64 %40, %35
  tail call void @llvm.memmove.p0.p0.i64(ptr nonnull align 1 %37, ptr nonnull align 1 %39, i64 %41, i1 false)
  %42 = load i64, ptr %9, align 8, !tbaa !13
  %43 = icmp eq i64 %42, 0
  br i1 %43, label %55, label %44

44:                                               ; preds = %30
  %45 = load i64, ptr %15, align 8, !tbaa !5
  %46 = icmp ne i64 %45, 0
  %47 = icmp ugt i64 %42, %2
  %48 = and i1 %47, %46
  br i1 %48, label %49, label %55

49:                                               ; preds = %44
  %50 = load ptr, ptr %0, align 8, !tbaa !11
  %51 = load i64, ptr %34, align 8, !tbaa !12
  %52 = mul i64 %51, %2
  %53 = getelementptr inbounds i8, ptr %50, i64 %52
  tail call void @llvm.memcpy.p0.p0.i64(ptr align 1 %53, ptr readonly align 1 %1, i64 %51, i1 false)
  %54 = load i64, ptr %9, align 8, !tbaa !13
  br label %55

55:                                               ; preds = %30, %44, %49
  %56 = phi i64 [ 0, %30 ], [ %42, %44 ], [ %54, %49 ]
  %57 = add i64 %56, 1
  store i64 %57, ptr %9, align 8, !tbaa !13
  br label %58

58:                                               ; preds = %22, %12, %8, %3, %5, %55
  %59 = phi i32 [ 0, %55 ], [ -3, %5 ], [ -3, %3 ], [ -6, %8 ], [ -5, %12 ], [ -4, %22 ]
  ret i32 %59
}

; Function Attrs: mustprogress nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memmove.p0.p0.i64(ptr nocapture writeonly, ptr nocapture readonly, i64, i1 immarg) #4

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(readwrite, inaccessiblemem: none) uwtable
define dso_local range(i32 -5, 1) i32 @removeidx(ptr noundef %0, i64 noundef %1) local_unnamed_addr #7 {
  %3 = icmp eq ptr %0, null
  br i1 %3, label %26, label %4

4:                                                ; preds = %2
  %5 = load ptr, ptr %0, align 8, !tbaa !11
  %6 = icmp eq ptr %5, null
  br i1 %6, label %26, label %7

7:                                                ; preds = %4
  %8 = getelementptr inbounds i8, ptr %0, i64 16
  %9 = load i64, ptr %8, align 8, !tbaa !13
  %10 = icmp eq i64 %9, 0
  br i1 %10, label %26, label %11

11:                                               ; preds = %7
  %12 = icmp ugt i64 %9, %1
  br i1 %12, label %13, label %26

13:                                               ; preds = %11
  %14 = getelementptr inbounds i8, ptr %0, i64 8
  %15 = load i64, ptr %14, align 8, !tbaa !12
  %16 = mul i64 %15, %1
  %17 = getelementptr inbounds i8, ptr %5, i64 %16
  %18 = add nuw i64 %1, 1
  %19 = mul i64 %15, %18
  %20 = getelementptr inbounds i8, ptr %5, i64 %19
  %21 = xor i64 %1, -1
  %22 = add i64 %9, %21
  %23 = mul i64 %15, %22
  tail call void @llvm.memmove.p0.p0.i64(ptr nonnull align 1 %17, ptr nonnull align 1 %20, i64 %23, i1 false)
  %24 = load i64, ptr %8, align 8, !tbaa !13
  %25 = add i64 %24, -1
  store i64 %25, ptr %8, align 8, !tbaa !13
  br label %26

26:                                               ; preds = %11, %2, %4, %7, %13
  %27 = phi i32 [ 0, %13 ], [ -3, %7 ], [ -3, %4 ], [ -3, %2 ], [ -5, %11 ]
  ret i32 %27
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: readwrite) uwtable
define dso_local range(i32 -2, 1) i32 @clearArr(ptr noundef %0) local_unnamed_addr #8 {
  %2 = icmp eq ptr %0, null
  br i1 %2, label %7, label %3

3:                                                ; preds = %1
  %4 = load ptr, ptr %0, align 8, !tbaa !11
  %5 = icmp eq ptr %4, null
  br i1 %5, label %7, label %6

6:                                                ; preds = %3
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 8 dereferenceable(24) %0, i8 0, i64 24, i1 false)
  br label %7

7:                                                ; preds = %1, %3, %6
  %8 = phi i32 [ 0, %6 ], [ -2, %3 ], [ -2, %1 ]
  ret i32 %8
}

; Function Attrs: mustprogress nounwind willreturn uwtable
define dso_local range(i32 -2, 1) i32 @freeArr(ptr nocapture noundef %0) local_unnamed_addr #9 {
  %2 = load ptr, ptr %0, align 8, !tbaa !11
  %3 = icmp eq ptr %2, null
  br i1 %3, label %5, label %4

4:                                                ; preds = %1
  tail call void @free(ptr noundef nonnull %2) #15
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 8 dereferenceable(32) %0, i8 0, i64 32, i1 false)
  br label %5

5:                                                ; preds = %1, %4
  %6 = phi i32 [ 0, %4 ], [ -2, %1 ]
  ret i32 %6
}

; Function Attrs: mustprogress nounwind willreturn allockind("free") memory(argmem: readwrite, inaccessiblemem: readwrite)
declare void @free(ptr allocptr nocapture noundef) local_unnamed_addr #10

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare { i64, i1 } @llvm.umul.with.overflow.i64(i64, i64) #11

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr nocapture writeonly, i8, i64, i1 immarg) #12

attributes #0 = { mustprogress nofree nounwind willreturn memory(argmem: readwrite, inaccessiblemem: readwrite) uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { mustprogress nofree nounwind willreturn allockind("alloc,uninitialized") allocsize(0) memory(inaccessiblemem: readwrite) "alloc-family"="malloc" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #2 = { nounwind uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #3 = { mustprogress nounwind willreturn allockind("realloc") allocsize(1) memory(argmem: readwrite, inaccessiblemem: readwrite) "alloc-family"="malloc" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #4 = { mustprogress nocallback nofree nounwind willreturn memory(argmem: readwrite) }
attributes #5 = { mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read) uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #6 = { mustprogress nofree norecurse nosync nounwind willreturn memory(none) uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #7 = { mustprogress nofree norecurse nosync nounwind willreturn memory(readwrite, inaccessiblemem: none) uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #8 = { mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: readwrite) uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #9 = { mustprogress nounwind willreturn uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #10 = { mustprogress nounwind willreturn allockind("free") memory(argmem: readwrite, inaccessiblemem: readwrite) "alloc-family"="malloc" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #11 = { nocallback nofree nosync nounwind speculatable willreturn memory(none) }
attributes #12 = { nocallback nofree nounwind willreturn memory(argmem: write) }
attributes #13 = { nounwind allocsize(0) }
attributes #14 = { nounwind allocsize(1) }
attributes #15 = { nounwind }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 2}
!4 = !{!"Debian clang version 19.1.7 (3+b1)"}
!5 = !{!6, !10, i64 24}
!6 = !{!"", !7, i64 0, !10, i64 8, !10, i64 16, !10, i64 24}
!7 = !{!"any pointer", !8, i64 0}
!8 = !{!"omnipotent char", !9, i64 0}
!9 = !{!"Simple C/C++ TBAA"}
!10 = !{!"long", !8, i64 0}
!11 = !{!6, !7, i64 0}
!12 = !{!6, !10, i64 8}
!13 = !{!6, !10, i64 16}
!14 = distinct !{!14, !15}
!15 = !{!"llvm.loop.mustprogress"}
!16 = !{!7, !7, i64 0}
