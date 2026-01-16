; ModuleID = 'dynarr/dynarr.c'
source_filename = "dynarr/dynarr.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; Function Attrs: mustprogress nofree nounwind willreturn memory(argmem: readwrite, inaccessiblemem: readwrite) uwtable
define dso_local range(i32 -7, 1) i32 @init(ptr nocapture noundef %0, i64 noundef %1, i64 noundef %2) local_unnamed_addr #0 {
  %4 = tail call { i64, i1 } @llvm.umul.with.overflow.i64(i64 %1, i64 %2)
  %5 = extractvalue { i64, i1 } %4, 1
  br i1 %5, label %17, label %6

6:                                                ; preds = %3
  %7 = getelementptr inbounds i8, ptr %0, i64 24
  %8 = load i64, ptr %7, align 8, !tbaa !5
  %9 = icmp eq i64 %8, 0
  br i1 %9, label %10, label %17

10:                                               ; preds = %6
  %11 = mul i64 %2, %1
  %12 = tail call noalias ptr @malloc(i64 noundef %11) #13
  %13 = icmp eq ptr %12, null
  br i1 %13, label %17, label %14

14:                                               ; preds = %10
  store ptr %12, ptr %0, align 8, !tbaa !11
  %15 = getelementptr inbounds i8, ptr %0, i64 8
  store i64 %1, ptr %15, align 8, !tbaa !12
  store i64 %2, ptr %7, align 8, !tbaa !5
  %16 = getelementptr inbounds i8, ptr %0, i64 16
  store i64 0, ptr %16, align 8, !tbaa !13
  br label %17

17:                                               ; preds = %14, %10, %6, %3
  %18 = phi i32 [ -6, %3 ], [ -7, %6 ], [ 0, %14 ], [ -1, %10 ]
  ret i32 %18
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
  br i1 %3, label %38, label %4

4:                                                ; preds = %2
  %5 = getelementptr inbounds i8, ptr %0, i64 8
  %6 = load i64, ptr %5, align 8, !tbaa !12
  %7 = icmp eq i64 %6, 0
  br i1 %7, label %38, label %8

8:                                                ; preds = %4
  %9 = getelementptr inbounds i8, ptr %0, i64 16
  %10 = load i64, ptr %9, align 8, !tbaa !13
  %11 = add i64 %10, 1
  %12 = getelementptr inbounds i8, ptr %0, i64 24
  %13 = load i64, ptr %12, align 8, !tbaa !5
  %14 = icmp ugt i64 %11, %13
  br i1 %14, label %15, label %30

15:                                               ; preds = %8
  %16 = icmp eq i64 %13, 0
  br i1 %16, label %27, label %17

17:                                               ; preds = %15, %17
  %18 = phi i64 [ %20, %17 ], [ %13, %15 ]
  %19 = icmp ult i64 %18, %11
  %20 = shl i64 %18, 1
  br i1 %19, label %17, label %21, !llvm.loop !14

21:                                               ; preds = %17
  %22 = load ptr, ptr %0, align 8, !tbaa !11
  %23 = mul i64 %18, %6
  %24 = tail call ptr @realloc(ptr noundef %22, i64 noundef %23) #14
  %25 = icmp eq ptr %24, null
  br i1 %25, label %27, label %26

26:                                               ; preds = %21
  store ptr %24, ptr %0, align 8, !tbaa !11
  store i64 %18, ptr %12, align 8, !tbaa !5
  br label %27

27:                                               ; preds = %15, %21, %26
  %28 = phi i1 [ false, %15 ], [ true, %26 ], [ false, %21 ]
  %29 = phi i32 [ -3, %15 ], [ 0, %26 ], [ -4, %21 ]
  br i1 %28, label %30, label %38

30:                                               ; preds = %27, %8
  %31 = load ptr, ptr %0, align 8, !tbaa !11
  %32 = load i64, ptr %9, align 8, !tbaa !13
  %33 = load i64, ptr %5, align 8, !tbaa !12
  %34 = mul i64 %33, %32
  %35 = getelementptr inbounds i8, ptr %31, i64 %34
  tail call void @llvm.memcpy.p0.p0.i64(ptr align 1 %35, ptr align 1 %1, i64 %33, i1 false)
  %36 = load i64, ptr %9, align 8, !tbaa !13
  %37 = add i64 %36, 1
  store i64 %37, ptr %9, align 8, !tbaa !13
  br label %38

38:                                               ; preds = %27, %4, %2, %30
  %39 = phi i32 [ %29, %27 ], [ 0, %30 ], [ -2, %2 ], [ -3, %4 ]
  ret i32 %39
}

