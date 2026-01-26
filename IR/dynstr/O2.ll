; ModuleID = 'dynstr/dynstr.c'
source_filename = "dynstr/dynstr.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; Function Attrs: mustprogress nofree nounwind willreturn memory(write, argmem: readwrite, inaccessiblemem: readwrite) uwtable
define dso_local range(i32 -3, 1) i32 @init(ptr nocapture noundef %0, i64 noundef %1) local_unnamed_addr #0 {
  %3 = getelementptr inbounds i8, ptr %0, i64 16
  %4 = load i64, ptr %3, align 8, !tbaa !5
  %5 = icmp eq i64 %4, 0
  br i1 %5, label %6, label %13

6:                                                ; preds = %2
  %7 = icmp eq i64 %1, 0
  br i1 %7, label %13, label %8

8:                                                ; preds = %6
  %9 = tail call noalias ptr @malloc(i64 noundef %1) #22
  store ptr %9, ptr %0, align 8, !tbaa !11
  %10 = icmp eq ptr %9, null
  br i1 %10, label %13, label %11

11:                                               ; preds = %8
  %12 = getelementptr inbounds i8, ptr %0, i64 8
  store i64 0, ptr %12, align 8, !tbaa !12
  store i64 %1, ptr %3, align 8, !tbaa !5
  store i8 0, ptr %9, align 1, !tbaa !13
  br label %13

13:                                               ; preds = %8, %6, %2, %11
  %14 = phi i32 [ 0, %11 ], [ -1, %2 ], [ -2, %6 ], [ -3, %8 ]
  ret i32 %14
}

; Function Attrs: mustprogress nofree nounwind willreturn allockind("alloc,uninitialized") allocsize(0) memory(inaccessiblemem: readwrite)
declare noalias noundef ptr @malloc(i64 noundef) local_unnamed_addr #1

; Function Attrs: nounwind uwtable
define dso_local range(i32 -5, 1) i32 @extendCap(ptr noundef %0, i64 noundef %1) local_unnamed_addr #2 {
  %3 = icmp eq ptr %0, null
  br i1 %3, label %21, label %4

4:                                                ; preds = %2
  %5 = load ptr, ptr %0, align 8, !tbaa !11
  %6 = icmp eq ptr %5, null
  br i1 %6, label %21, label %7

7:                                                ; preds = %4
  %8 = getelementptr inbounds i8, ptr %0, i64 16
  %9 = load i64, ptr %8, align 8, !tbaa !5
  %10 = icmp ult i64 %9, %1
  br i1 %10, label %11, label %21

11:                                               ; preds = %7
  %12 = add i64 %1, 1
  br label %13

13:                                               ; preds = %13, %11
  %14 = phi i64 [ %16, %13 ], [ %9, %11 ]
  %15 = icmp ult i64 %14, %12
  %16 = shl i64 %14, 1
  br i1 %15, label %13, label %17, !llvm.loop !14

17:                                               ; preds = %13
  %18 = tail call ptr @realloc(ptr noundef nonnull %5, i64 noundef %14) #23
  %19 = icmp eq ptr %18, null
  br i1 %19, label %21, label %20

20:                                               ; preds = %17
  store ptr %18, ptr %0, align 8, !tbaa !11
  store i64 %14, ptr %8, align 8, !tbaa !5
  br label %21

21:                                               ; preds = %20, %17, %7, %2, %4
  %22 = phi i32 [ -4, %4 ], [ -4, %2 ], [ 0, %7 ], [ 0, %20 ], [ -5, %17 ]
  ret i32 %22
}

; Function Attrs: mustprogress nounwind willreturn allockind("realloc") allocsize(1) memory(argmem: readwrite, inaccessiblemem: readwrite)
declare noalias noundef ptr @realloc(ptr allocptr nocapture noundef, i64 noundef) local_unnamed_addr #3

; Function Attrs: nofree norecurse nosync nounwind memory(read, inaccessiblemem: none) uwtable
define dso_local i32 @lenstr(ptr noundef readonly %0) local_unnamed_addr #4 {
  %2 = icmp eq ptr %0, null
  br i1 %2, label %13, label %3

3:                                                ; preds = %1
  %4 = load i8, ptr %0, align 1, !tbaa !13
  %5 = icmp eq i8 %4, 0
  br i1 %5, label %13, label %6

6:                                                ; preds = %3, %6
  %7 = phi i32 [ %10, %6 ], [ 0, %3 ]
  %8 = phi ptr [ %9, %6 ], [ %0, %3 ]
  %9 = getelementptr inbounds i8, ptr %8, i64 1
  %10 = add nuw nsw i32 %7, 1
  %11 = load i8, ptr %9, align 1, !tbaa !13
  %12 = icmp eq i8 %11, 0
  br i1 %12, label %13, label %6, !llvm.loop !16

13:                                               ; preds = %6, %3, %1
  %14 = phi i32 [ -1, %1 ], [ 0, %3 ], [ %10, %6 ]
  ret i32 %14
}

; Function Attrs: nounwind uwtable
define dso_local range(i32 -6, 1) i32 @populate(ptr noundef %0, ptr noundef readonly %1) local_unnamed_addr #2 {
  %3 = icmp eq ptr %0, null
  br i1 %3, label %47, label %4

4:                                                ; preds = %2
  %5 = load ptr, ptr %0, align 8, !tbaa !11
  %6 = icmp eq ptr %5, null
  br i1 %6, label %47, label %7

7:                                                ; preds = %4
  %8 = icmp eq ptr %1, null
  br i1 %8, label %47, label %9

9:                                                ; preds = %7
  %10 = load i8, ptr %1, align 1, !tbaa !13
  %11 = icmp eq i8 %10, 0
  br i1 %11, label %21, label %12

12:                                               ; preds = %9, %12
  %13 = phi i32 [ %16, %12 ], [ 0, %9 ]
  %14 = phi ptr [ %15, %12 ], [ %1, %9 ]
  %15 = getelementptr inbounds i8, ptr %14, i64 1
  %16 = add nuw nsw i32 %13, 1
  %17 = load i8, ptr %15, align 1, !tbaa !13
  %18 = icmp eq i8 %17, 0
  br i1 %18, label %19, label %12, !llvm.loop !16

19:                                               ; preds = %12
  %20 = zext nneg i32 %16 to i64
  br label %21

21:                                               ; preds = %19, %9
  %22 = phi i64 [ 0, %9 ], [ %20, %19 ]
  %23 = getelementptr inbounds i8, ptr %0, i64 8
  %24 = load i64, ptr %23, align 8, !tbaa !12
  %25 = add i64 %24, %22
  %26 = add i64 %25, 1
  %27 = getelementptr inbounds i8, ptr %0, i64 16
  %28 = load i64, ptr %27, align 8, !tbaa !5
  %29 = icmp ult i64 %28, %26
  br i1 %29, label %30, label %41

30:                                               ; preds = %21
  %31 = add i64 %25, 2
  br label %32

32:                                               ; preds = %32, %30
  %33 = phi i64 [ %35, %32 ], [ %28, %30 ]
  %34 = icmp ult i64 %33, %31
  %35 = shl i64 %33, 1
  br i1 %34, label %32, label %36, !llvm.loop !14

36:                                               ; preds = %32
  %37 = tail call ptr @realloc(ptr noundef nonnull %5, i64 noundef %33) #23
  %38 = icmp eq ptr %37, null
  br i1 %38, label %47, label %39

39:                                               ; preds = %36
  store ptr %37, ptr %0, align 8, !tbaa !11
  store i64 %33, ptr %27, align 8, !tbaa !5
  %40 = load i64, ptr %23, align 8, !tbaa !12
  br label %41

41:                                               ; preds = %21, %39
  %42 = phi i64 [ %24, %21 ], [ %40, %39 ]
  %43 = phi ptr [ %5, %21 ], [ %37, %39 ]
  %44 = getelementptr inbounds i8, ptr %43, i64 %42
  tail call void @llvm.memcpy.p0.p0.i64(ptr nonnull align 1 %44, ptr nonnull align 1 %1, i64 %22, i1 false)
  store i64 %25, ptr %23, align 8, !tbaa !12
  %45 = load ptr, ptr %0, align 8, !tbaa !11
  %46 = getelementptr inbounds i8, ptr %45, i64 %25
  store i8 0, ptr %46, align 1, !tbaa !13
  br label %47

47:                                               ; preds = %36, %41, %7, %2, %4
  %48 = phi i32 [ -4, %4 ], [ -4, %2 ], [ -6, %7 ], [ 0, %41 ], [ -5, %36 ]
  ret i32 %48
}

; Function Attrs: mustprogress nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias nocapture writeonly, ptr noalias nocapture readonly, i64, i1 immarg) #5

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none) uwtable
define dso_local noundef range(i32 -7, 1) i32 @boundcheck(i64 noundef %0, i64 noundef %1, i64 noundef %2) local_unnamed_addr #6 {
  %4 = icmp uge i64 %2, %0
  %5 = icmp ult i64 %2, %1
  %6 = and i1 %4, %5
  %7 = select i1 %6, i32 0, i32 -7
  ret i32 %7
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: readwrite) uwtable
define dso_local range(i32 -7, 1) i32 @getstr(ptr noundef readonly %0, i64 noundef %1, ptr nocapture noundef writeonly %2) local_unnamed_addr #7 {
  %4 = icmp eq ptr %0, null
  br i1 %4, label %14, label %5

5:                                                ; preds = %3
  %6 = load ptr, ptr %0, align 8, !tbaa !11
  %7 = icmp eq ptr %6, null
  br i1 %7, label %14, label %8

8:                                                ; preds = %5
  %9 = getelementptr inbounds i8, ptr %0, i64 8
  %10 = load i64, ptr %9, align 8, !tbaa !12
  %11 = icmp ugt i64 %10, %1
  br i1 %11, label %12, label %14

12:                                               ; preds = %8
  %13 = getelementptr inbounds i8, ptr %6, i64 %1
  store ptr %13, ptr %2, align 8, !tbaa !17
  br label %14

14:                                               ; preds = %8, %3, %5, %12
  %15 = phi i32 [ 0, %12 ], [ -4, %5 ], [ -4, %3 ], [ -7, %8 ]
  ret i32 %15
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(readwrite, inaccessiblemem: none) uwtable
define dso_local range(i32 -8, 1) i32 @getslicedstr(ptr noundef readonly %0, i64 noundef %1, i64 noundef %2, ptr nocapture noundef writeonly %3) local_unnamed_addr #8 {
  %5 = icmp eq ptr %0, null
  br i1 %5, label %19, label %6

6:                                                ; preds = %4
  %7 = load ptr, ptr %0, align 8, !tbaa !11
  %8 = icmp eq ptr %7, null
  br i1 %8, label %19, label %9

9:                                                ; preds = %6
  %10 = getelementptr inbounds i8, ptr %0, i64 8
  %11 = load i64, ptr %10, align 8, !tbaa !12
  %12 = icmp ugt i64 %11, %1
  %13 = icmp ugt i64 %11, %2
  %14 = and i1 %12, %13
  br i1 %14, label %15, label %19

15:                                               ; preds = %9
  %16 = sub i64 %2, %1
  %17 = getelementptr inbounds i8, ptr %7, i64 %1
  tail call void @llvm.memcpy.p0.p0.i64(ptr align 1 %3, ptr nonnull align 1 %17, i64 %16, i1 false)
  %18 = getelementptr inbounds i8, ptr %3, i64 %16
  store i8 0, ptr %18, align 1, !tbaa !13
  br label %19

19:                                               ; preds = %9, %4, %6, %15
  %20 = phi i32 [ 0, %15 ], [ -4, %6 ], [ -4, %4 ], [ -8, %9 ]
  ret i32 %20
}

; Function Attrs: nofree norecurse nosync nounwind memory(read, argmem: readwrite, inaccessiblemem: none) uwtable
define dso_local range(i32 -6, 7) i32 @copystr(ptr noundef readonly %0, ptr nocapture noundef writeonly %1) local_unnamed_addr #9 {
  %3 = icmp eq ptr %0, null
  br i1 %3, label %19, label %4

4:                                                ; preds = %2
  %5 = load i8, ptr %0, align 1, !tbaa !13
  %6 = icmp eq i8 %5, 0
  br i1 %6, label %16, label %7

7:                                                ; preds = %4, %7
  %8 = phi i32 [ %11, %7 ], [ 0, %4 ]
  %9 = phi ptr [ %10, %7 ], [ %0, %4 ]
  %10 = getelementptr inbounds i8, ptr %9, i64 1
  %11 = add nuw nsw i32 %8, 1
  %12 = load i8, ptr %10, align 1, !tbaa !13
  %13 = icmp eq i8 %12, 0
  br i1 %13, label %14, label %7, !llvm.loop !16

14:                                               ; preds = %7
  %15 = zext nneg i32 %11 to i64
  br label %16

16:                                               ; preds = %14, %4
  %17 = phi i64 [ 0, %4 ], [ %15, %14 ]
  tail call void @llvm.memcpy.p0.p0.i64(ptr align 1 %1, ptr nonnull align 1 %0, i64 %17, i1 false)
  %18 = getelementptr inbounds i8, ptr %1, i64 %17
  store i8 0, ptr %18, align 1, !tbaa !13
  br label %19