; Function Attrs: mustprogress nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias nocapture writeonly, ptr noalias nocapture readonly, i64, i1 immarg) #4

; Function Attrs: nounwind uwtable
define dso_local noundef i32 @pushMany(ptr noundef %0, ptr nocapture noundef readonly %1, i64 noundef %2) local_unnamed_addr #2 {
  %4 = icmp eq ptr %0, null
  br i1 %4, label %41, label %5

5:                                                ; preds = %3
  %6 = getelementptr inbounds i8, ptr %0, i64 8
  %7 = load i64, ptr %6, align 8, !tbaa !12
  %8 = icmp eq i64 %7, 0
  br i1 %8, label %41, label %9

9:                                                ; preds = %5
  %10 = getelementptr inbounds i8, ptr %0, i64 24
  %11 = load i64, ptr %10, align 8, !tbaa !5
  %12 = icmp eq i64 %11, 0
  br i1 %12, label %28, label %13

13:                                               ; preds = %9
  %14 = getelementptr inbounds i8, ptr %0, i64 16
  %15 = load i64, ptr %14, align 8, !tbaa !13
  %16 = add i64 %15, %2
  %17 = icmp ugt i64 %16, %11
  br i1 %17, label %18, label %28

18:                                               ; preds = %13, %18
  %19 = phi i64 [ %21, %18 ], [ %11, %13 ]
  %20 = icmp ult i64 %19, %16
  %21 = shl i64 %19, 1
  br i1 %20, label %18, label %22, !llvm.loop !14

22:                                               ; preds = %18
  %23 = load ptr, ptr %0, align 8, !tbaa !11
  %24 = mul i64 %19, %7
  %25 = tail call ptr @realloc(ptr noundef %23, i64 noundef %24) #14
  %26 = icmp eq ptr %25, null
  br i1 %26, label %28, label %27

27:                                               ; preds = %22
  store ptr %25, ptr %0, align 8, !tbaa !11
  store i64 %19, ptr %10, align 8, !tbaa !5
  br label %28

28:                                               ; preds = %9, %13, %22, %27
  %29 = phi i1 [ false, %9 ], [ true, %13 ], [ true, %27 ], [ false, %22 ]
  %30 = phi i32 [ -3, %9 ], [ 0, %13 ], [ 0, %27 ], [ -4, %22 ]
  br i1 %29, label %31, label %41

31:                                               ; preds = %28
  %32 = load ptr, ptr %0, align 8, !tbaa !11
  %33 = getelementptr inbounds i8, ptr %0, i64 16
  %34 = load i64, ptr %33, align 8, !tbaa !13
  %35 = load i64, ptr %6, align 8, !tbaa !12
  %36 = mul i64 %35, %34
  %37 = getelementptr inbounds i8, ptr %32, i64 %36
  %38 = mul i64 %35, %2
  tail call void @llvm.memcpy.p0.p0.i64(ptr align 1 %37, ptr align 1 %1, i64 %38, i1 false)
  %39 = load i64, ptr %33, align 8, !tbaa !13
  %40 = add i64 %39, %2
  store i64 %40, ptr %33, align 8, !tbaa !13
  br label %41

41:                                               ; preds = %31, %28, %5, %3
  %42 = phi i32 [ -2, %3 ], [ -3, %5 ], [ 0, %31 ], [ %30, %28 ]
  ret i32 %42
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
  br i1 %10, label %11, label %16

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

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none) uwtable
define dso_local range(i32 0, 2) i32 @boundcheck(i64 noundef %0, i64 noundef %1, i64 noundef %2) local_unnamed_addr #6 {
  %4 = icmp uge i64 %2, %0
  %5 = icmp ult i64 %2, %1
  %6 = and i1 %4, %5
  %7 = zext i1 %6 to i32
  ret i32 %7
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(readwrite, inaccessiblemem: none) uwtable
define dso_local range(i32 -5, 1) i32 @setidx(ptr nocapture noundef readonly %0, ptr nocapture noundef readonly %1, i64 noundef %2) local_unnamed_addr #7 {
  %4 = getelementptr inbounds i8, ptr %0, i64 16
  %5 = load i64, ptr %4, align 8, !tbaa !13
  %6 = icmp eq i64 %5, 0
  br i1 %6, label %15, label %7

7:                                                ; preds = %3
  %8 = icmp ugt i64 %5, %2
  br i1 %8, label %9, label %15