19:                                               ; preds = %16, %2
  %20 = phi i32 [ -6, %2 ], [ 0, %16 ]
  ret i32 %20
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none) uwtable
define dso_local signext i8 @char2lcase(i8 noundef signext %0) local_unnamed_addr #6 {
  %2 = add i8 %0, -65
  %3 = icmp ult i8 %2, 26
  %4 = or disjoint i8 %0, 32
  %5 = select i1 %3, i8 %4, i8 %0
  ret i8 %5
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none) uwtable
define dso_local noundef signext i8 @char2ucase(i8 noundef signext %0) local_unnamed_addr #6 {
  %2 = add i8 %0, -97
  %3 = icmp ult i8 %2, 26
  %4 = and i8 %0, 95
  %5 = select i1 %3, i8 %4, i8 %0
  ret i8 %5
}

; Function Attrs: nofree norecurse nosync nounwind memory(argmem: read) uwtable
define dso_local range(i32 -9, 1) i32 @islcase(ptr noundef readonly %0) local_unnamed_addr #10 {
  %2 = icmp eq ptr %0, null
  br i1 %2, label %16, label %3

3:                                                ; preds = %1
  %4 = load i8, ptr %0, align 1, !tbaa !13
  %5 = icmp eq i8 %4, 0
  br i1 %5, label %16, label %11

6:                                                ; preds = %11
  %7 = add i64 %13, 1
  %8 = getelementptr inbounds i8, ptr %0, i64 %7
  %9 = load i8, ptr %8, align 1, !tbaa !13
  %10 = icmp eq i8 %9, 0
  br i1 %10, label %16, label %11, !llvm.loop !18

11:                                               ; preds = %3, %6
  %12 = phi i8 [ %9, %6 ], [ %4, %3 ]
  %13 = phi i64 [ %7, %6 ], [ 0, %3 ]
  %14 = add i8 %12, -65
  %15 = icmp ult i8 %14, 26
  br i1 %15, label %16, label %6

16:                                               ; preds = %11, %6, %3, %1
  %17 = phi i32 [ -6, %1 ], [ 0, %3 ], [ -9, %11 ], [ 0, %6 ]
  ret i32 %17
}

; Function Attrs: nofree norecurse nosync nounwind memory(argmem: read) uwtable
define dso_local range(i32 -10, 1) i32 @isucase(ptr noundef readonly %0) local_unnamed_addr #10 {
  %2 = icmp eq ptr %0, null
  br i1 %2, label %16, label %3

3:                                                ; preds = %1
  %4 = load i8, ptr %0, align 1, !tbaa !13
  %5 = icmp eq i8 %4, 0
  br i1 %5, label %16, label %11

6:                                                ; preds = %11
  %7 = add i64 %13, 1
  %8 = getelementptr inbounds i8, ptr %0, i64 %7
  %9 = load i8, ptr %8, align 1, !tbaa !13
  %10 = icmp eq i8 %9, 0
  br i1 %10, label %16, label %11, !llvm.loop !19

11:                                               ; preds = %3, %6
  %12 = phi i8 [ %9, %6 ], [ %4, %3 ]
  %13 = phi i64 [ %7, %6 ], [ 0, %3 ]
  %14 = add i8 %12, -97
  %15 = icmp ult i8 %14, 26
  br i1 %15, label %16, label %6

16:                                               ; preds = %11, %6, %3, %1
  %17 = phi i32 [ -6, %1 ], [ 0, %3 ], [ -10, %11 ], [ 0, %6 ]
  ret i32 %17
}

; Function Attrs: nofree norecurse nosync nounwind memory(read, argmem: readwrite, inaccessiblemem: none) uwtable
define dso_local noundef i32 @tolcase(ptr noundef readonly %0, ptr nocapture noundef %1) local_unnamed_addr #9 {
  %3 = icmp eq ptr %0, null
  br i1 %3, label %46, label %4

4:                                                ; preds = %2
  %5 = load i8, ptr %0, align 1, !tbaa !13
  %6 = icmp eq i8 %5, 0
  br i1 %6, label %16, label %7

7:                                                ; preds = %4, %7
  %8 = phi i32 [ %11, %7 ], [ 0, %4 ]
  %9 = phi ptr [ %10, %7 ], [ %0, %4 ]
  %10 = getelementptr inbounds i8, ptr %9, i64 1
  %11 = add nuw nsw i32 %8, 1
  %12 = load i8, ptr %10, align 1, !tbaa !13
  %13 = icmp eq i8 %12, 0
  br i1 %13, label %14, label %7, !llvm.loop !16

14:                                               ; preds = %7
  %15 = zext nneg i32 %11 to i64
  br label %16

16:                                               ; preds = %4, %14
  %17 = phi i64 [ 0, %4 ], [ %15, %14 ]
  tail call void @llvm.memcpy.p0.p0.i64(ptr align 1 %1, ptr nonnull readonly align 1 %0, i64 %17, i1 false)
  %18 = getelementptr inbounds i8, ptr %1, i64 %17
  store i8 0, ptr %18, align 1, !tbaa !13
  %19 = load i8, ptr %1, align 1, !tbaa !13
  %20 = icmp eq i8 %19, 0
  br i1 %20, label %46, label %21

21:                                               ; preds = %16, %21
  %22 = phi i64 [ %29, %21 ], [ 0, %16 ]
  %23 = phi i8 [ %31, %21 ], [ %19, %16 ]
  %24 = getelementptr inbounds i8, ptr %1, i64 %22
  %25 = add i8 %23, -65
  %26 = icmp ult i8 %25, 26
  %27 = or disjoint i8 %23, 32
  %28 = select i1 %26, i8 %27, i8 %23
  store i8 %28, ptr %24, align 1, !tbaa !13
  %29 = add nuw nsw i64 %22, 1
  %30 = getelementptr inbounds i8, ptr %1, i64 %29
  %31 = load i8, ptr %30, align 1, !tbaa !13
  %32 = icmp eq i8 %31, 0
  br i1 %32, label %33, label %21, !llvm.loop !20

33:                                               ; preds = %21
  %34 = load i8, ptr %1, align 1, !tbaa !13
  %35 = icmp eq i8 %34, 0
  br i1 %35, label %46, label %41

36:                                               ; preds = %41
  %37 = add i64 %43, 1
  %38 = getelementptr inbounds i8, ptr %1, i64 %37
  %39 = load i8, ptr %38, align 1, !tbaa !13
  %40 = icmp eq i8 %39, 0
  br i1 %40, label %46, label %41, !llvm.loop !18

41:                                               ; preds = %33, %36
  %42 = phi i8 [ %39, %36 ], [ %34, %33 ]
  %43 = phi i64 [ %37, %36 ], [ 0, %33 ]
  %44 = add i8 %42, -65
  %45 = icmp ult i8 %44, 26
  br i1 %45, label %46, label %36

46:                                               ; preds = %41, %36, %16, %33, %2
  %47 = phi i32 [ -6, %2 ], [ 0, %33 ], [ 0, %16 ], [ 0, %36 ], [ -11, %41 ]
  ret i32 %47
}

; Function Attrs: nofree norecurse nosync nounwind memory(read, argmem: readwrite, inaccessiblemem: none) uwtable
define dso_local noundef i32 @toucase(ptr noundef readonly %0, ptr nocapture noundef %1) local_unnamed_addr #9 {
  %3 = icmp eq ptr %0, null
  br i1 %3, label %46, label %4

4:                                                ; preds = %2
  %5 = load i8, ptr %0, align 1, !tbaa !13
  %6 = icmp eq i8 %5, 0
  br i1 %6, label %16, label %7

7:                                                ; preds = %4, %7
  %8 = phi i32 [ %11, %7 ], [ 0, %4 ]
  %9 = phi ptr [ %10, %7 ], [ %0, %4 ]
  %10 = getelementptr inbounds i8, ptr %9, i64 1
  %11 = add nuw nsw i32 %8, 1
  %12 = load i8, ptr %10, align 1, !tbaa !13
  %13 = icmp eq i8 %12, 0
  br i1 %13, label %14, label %7, !llvm.loop !16

14:                                               ; preds = %7
  %15 = zext nneg i32 %11 to i64
  br label %16

16:                                               ; preds = %4, %14
  %17 = phi i64 [ 0, %4 ], [ %15, %14 ]
  tail call void @llvm.memcpy.p0.p0.i64(ptr align 1 %1, ptr nonnull readonly align 1 %0, i64 %17, i1 false)
  %18 = getelementptr inbounds i8, ptr %1, i64 %17
  store i8 0, ptr %18, align 1, !tbaa !13
  %19 = load i8, ptr %1, align 1, !tbaa !13
  %20 = icmp eq i8 %19, 0
  br i1 %20, label %46, label %21

21:                                               ; preds = %16, %21
  %22 = phi i64 [ %29, %21 ], [ 0, %16 ]
  %23 = phi i8 [ %31, %21 ], [ %19, %16 ]
  %24 = getelementptr inbounds i8, ptr %1, i64 %22
  %25 = add i8 %23, -97
  %26 = icmp ult i8 %25, 26
  %27 = and i8 %23, 95
  %28 = select i1 %26, i8 %27, i8 %23
  store i8 %28, ptr %24, align 1, !tbaa !13
  %29 = add nuw nsw i64 %22, 1
  %30 = getelementptr inbounds i8, ptr %1, i64 %29
  %31 = load i8, ptr %30, align 1, !tbaa !13
  %32 = icmp eq i8 %31, 0
  br i1 %32, label %33, label %21, !llvm.loop !21

33:                                               ; preds = %21
  %34 = load i8, ptr %1, align 1, !tbaa !13
  %35 = icmp eq i8 %34, 0
  br i1 %35, label %46, label %41

36:                                               ; preds = %41
  %37 = add i64 %43, 1
  %38 = getelementptr inbounds i8, ptr %1, i64 %37
  %39 = load i8, ptr %38, align 1, !tbaa !13
  %40 = icmp eq i8 %39, 0
  br i1 %40, label %46, label %41, !llvm.loop !19

41:                                               ; preds = %33, %36
  %42 = phi i8 [ %39, %36 ], [ %34, %33 ]
  %43 = phi i64 [ %37, %36 ], [ 0, %33 ]
  %44 = add i8 %42, -97
  %45 = icmp ult i8 %44, 26
  br i1 %45, label %46, label %36

46:                                               ; preds = %41, %36, %16, %33, %2
  %47 = phi i32 [ -6, %2 ], [ 0, %33 ], [ 0, %16 ], [ 0, %36 ], [ -12, %41 ]
  ret i32 %47
}

; Function Attrs: nofree nounwind uwtable
define dso_local range(i32 -14, 1) i32 @cmp2strs(ptr noundef readonly %0, ptr noundef readonly %1, i32 noundef %2) local_unnamed_addr #11 {
  %4 = icmp eq ptr %0, null
  br i1 %4, label %128, label %5

5:                                                ; preds = %3
  %6 = load ptr, ptr %0, align 8, !tbaa !11
  %7 = icmp ne ptr %6, null
  %8 = icmp ne ptr %1, null
  %9 = and i1 %8, %7
  br i1 %9, label %10, label %128

10:                                               ; preds = %5
  %11 = load ptr, ptr %1, align 8, !tbaa !11
  %12 = icmp eq ptr %11, null
  br i1 %12, label %128, label %13

13:                                               ; preds = %10
  %14 = getelementptr inbounds i8, ptr %0, i64 8
  %15 = load i64, ptr %14, align 8, !tbaa !12
  %16 = getelementptr inbounds i8, ptr %1, i64 8
  %17 = load i64, ptr %16, align 8, !tbaa !12
  %18 = icmp eq i64 %15, %17
  br i1 %18, label %19, label %128

19:                                               ; preds = %13
  %20 = icmp eq i32 %2, 0
  br i1 %20, label %21, label %25

21:                                               ; preds = %19
  %22 = tail call i32 @bcmp(ptr nonnull %6, ptr nonnull %11, i64 %15)
  %23 = icmp eq i32 %22, 0
  %24 = select i1 %23, i32 0, i32 -13
  br label %128

25:                                               ; preds = %19
  %26 = add i64 %15, 1
  %27 = tail call ptr @llvm.stacksave.p0()
  %28 = alloca i8, i64 %26, align 16
  %29 = load i64, ptr %16, align 8, !tbaa !12
  %30 = add i64 %29, 1
  %31 = alloca i8, i64 %30, align 16
  %32 = load ptr, ptr %0, align 8, !tbaa !11
  %33 = icmp eq ptr %32, null
  br i1 %33, label %126, label %34

34:                                               ; preds = %25
  %35 = load i8, ptr %32, align 1, !tbaa !13
  %36 = icmp eq i8 %35, 0
  br i1 %36, label %46, label %37

37:                                               ; preds = %34, %37
  %38 = phi i32 [ %41, %37 ], [ 0, %34 ]
  %39 = phi ptr [ %40, %37 ], [ %32, %34 ]
  %40 = getelementptr inbounds i8, ptr %39, i64 1
  %41 = add nuw nsw i32 %38, 1
  %42 = load i8, ptr %40, align 1, !tbaa !13
  %43 = icmp eq i8 %42, 0
  br i1 %43, label %44, label %37, !llvm.loop !16