9:                                                ; preds = %7
  %10 = load ptr, ptr %0, align 8, !tbaa !11
  %11 = getelementptr inbounds i8, ptr %0, i64 8
  %12 = load i64, ptr %11, align 8, !tbaa !12
  %13 = mul i64 %12, %2
  %14 = getelementptr inbounds i8, ptr %10, i64 %13
  tail call void @llvm.memcpy.p0.p0.i64(ptr align 1 %14, ptr align 1 %1, i64 %12, i1 false)
  br label %15

15:                                               ; preds = %7, %3, %9
  %16 = phi i32 [ 0, %9 ], [ -2, %3 ], [ -5, %7 ]
  ret i32 %16
}

; Function Attrs: nounwind uwtable
define dso_local range(i32 -10, 1) i32 @bytecopy(ptr noundef readonly %0, ptr noundef %1) local_unnamed_addr #2 {
  %3 = icmp ne ptr %0, null
  %4 = icmp ne ptr %1, null
  %5 = and i1 %3, %4
  br i1 %5, label %6, label %45

6:                                                ; preds = %2
  %7 = load ptr, ptr %0, align 8, !tbaa !11
  %8 = icmp eq ptr %7, null
  br i1 %8, label %45, label %9

9:                                                ; preds = %6
  %10 = getelementptr inbounds i8, ptr %0, i64 16
  %11 = getelementptr inbounds i8, ptr %1, i64 24
  %12 = load i64, ptr %11, align 8, !tbaa !5
  %13 = icmp eq i64 %12, 0
  br i1 %13, label %45, label %14

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
  br i1 %30, label %45, label %31

31:                                               ; preds = %24
  store ptr %29, ptr %1, align 8, !tbaa !11
  store i64 %21, ptr %11, align 8, !tbaa !5
  br label %32

32:                                               ; preds = %31, %14
  %33 = getelementptr inbounds i8, ptr %0, i64 8
  %34 = load i64, ptr %33, align 8, !tbaa !12
  %35 = getelementptr inbounds i8, ptr %1, i64 8
  %36 = load i64, ptr %35, align 8, !tbaa !12
  %37 = icmp eq i64 %34, %36
  br i1 %37, label %38, label %45

38:                                               ; preds = %32
  %39 = load ptr, ptr %1, align 8, !tbaa !11
  %40 = load ptr, ptr %0, align 8, !tbaa !11
  %41 = load i64, ptr %10, align 8, !tbaa !13
  %42 = mul i64 %41, %34
  tail call void @llvm.memcpy.p0.p0.i64(ptr align 1 %39, ptr align 1 %40, i64 %42, i1 false)
  %43 = load i64, ptr %10, align 8, !tbaa !13
  %44 = getelementptr inbounds i8, ptr %1, i64 16
  store i64 %43, ptr %44, align 8, !tbaa !13
  br label %45

45:                                               ; preds = %9, %24, %32, %2, %6, %38
  %46 = phi i32 [ 0, %38 ], [ -2, %6 ], [ -2, %2 ], [ -10, %32 ], [ -4, %24 ], [ -4, %9 ]
  ret i32 %46
}

; Function Attrs: nounwind uwtable
define dso_local range(i32 -4, 1) i32 @merge(ptr noundef %0, ptr noundef readonly %1) local_unnamed_addr #2 {
  %3 = icmp eq ptr %0, null
  br i1 %3, label %50, label %4

4:                                                ; preds = %2
  %5 = load ptr, ptr %0, align 8, !tbaa !11
  %6 = icmp ne ptr %5, null
  %7 = icmp ne ptr %1, null
  %8 = and i1 %7, %6
  br i1 %8, label %9, label %50

9:                                                ; preds = %4
  %10 = load ptr, ptr %1, align 8, !tbaa !11
  %11 = icmp eq ptr %10, null
  br i1 %11, label %50, label %12

12:                                               ; preds = %9
  %13 = getelementptr inbounds i8, ptr %1, i64 16
  %14 = getelementptr inbounds i8, ptr %0, i64 24
  %15 = load i64, ptr %14, align 8, !tbaa !5
  %16 = icmp eq i64 %15, 0
  br i1 %16, label %50, label %17

17:                                               ; preds = %12
  %18 = load i64, ptr %13, align 8, !tbaa !13
  %19 = getelementptr inbounds i8, ptr %0, i64 16
  %20 = load i64, ptr %19, align 8, !tbaa !13
  %21 = add i64 %20, %18
  %22 = icmp ugt i64 %21, %15
  br i1 %22, label %23, label %34

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
  br i1 %32, label %50, label %33

33:                                               ; preds = %27
  store ptr %31, ptr %0, align 8, !tbaa !11
  store i64 %24, ptr %14, align 8, !tbaa !5
  br label %34