44:                                               ; preds = %37
  %45 = zext nneg i32 %41 to i64
  br label %46

46:                                               ; preds = %44, %34
  %47 = phi i64 [ 0, %34 ], [ %45, %44 ]
  call void @llvm.memcpy.p0.p0.i64(ptr nonnull align 16 %28, ptr nonnull readonly align 1 %32, i64 %47, i1 false)
  %48 = getelementptr inbounds i8, ptr %28, i64 %47
  store i8 0, ptr %48, align 1, !tbaa !13
  %49 = load i8, ptr %28, align 16, !tbaa !13
  %50 = icmp eq i8 %49, 0
  br i1 %50, label %76, label %51

51:                                               ; preds = %46, %51
  %52 = phi i64 [ %59, %51 ], [ 0, %46 ]
  %53 = phi i8 [ %61, %51 ], [ %49, %46 ]
  %54 = getelementptr inbounds i8, ptr %28, i64 %52
  %55 = add i8 %53, -65
  %56 = icmp ult i8 %55, 26
  %57 = or disjoint i8 %53, 32
  %58 = select i1 %56, i8 %57, i8 %53
  store i8 %58, ptr %54, align 1, !tbaa !13
  %59 = add nuw nsw i64 %52, 1
  %60 = getelementptr inbounds i8, ptr %28, i64 %59
  %61 = load i8, ptr %60, align 1, !tbaa !13
  %62 = icmp eq i8 %61, 0
  br i1 %62, label %63, label %51, !llvm.loop !20

63:                                               ; preds = %51
  %64 = load i8, ptr %28, align 16, !tbaa !13
  %65 = icmp eq i8 %64, 0
  br i1 %65, label %76, label %71

66:                                               ; preds = %71
  %67 = add i64 %73, 1
  %68 = getelementptr inbounds i8, ptr %28, i64 %67
  %69 = load i8, ptr %68, align 1, !tbaa !13
  %70 = icmp eq i8 %69, 0
  br i1 %70, label %76, label %71, !llvm.loop !18

71:                                               ; preds = %63, %66
  %72 = phi i8 [ %69, %66 ], [ %64, %63 ]
  %73 = phi i64 [ %67, %66 ], [ 0, %63 ]
  %74 = add i8 %72, -65
  %75 = icmp ult i8 %74, 26
  br i1 %75, label %126, label %66

76:                                               ; preds = %66, %63, %46
  %77 = load ptr, ptr %1, align 8, !tbaa !11
  %78 = icmp eq ptr %77, null
  br i1 %78, label %126, label %79

79:                                               ; preds = %76
  %80 = load i8, ptr %77, align 1, !tbaa !13
  %81 = icmp eq i8 %80, 0
  br i1 %81, label %91, label %82

82:                                               ; preds = %79, %82
  %83 = phi i32 [ %86, %82 ], [ 0, %79 ]
  %84 = phi ptr [ %85, %82 ], [ %77, %79 ]
  %85 = getelementptr inbounds i8, ptr %84, i64 1
  %86 = add nuw nsw i32 %83, 1
  %87 = load i8, ptr %85, align 1, !tbaa !13
  %88 = icmp eq i8 %87, 0
  br i1 %88, label %89, label %82, !llvm.loop !16

89:                                               ; preds = %82
  %90 = zext nneg i32 %86 to i64
  br label %91

91:                                               ; preds = %89, %79
  %92 = phi i64 [ 0, %79 ], [ %90, %89 ]
  call void @llvm.memcpy.p0.p0.i64(ptr nonnull align 16 %31, ptr nonnull readonly align 1 %77, i64 %92, i1 false)
  %93 = getelementptr inbounds i8, ptr %31, i64 %92
  store i8 0, ptr %93, align 1, !tbaa !13
  %94 = load i8, ptr %31, align 16, !tbaa !13
  %95 = icmp eq i8 %94, 0
  br i1 %95, label %121, label %96

96:                                               ; preds = %91, %96
  %97 = phi i64 [ %104, %96 ], [ 0, %91 ]
  %98 = phi i8 [ %106, %96 ], [ %94, %91 ]
  %99 = getelementptr inbounds i8, ptr %31, i64 %97
  %100 = add i8 %98, -65
  %101 = icmp ult i8 %100, 26
  %102 = or disjoint i8 %98, 32
  %103 = select i1 %101, i8 %102, i8 %98
  store i8 %103, ptr %99, align 1, !tbaa !13
  %104 = add nuw nsw i64 %97, 1
  %105 = getelementptr inbounds i8, ptr %31, i64 %104
  %106 = load i8, ptr %105, align 1, !tbaa !13
  %107 = icmp eq i8 %106, 0
  br i1 %107, label %108, label %96, !llvm.loop !20

108:                                              ; preds = %96
  %109 = load i8, ptr %31, align 16, !tbaa !13
  %110 = icmp eq i8 %109, 0
  br i1 %110, label %121, label %116

111:                                              ; preds = %116
  %112 = add i64 %118, 1
  %113 = getelementptr inbounds i8, ptr %31, i64 %112
  %114 = load i8, ptr %113, align 1, !tbaa !13
  %115 = icmp eq i8 %114, 0
  br i1 %115, label %121, label %116, !llvm.loop !18

116:                                              ; preds = %108, %111
  %117 = phi i8 [ %114, %111 ], [ %109, %108 ]
  %118 = phi i64 [ %112, %111 ], [ 0, %108 ]
  %119 = add i8 %117, -65
  %120 = icmp ult i8 %119, 26
  br i1 %120, label %126, label %111

121:                                              ; preds = %111, %108, %91
  %122 = load i64, ptr %14, align 8, !tbaa !12
  %123 = call i32 @bcmp(ptr nonnull %28, ptr nonnull %31, i64 %122)
  %124 = icmp eq i32 %123, 0
  %125 = select i1 %124, i32 0, i32 -13
  br label %126

126:                                              ; preds = %71, %116, %76, %25, %121
  %127 = phi i32 [ %125, %121 ], [ -14, %25 ], [ -14, %76 ], [ -14, %116 ], [ -14, %71 ]
  tail call void @llvm.stackrestore.p0(ptr %27)
  br label %128

128:                                              ; preds = %13, %3, %5, %10, %126, %21
  %129 = phi i32 [ %24, %21 ], [ %127, %126 ], [ -4, %10 ], [ -4, %5 ], [ -4, %3 ], [ -13, %13 ]
  ret i32 %129
}

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn
declare ptr @llvm.stacksave.p0() #12

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn
declare void @llvm.stackrestore.p0(ptr) #12

; Function Attrs: nofree norecurse nosync nounwind memory(argmem: readwrite) uwtable
define dso_local range(i32 -6, 18) i32 @findchar(ptr noundef readonly %0, i8 noundef signext %1, i32 noundef %2, ptr nocapture noundef writeonly %3) local_unnamed_addr #13 {
  %5 = icmp eq ptr %0, null
  br i1 %5, label %47, label %6

6:                                                ; preds = %4
  %7 = icmp eq i32 %2, 0
  %8 = load i8, ptr %0, align 1, !tbaa !13
  %9 = icmp eq i8 %8, 0
  br i1 %7, label %16, label %10

10:                                               ; preds = %6
  br i1 %9, label %47, label %11

11:                                               ; preds = %10
  %12 = add i8 %1, -65
  %13 = icmp ult i8 %12, 26
  %14 = or disjoint i8 %1, 32
  %15 = select i1 %13, i8 %14, i8 %1
  br label %17

16:                                               ; preds = %6
  br i1 %9, label %47, label %32

17:                                               ; preds = %11, %17
  %18 = phi i64 [ 0, %11 ], [ %28, %17 ]
  %19 = phi i8 [ %8, %11 ], [ %30, %17 ]
  %20 = phi i32 [ 0, %11 ], [ %27, %17 ]
  %21 = add i8 %19, -65
  %22 = icmp ult i8 %21, 26
  %23 = or disjoint i8 %19, 32
  %24 = select i1 %22, i8 %23, i8 %19
  %25 = icmp eq i8 %24, %15
  %26 = zext i1 %25 to i32
  %27 = add nuw nsw i32 %20, %26
  %28 = add nuw nsw i64 %18, 1
  %29 = getelementptr inbounds i8, ptr %0, i64 %28
  %30 = load i8, ptr %29, align 1, !tbaa !13
  %31 = icmp eq i8 %30, 0
  br i1 %31, label %43, label %17, !llvm.loop !22

32:                                               ; preds = %16, %32
  %33 = phi i64 [ %39, %32 ], [ 0, %16 ]
  %34 = phi i8 [ %41, %32 ], [ %8, %16 ]
  %35 = phi i32 [ %38, %32 ], [ 0, %16 ]
  %36 = icmp eq i8 %34, %1
  %37 = zext i1 %36 to i32
  %38 = add nuw nsw i32 %35, %37
  %39 = add nuw nsw i64 %33, 1
  %40 = getelementptr inbounds i8, ptr %0, i64 %39
  %41 = load i8, ptr %40, align 1, !tbaa !13
  %42 = icmp eq i8 %41, 0
  br i1 %42, label %43, label %32, !llvm.loop !23

43:                                               ; preds = %17, %32
  %44 = phi i32 [ %38, %32 ], [ %27, %17 ]
  %45 = icmp eq i32 %44, 0
  br i1 %45, label %47, label %46

46:                                               ; preds = %43
  store i32 %44, ptr %3, align 4, !tbaa !24
  br label %47

47:                                               ; preds = %10, %16, %46, %43, %4
  %48 = phi i32 [ -6, %4 ], [ 0, %46 ], [ 17, %43 ], [ 17, %16 ], [ 17, %10 ]
  ret i32 %48
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(write, argmem: readwrite, inaccessiblemem: none) uwtable
define dso_local range(i32 -4, 1) i32 @clearStr(ptr noundef %0) local_unnamed_addr #14 {
  %2 = icmp eq ptr %0, null
  br i1 %2, label %8, label %3

3:                                                ; preds = %1
  %4 = load ptr, ptr %0, align 8, !tbaa !11
  %5 = icmp eq ptr %4, null
  br i1 %5, label %8, label %6

6:                                                ; preds = %3
  %7 = getelementptr inbounds i8, ptr %0, i64 8
  store i64 0, ptr %7, align 8, !tbaa !12
  store i8 0, ptr %4, align 1, !tbaa !13
  br label %8

8:                                                ; preds = %6, %1, %3
  %9 = phi i32 [ -4, %3 ], [ -4, %1 ], [ 0, %6 ]
  ret i32 %9
}

; Function Attrs: mustprogress nounwind willreturn uwtable
define dso_local range(i32 -4, 1) i32 @freeStr(ptr noundef %0) local_unnamed_addr #15 {
  %2 = icmp eq ptr %0, null
  br i1 %2, label %8, label %3

3:                                                ; preds = %1
  %4 = load ptr, ptr %0, align 8, !tbaa !11
  %5 = icmp eq ptr %4, null
  br i1 %5, label %8, label %6

6:                                                ; preds = %3
  tail call void @free(ptr noundef nonnull %4) #24
  %7 = getelementptr inbounds i8, ptr %0, i64 8
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 8 dereferenceable(16) %7, i8 0, i64 16, i1 false)
  br label %8

8:                                                ; preds = %1, %3, %6
  %9 = phi i32 [ 0, %6 ], [ -4, %3 ], [ -4, %1 ]
  ret i32 %9
}

; Function Attrs: mustprogress nounwind willreturn allockind("free") memory(argmem: readwrite, inaccessiblemem: readwrite)
declare void @free(ptr allocptr nocapture noundef) local_unnamed_addr #16

; Function Attrs: nofree norecurse nosync nounwind uwtable
define dso_local noundef i32 @kmp_search(ptr noundef readonly %0, ptr noundef readonly %1, ptr nocapture noundef %2) local_unnamed_addr #17 {
  %4 = icmp ne ptr %0, null
  %5 = icmp ne ptr %1, null
  %6 = and i1 %4, %5
  br i1 %6, label %7, label %111

7:                                                ; preds = %3
  %8 = load i8, ptr %0, align 1, !tbaa !13
  %9 = icmp eq i8 %8, 0
  br i1 %9, label %17, label %10

10:                                               ; preds = %7, %10
  %11 = phi i32 [ %14, %10 ], [ 0, %7 ]
  %12 = phi ptr [ %13, %10 ], [ %0, %7 ]
  %13 = getelementptr inbounds i8, ptr %12, i64 1
  %14 = add nuw nsw i32 %11, 1
  %15 = load i8, ptr %13, align 1, !tbaa !13
  %16 = icmp eq i8 %15, 0
  br i1 %16, label %17, label %10, !llvm.loop !16

17:                                               ; preds = %10, %7
  %18 = phi i32 [ 0, %7 ], [ %14, %10 ]
  %19 = load i8, ptr %1, align 1, !tbaa !13
  %20 = icmp eq i8 %19, 0
  br i1 %20, label %21, label %23

21:                                               ; preds = %17
  %22 = tail call ptr @llvm.stacksave.p0()
  br label %108