34:                                               ; preds = %33, %17
  %35 = load ptr, ptr %0, align 8, !tbaa !11
  %36 = getelementptr inbounds i8, ptr %0, i64 16
  %37 = load i64, ptr %36, align 8, !tbaa !13
  %38 = getelementptr inbounds i8, ptr %0, i64 8
  %39 = load i64, ptr %38, align 8, !tbaa !12
  %40 = mul i64 %39, %37
  %41 = getelementptr inbounds i8, ptr %35, i64 %40
  %42 = load ptr, ptr %1, align 8, !tbaa !11
  %43 = load i64, ptr %13, align 8, !tbaa !13
  %44 = getelementptr inbounds i8, ptr %1, i64 8
  %45 = load i64, ptr %44, align 8, !tbaa !12
  %46 = mul i64 %45, %43
  tail call void @llvm.memcpy.p0.p0.i64(ptr align 1 %41, ptr align 1 %42, i64 %46, i1 false)
  %47 = load i64, ptr %13, align 8, !tbaa !13
  %48 = load i64, ptr %36, align 8, !tbaa !13
  %49 = add i64 %48, %47
  store i64 %49, ptr %36, align 8, !tbaa !13
  br label %50

50:                                               ; preds = %12, %27, %2, %4, %9, %34
  %51 = phi i32 [ 0, %34 ], [ -2, %9 ], [ -2, %4 ], [ -2, %2 ], [ -4, %27 ], [ -4, %12 ]
  ret i32 %51
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(readwrite, inaccessiblemem: none) uwtable
define dso_local range(i32 -2, 1) i32 @export2stack(ptr noundef readonly %0, ptr nocapture noundef readonly %1) local_unnamed_addr #7 {
  %3 = icmp eq ptr %0, null
  br i1 %3, label %14, label %4

4:                                                ; preds = %2
  %5 = load ptr, ptr %0, align 8, !tbaa !11
  %6 = icmp eq ptr %5, null
  br i1 %6, label %14, label %7

7:                                                ; preds = %4
  %8 = load ptr, ptr %1, align 8, !tbaa !17
  %9 = getelementptr inbounds i8, ptr %0, i64 16
  %10 = load i64, ptr %9, align 8, !tbaa !13
  %11 = getelementptr inbounds i8, ptr %0, i64 8
  %12 = load i64, ptr %11, align 8, !tbaa !12
  %13 = mul i64 %12, %10
  tail call void @llvm.memcpy.p0.p0.i64(ptr align 1 %8, ptr nonnull align 1 %5, i64 %13, i1 false)
  br label %14

14:                                               ; preds = %2, %4, %7
  %15 = phi i32 [ 0, %7 ], [ -2, %4 ], [ -2, %2 ]
  ret i32 %15
}

; Function Attrs: nounwind uwtable
define dso_local range(i32 -5, 1) i32 @insertidx(ptr noundef %0, ptr nocapture noundef readonly %1, i64 noundef %2) local_unnamed_addr #2 {
  %4 = icmp eq ptr %0, null
  br i1 %4, label %54, label %5

5:                                                ; preds = %3
  %6 = load ptr, ptr %0, align 8, !tbaa !11
  %7 = icmp eq ptr %6, null
  br i1 %7, label %54, label %8

8:                                                ; preds = %5
  %9 = getelementptr inbounds i8, ptr %0, i64 16
  %10 = load i64, ptr %9, align 8, !tbaa !13
  %11 = icmp ugt i64 %10, %2
  br i1 %11, label %12, label %54

12:                                               ; preds = %8
  %13 = getelementptr inbounds i8, ptr %0, i64 24
  %14 = load i64, ptr %13, align 8, !tbaa !5
  %15 = icmp eq i64 %10, %14
  br i1 %15, label %16, label %32

16:                                               ; preds = %12
  %17 = icmp eq i64 %14, 0
  br i1 %17, label %54, label %18

18:                                               ; preds = %16
  %19 = add i64 %10, 1
  %20 = icmp ugt i64 %19, %14
  br i1 %20, label %21, label %32

21:                                               ; preds = %18, %21
  %22 = phi i64 [ %24, %21 ], [ %14, %18 ]
  %23 = icmp ult i64 %22, %19
  %24 = shl i64 %22, 1
  br i1 %23, label %21, label %25, !llvm.loop !14