23:                                               ; preds = %17, %23
  %24 = phi i32 [ %27, %23 ], [ 0, %17 ]
  %25 = phi ptr [ %26, %23 ], [ %1, %17 ]
  %26 = getelementptr inbounds i8, ptr %25, i64 1
  %27 = add nuw nsw i32 %24, 1
  %28 = load i8, ptr %26, align 1, !tbaa !13
  %29 = icmp eq i8 %28, 0
  br i1 %29, label %30, label %23, !llvm.loop !16

30:                                               ; preds = %23
  %31 = icmp slt i32 %24, %18
  br i1 %31, label %32, label %111

32:                                               ; preds = %30
  %33 = zext nneg i32 %27 to i64
  %34 = tail call ptr @llvm.stacksave.p0()
  %35 = alloca i64, i64 %33, align 16
  %36 = zext nneg i32 %27 to i64
  store i64 0, ptr %35, align 16, !tbaa !26
  %37 = getelementptr i8, ptr %35, i64 -8
  %38 = icmp eq i32 %24, 0
  br i1 %38, label %63, label %39

39:                                               ; preds = %32, %59
  %40 = phi i64 [ %61, %59 ], [ 1, %32 ]
  %41 = phi i64 [ %60, %59 ], [ 0, %32 ]
  %42 = getelementptr inbounds i8, ptr %1, i64 %40
  %43 = load i8, ptr %42, align 1, !tbaa !13
  %44 = getelementptr inbounds i8, ptr %1, i64 %41
  %45 = load i8, ptr %44, align 1, !tbaa !13
  %46 = icmp eq i8 %43, %45
  br i1 %46, label %47, label %51

47:                                               ; preds = %39
  %48 = add i64 %41, 1
  %49 = getelementptr inbounds i64, ptr %35, i64 %40
  store i64 %48, ptr %49, align 8, !tbaa !26
  %50 = add nuw i64 %40, 1
  br label %59

51:                                               ; preds = %39
  %52 = icmp eq i64 %41, 0
  br i1 %52, label %56, label %53

53:                                               ; preds = %51
  %54 = getelementptr i64, ptr %37, i64 %41
  %55 = load i64, ptr %54, align 8, !tbaa !26
  br label %59

56:                                               ; preds = %51
  %57 = getelementptr inbounds i64, ptr %35, i64 %40
  store i64 0, ptr %57, align 8, !tbaa !26
  %58 = add nuw i64 %40, 1
  br label %59

59:                                               ; preds = %56, %53, %47
  %60 = phi i64 [ %48, %47 ], [ %55, %53 ], [ 0, %56 ]
  %61 = phi i64 [ %50, %47 ], [ %40, %53 ], [ %58, %56 ]
  %62 = icmp ult i64 %61, %36
  br i1 %62, label %39, label %63, !llvm.loop !27

63:                                               ; preds = %59, %32
  %64 = sext i32 %18 to i64
  %65 = icmp eq i32 %18, 0
  br i1 %65, label %103, label %66

66:                                               ; preds = %63
  %67 = getelementptr inbounds i8, ptr %2, i64 8
  %68 = getelementptr i64, ptr %35, i64 %36
  %69 = getelementptr i8, ptr %68, i64 -8
  br label %70

70:                                               ; preds = %66, %96
  %71 = phi i64 [ 0, %66 ], [ %99, %96 ]
  %72 = phi i64 [ 0, %66 ], [ %98, %96 ]
  %73 = phi i64 [ 0, %66 ], [ %97, %96 ]
  %74 = getelementptr inbounds i8, ptr %0, i64 %73
  %75 = load i8, ptr %74, align 1, !tbaa !13
  %76 = getelementptr inbounds i8, ptr %1, i64 %72
  %77 = load i8, ptr %76, align 1, !tbaa !13
  %78 = icmp eq i8 %75, %77
  br i1 %78, label %79, label %89

79:                                               ; preds = %70
  %80 = add nuw i64 %73, 1
  %81 = add i64 %72, 1
  %82 = icmp eq i64 %81, %36
  br i1 %82, label %83, label %96

83:                                               ; preds = %79
  %84 = sub i64 %73, %72
  %85 = load ptr, ptr %67, align 8, !tbaa !28
  %86 = getelementptr inbounds i64, ptr %85, i64 %71
  store i64 %84, ptr %86, align 8, !tbaa !26
  %87 = add i64 %71, 1
  %88 = load i64, ptr %69, align 8, !tbaa !26
  br label %96

89:                                               ; preds = %70
  %90 = icmp eq i64 %72, 0
  br i1 %90, label %94, label %91

91:                                               ; preds = %89
  %92 = getelementptr i64, ptr %37, i64 %72
  %93 = load i64, ptr %92, align 8, !tbaa !26
  br label %96

94:                                               ; preds = %89
  %95 = add nuw i64 %73, 1
  br label %96

96:                                               ; preds = %91, %94, %79, %83
  %97 = phi i64 [ %80, %83 ], [ %80, %79 ], [ %73, %91 ], [ %95, %94 ]
  %98 = phi i64 [ %88, %83 ], [ %81, %79 ], [ %93, %91 ], [ 0, %94 ]
  %99 = phi i64 [ %87, %83 ], [ %71, %79 ], [ %71, %91 ], [ %71, %94 ]
  %100 = icmp ult i64 %97, %64
  br i1 %100, label %70, label %101, !llvm.loop !30

101:                                              ; preds = %96
  %102 = icmp eq i64 %99, 0
  br i1 %102, label %103, label %105

103:                                              ; preds = %63, %101
  %104 = getelementptr inbounds i8, ptr %2, i64 8
  store ptr null, ptr %104, align 8, !tbaa !28
  br label %105

105:                                              ; preds = %101, %103
  %106 = phi i64 [ 0, %103 ], [ %99, %101 ]
  %107 = phi i32 [ -16, %103 ], [ 0, %101 ]
  store i64 %106, ptr %2, align 8, !tbaa !31
  br label %108

108:                                              ; preds = %21, %105
  %109 = phi ptr [ %34, %105 ], [ %22, %21 ]
  %110 = phi i32 [ %107, %105 ], [ -6, %21 ]
  tail call void @llvm.stackrestore.p0(ptr %109)
  br label %111

111:                                              ; preds = %108, %30, %3
  %112 = phi i32 [ -6, %3 ], [ %110, %108 ], [ -6, %30 ]
  ret i32 %112
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read) uwtable
define dso_local range(i32 -16, 1) i32 @isin(ptr noundef readonly %0) local_unnamed_addr #18 {
  %2 = icmp eq ptr %0, null
  br i1 %2, label %7, label %3

3:                                                ; preds = %1
  %4 = load i64, ptr %0, align 8, !tbaa !31
  %5 = icmp eq i64 %4, 0
  %6 = select i1 %5, i32 -16, i32 0
  br label %7