25:                                               ; preds = %21
  %26 = getelementptr inbounds i8, ptr %0, i64 8
  %27 = load i64, ptr %26, align 8, !tbaa !12
  %28 = mul i64 %27, %22
  %29 = tail call ptr @realloc(ptr noundef nonnull %6, i64 noundef %28) #14
  %30 = icmp eq ptr %29, null
  br i1 %30, label %54, label %31

31:                                               ; preds = %25
  store ptr %29, ptr %0, align 8, !tbaa !11
  store i64 %22, ptr %13, align 8, !tbaa !5
  br label %32

32:                                               ; preds = %31, %18, %12
  %33 = load ptr, ptr %0, align 8, !tbaa !11
  %34 = add i64 %2, 1
  %35 = getelementptr inbounds i8, ptr %0, i64 8
  %36 = load i64, ptr %35, align 8, !tbaa !12
  %37 = mul i64 %36, %34
  %38 = getelementptr inbounds i8, ptr %33, i64 %37
  %39 = mul i64 %36, %2
  %40 = getelementptr inbounds i8, ptr %33, i64 %39
  %41 = load i64, ptr %9, align 8, !tbaa !13
  %42 = sub i64 %41, %2
  %43 = mul i64 %42, %36
  tail call void @llvm.memmove.p0.p0.i64(ptr align 1 %38, ptr align 1 %40, i64 %43, i1 false)
  %44 = load i64, ptr %9, align 8, !tbaa !13
  %45 = icmp ugt i64 %44, %2
  br i1 %45, label %46, label %51

46:                                               ; preds = %32
  %47 = load ptr, ptr %0, align 8, !tbaa !11
  %48 = load i64, ptr %35, align 8, !tbaa !12
  %49 = mul i64 %48, %2
  %50 = getelementptr inbounds i8, ptr %47, i64 %49
  tail call void @llvm.memcpy.p0.p0.i64(ptr align 1 %50, ptr readonly align 1 %1, i64 %48, i1 false)
  br label %51

51:                                               ; preds = %32, %46
  %52 = load i64, ptr %9, align 8, !tbaa !13
  %53 = add i64 %52, 1
  store i64 %53, ptr %9, align 8, !tbaa !13
  br label %54

54:                                               ; preds = %16, %25, %8, %3, %5, %51
  %55 = phi i32 [ 0, %51 ], [ -2, %5 ], [ -2, %3 ], [ -5, %8 ], [ -4, %25 ], [ -4, %16 ]
  ret i32 %55
}

; Function Attrs: mustprogress nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memmove.p0.p0.i64(ptr nocapture writeonly, ptr nocapture readonly, i64, i1 immarg) #4

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(readwrite, inaccessiblemem: none) uwtable
define dso_local range(i32 -5, 1) i32 @removeidx(ptr noundef %0, i64 noundef %1) local_unnamed_addr #7 {
  %3 = icmp eq ptr %0, null
  br i1 %3, label %24, label %4

4:                                                ; preds = %2
  %5 = load ptr, ptr %0, align 8, !tbaa !11
  %6 = icmp eq ptr %5, null
  br i1 %6, label %24, label %7

7:                                                ; preds = %4
  %8 = getelementptr inbounds i8, ptr %0, i64 16
  %9 = load i64, ptr %8, align 8, !tbaa !13
  %10 = icmp ugt i64 %9, %1
  br i1 %10, label %11, label %24

11:                                               ; preds = %7
  %12 = getelementptr inbounds i8, ptr %0, i64 8
  %13 = load i64, ptr %12, align 8, !tbaa !12
  %14 = mul i64 %13, %1
  %15 = getelementptr inbounds i8, ptr %5, i64 %14
  %16 = add i64 %1, 1
  %17 = mul i64 %13, %16
  %18 = getelementptr inbounds i8, ptr %5, i64 %17
  %19 = xor i64 %1, -1
  %20 = add i64 %9, %19
  %21 = mul i64 %13, %20
  tail call void @llvm.memmove.p0.p0.i64(ptr nonnull align 1 %15, ptr nonnull align 1 %18, i64 %21, i1 false)
  %22 = load i64, ptr %8, align 8, !tbaa !13
  %23 = add i64 %22, -1
  store i64 %23, ptr %8, align 8, !tbaa !13
  br label %24

24:                                               ; preds = %7, %2, %4, %11
  %25 = phi i32 [ 0, %11 ], [ -2, %4 ], [ -2, %2 ], [ -5, %7 ]
  ret i32 %25
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
  tail call void @free(ptr noundef %2) #15
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
!14 = distinct !{!14, !15, !16}
!15 = !{!"llvm.loop.mustprogress"}
!16 = !{!"llvm.loop.unroll.disable"}
!17 = !{!7, !7, i64 0}