7:                                                ; preds = %3, %1
  %8 = phi i32 [ -15, %1 ], [ %6, %3 ]
  ret i32 %8
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(read, argmem: readwrite, inaccessiblemem: none) uwtable
define dso_local range(i32 -16, 1) i32 @firstOccurrence(ptr noundef readonly %0, ptr nocapture noundef writeonly %1) local_unnamed_addr #19 {
  %3 = icmp eq ptr %0, null
  br i1 %3, label %17, label %4

4:                                                ; preds = %2
  %5 = load i64, ptr %0, align 8, !tbaa !31
  %6 = icmp eq i64 %5, 0
  br i1 %6, label %14, label %7

7:                                                ; preds = %4
  %8 = getelementptr inbounds i8, ptr %0, i64 8
  %9 = load ptr, ptr %8, align 8, !tbaa !28
  %10 = icmp eq ptr %9, null
  br i1 %10, label %14, label %11

11:                                               ; preds = %7
  %12 = load i64, ptr %9, align 8, !tbaa !26
  %13 = trunc i64 %12 to i32
  br label %14

14:                                               ; preds = %4, %7, %11
  %15 = phi i32 [ %13, %11 ], [ -1, %7 ], [ -1, %4 ]
  %16 = phi i32 [ 0, %11 ], [ -16, %7 ], [ -16, %4 ]
  store i32 %15, ptr %1, align 4, !tbaa !24
  br label %17

17:                                               ; preds = %14, %2
  %18 = phi i32 [ -15, %2 ], [ %16, %14 ]
  ret i32 %18
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: readwrite) uwtable
define dso_local range(i32 -16, 1) i32 @allOccurrences(ptr noundef readonly %0, ptr nocapture noundef writeonly %1, ptr nocapture noundef writeonly %2) local_unnamed_addr #7 {
  %4 = icmp eq ptr %0, null
  br i1 %4, label %15, label %5

5:                                                ; preds = %3
  %6 = load i64, ptr %0, align 8, !tbaa !31
  %7 = icmp eq i64 %6, 0
  br i1 %7, label %12, label %8

8:                                                ; preds = %5
  %9 = getelementptr inbounds i8, ptr %0, i64 8
  %10 = load ptr, ptr %9, align 8, !tbaa !28
  %11 = icmp eq ptr %10, null
  br i1 %11, label %12, label %13

12:                                               ; preds = %8, %5
  store i32 -1, ptr %2, align 4, !tbaa !24
  store ptr null, ptr %1, align 8, !tbaa !17
  br label %15

13:                                               ; preds = %8
  store ptr %10, ptr %1, align 8, !tbaa !17
  %14 = trunc i64 %6 to i32
  store i32 %14, ptr %2, align 4, !tbaa !24
  br label %15

15:                                               ; preds = %3, %13, %12
  %16 = phi i32 [ -16, %12 ], [ 0, %13 ], [ -15, %3 ]
  ret i32 %16
}

; Function Attrs: nofree nounwind willreturn memory(argmem: read)
declare i32 @bcmp(ptr nocapture, ptr nocapture, i64) local_unnamed_addr #20

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr nocapture writeonly, i8, i64, i1 immarg) #21

attributes #0 = { mustprogress nofree nounwind willreturn memory(write, argmem: readwrite, inaccessiblemem: readwrite) uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { mustprogress nofree nounwind willreturn allockind("alloc,uninitialized") allocsize(0) memory(inaccessiblemem: readwrite) "alloc-family"="malloc" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #2 = { nounwind uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #3 = { mustprogress nounwind willreturn allockind("realloc") allocsize(1) memory(argmem: readwrite, inaccessiblemem: readwrite) "alloc-family"="malloc" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #4 = { nofree norecurse nosync nounwind memory(read, inaccessiblemem: none) uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #5 = { mustprogress nocallback nofree nounwind willreturn memory(argmem: readwrite) }
attributes #6 = { mustprogress nofree norecurse nosync nounwind willreturn memory(none) uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #7 = { mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: readwrite) uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #8 = { mustprogress nofree norecurse nosync nounwind willreturn memory(readwrite, inaccessiblemem: none) uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #9 = { nofree norecurse nosync nounwind memory(read, argmem: readwrite, inaccessiblemem: none) uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #10 = { nofree norecurse nosync nounwind memory(argmem: read) uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #11 = { nofree nounwind uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #12 = { mustprogress nocallback nofree nosync nounwind willreturn }
attributes #13 = { nofree norecurse nosync nounwind memory(argmem: readwrite) uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #14 = { mustprogress nofree norecurse nosync nounwind willreturn memory(write, argmem: readwrite, inaccessiblemem: none) uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #15 = { mustprogress nounwind willreturn uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #16 = { mustprogress nounwind willreturn allockind("free") memory(argmem: readwrite, inaccessiblemem: readwrite) "alloc-family"="malloc" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #17 = { nofree norecurse nosync nounwind uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #18 = { mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read) uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #19 = { mustprogress nofree norecurse nosync nounwind willreturn memory(read, argmem: readwrite, inaccessiblemem: none) uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #20 = { nofree nounwind willreturn memory(argmem: read) }
attributes #21 = { nocallback nofree nounwind willreturn memory(argmem: write) }
attributes #22 = { nounwind allocsize(0) }
attributes #23 = { nounwind allocsize(1) }
attributes #24 = { nounwind }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 2}
!4 = !{!"Debian clang version 19.1.7 (3+b1)"}
!5 = !{!6, !10, i64 16}
!6 = !{!"", !7, i64 0, !10, i64 8, !10, i64 16}
!7 = !{!"any pointer", !8, i64 0}
!8 = !{!"omnipotent char", !9, i64 0}
!9 = !{!"Simple C/C++ TBAA"}
!10 = !{!"long", !8, i64 0}
!11 = !{!6, !7, i64 0}
!12 = !{!6, !10, i64 8}
!13 = !{!8, !8, i64 0}
!14 = distinct !{!14, !15}
!15 = !{!"llvm.loop.mustprogress"}
!16 = distinct !{!16, !15}
!17 = !{!7, !7, i64 0}
!18 = distinct !{!18, !15}
!19 = distinct !{!19, !15}
!20 = distinct !{!20, !15}
!21 = distinct !{!21, !15}
!22 = distinct !{!22, !15}
!23 = distinct !{!23, !15}
!24 = !{!25, !25, i64 0}
!25 = !{!"int", !8, i64 0}
!26 = !{!10, !10, i64 0}
!27 = distinct !{!27, !15}
!28 = !{!29, !7, i64 8}
!29 = !{!"", !10, i64 0, !7, i64 8}
!30 = distinct !{!30, !15}
!31 = !{!29, !10, i64 0}
