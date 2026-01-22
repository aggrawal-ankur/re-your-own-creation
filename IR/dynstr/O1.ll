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
  %9 = tail call noalias ptr @malloc(i64 noundef %1) #23
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
  %18 = tail call ptr @realloc(ptr noundef nonnull %5, i64 noundef %14) #24
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
  br i1 %12, label %13, label %6, !llvm.loop !17

13:                                               ; preds = %6, %3, %1
  %14 = phi i32 [ -1, %1 ], [ 0, %3 ], [ %10, %6 ]
  ret i32 %14
}

; Function Attrs: nounwind uwtable
define dso_local range(i32 -6, 1) i32 @populate(ptr noundef %0, ptr noundef readonly %1) local_unnamed_addr #2 {
  %3 = icmp eq ptr %0, null       ; !dest
  br i1 %3, label %49, label %4

4:                                                ; preds = %2
  %5 = load ptr, ptr %0, align 8, !tbaa !11
  %6 = icmp eq ptr %5, null         ; !dest.data
  br i1 %6, label %49, label %7

7:                                                ; preds = %4
  %8 = icmp eq ptr %1, null         ; !src
  br i1 %8, label %49, label %9

9:              ; lenstr inlined                  ; preds = %7
  %10 = load i8, ptr %1, align 1, !tbaa !13
  %11 = icmp eq i8 %10, 0
  br i1 %11, label %21, label %12

12:                                               ; preds = %9, %12
  %13 = phi i32 [ %16, %12 ], [ 0, %9 ]     ; len=0
  %14 = phi ptr [ %15, %12 ], [ %1, %9 ]    ; ptr=&src[0]
  %15 = getelementptr inbounds i8, ptr %14, i64 1   ; ptr=&src[1]
  %16 = add nuw nsw i32 %13, 1      ; len++
  %17 = load i8, ptr %15, align 1, !tbaa !13    ; src[1]
  %18 = icmp eq i8 %17, 0       ; src[1] == '\0'
  br i1 %18, label %19, label %12, !llvm.loop !17

19:                                               ; preds = %12
  %20 = zext nneg i32 %16 to i64      ; zero-extend so that it can be added to dest.len
  br label %21

21:                                               ; preds = %19, %9
  %22 = phi i64 [ 0, %9 ], [ %20, %19 ]     ; WHY THIS
  %23 = getelementptr inbounds i8, ptr %0, i64 8
  %24 = load i64, ptr %23, align 8, !tbaa !12     ; dest.len
  %25 = add i64 %24, %22     ; add(lenstr(src), dest.len)==nlen
  %26 = add i64 %25, 1       ; nlen+1
  %27 = getelementptr inbounds i8, ptr %0, i64 16
  %28 = load i64, ptr %27, align 8, !tbaa !5      ; dest.cap
  %29 = icmp ult i64 %28, %26     ; dest.cap < nlen+1
  br i1 %29, label %30, label %40

30:                                               ; preds = %21
  %31 = add i64 %25, 2     ; add(lenstr(src), dest.len)==nlen+1+1 (I am not sure why not nlen+1 was reused)
  br label %32

32:             ; extend inlined                  ; preds = %32, %30
  %33 = phi i64 [ %35, %32 ], [ %28, %30 ]    ; dest.cap=>ncap
  %34 = icmp ult i64 %33, %31     ; ncap < (add+1) where (add+1)=(nlen+2)
  %35 = shl i64 %33, 1        ; ncap*=2
  br i1 %34, label %32, label %36, !llvm.loop !14

36:                                               ; preds = %32
  %37 = tail call ptr @realloc(ptr noundef nonnull %5, i64 noundef %33) #24
  %38 = icmp eq ptr %37, null       ; !tmp
  br i1 %38, label %40, label %39

39:                                               ; preds = %36
  store ptr %37, ptr %0, align 8, !tbaa !11       ; update %0, if required
  store i64 %33, ptr %27, align 8, !tbaa !5       ; update dest.cap, if required
  br label %40

40:                                               ; preds = %21, %36, %39
  %41 = phi i1 [ true, %21 ], [ true, %39 ], [ false, %36 ]
  %42 = phi i32 [ 0, %21 ], [ 0, %39 ], [ -5, %36 ]
  br i1 %41, label %43, label %49

43:                                               ; preds = %40
  %44 = load ptr, ptr %0, align 8, !tbaa !11      ; dest
  %45 = load i64, ptr %23, align 8, !tbaa !12     ; dest.len
  %46 = getelementptr inbounds i8, ptr %44, i64 %45     ; dest.data[dest.len]   point to the current end of the string
  tail call void @llvm.memcpy.p0.p0.i64(ptr align 1 %46, ptr nonnull align 1 %1, i64 %22, i1 false)
  store i64 %25, ptr %23, align 8, !tbaa !12
  %47 = load ptr, ptr %0, align 8, !tbaa !11      ; dest
  %48 = getelementptr inbounds i8, ptr %47, i64 %25    ; dest.data[nlen]
  store i8 0, ptr %48, align 1, !tbaa !13    ; dest.data[nlen]='\0'
  br label %49

49:                                               ; preds = %40, %43, %7, %2, %4
  %50 = phi i32 [ -4, %4 ], [ -4, %2 ], [ -6, %7 ], [ 0, %43 ], [ %42, %40 ]
  ret i32 %50
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
  store ptr %13, ptr %2, align 8, !tbaa !18
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
  br i1 %13, label %14, label %7, !llvm.loop !17

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
  br i1 %10, label %16, label %11, !llvm.loop !19

11:                                               ; preds = %3, %6
  %12 = phi i8 [ %9, %6 ], [ %4, %3 ]
  %13 = phi i64 [ %7, %6 ], [ 0, %3 ]
  %14 = add i8 %12, -65
  %15 = icmp ult i8 %14, 26
  br i1 %15, label %16, label %6

16:                                               ; preds = %11, %6, %3, %1
  %17 = phi i32 [ -6, %1 ], [ 0, %3 ], [ 0, %6 ], [ -9, %11 ]
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
  br i1 %10, label %16, label %11, !llvm.loop !20

11:                                               ; preds = %3, %6
  %12 = phi i8 [ %9, %6 ], [ %4, %3 ]
  %13 = phi i64 [ %7, %6 ], [ 0, %3 ]
  %14 = add i8 %12, -97
  %15 = icmp ult i8 %14, 26
  br i1 %15, label %16, label %6

16:                                               ; preds = %11, %6, %3, %1
  %17 = phi i32 [ -6, %1 ], [ 0, %3 ], [ 0, %6 ], [ -10, %11 ]
  ret i32 %17
}

; Function Attrs: nofree norecurse nosync nounwind memory(readwrite, inaccessiblemem: none) uwtable
define dso_local noundef i32 @tolcase(ptr noundef readonly %0, ptr nocapture noundef %1) local_unnamed_addr #11 {
  %3 = icmp eq ptr %0, null
  br i1 %3, label %49, label %4

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
  br i1 %13, label %14, label %7, !llvm.loop !17

14:                                               ; preds = %7
  %15 = zext nneg i32 %11 to i64
  br label %16

16:                                               ; preds = %14, %4
  %17 = phi i64 [ 0, %4 ], [ %15, %14 ]
  tail call void @llvm.memcpy.p0.p0.i64(ptr align 1 %1, ptr nonnull readonly align 1 %0, i64 %17, i1 false)
  %18 = getelementptr inbounds i8, ptr %1, i64 %17
  store i8 0, ptr %18, align 1, !tbaa !13
  %19 = load i8, ptr %1, align 1, !tbaa !13
  %20 = icmp eq i8 %19, 0
  br i1 %20, label %35, label %21

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
  br i1 %32, label %33, label %21, !llvm.loop !21

33:                                               ; preds = %21
  %34 = getelementptr inbounds i8, ptr %1, i64 %29
  br label %35

35:                                               ; preds = %33, %16
  %36 = phi ptr [ %1, %16 ], [ %34, %33 ]
  store i8 0, ptr %36, align 1, !tbaa !13
  %37 = load i8, ptr %1, align 1, !tbaa !13
  %38 = icmp eq i8 %37, 0
  br i1 %38, label %49, label %44

39:                                               ; preds = %44
  %40 = add i64 %46, 1
  %41 = getelementptr inbounds i8, ptr %1, i64 %40
  %42 = load i8, ptr %41, align 1, !tbaa !13
  %43 = icmp eq i8 %42, 0
  br i1 %43, label %49, label %44, !llvm.loop !19

44:                                               ; preds = %35, %39
  %45 = phi i8 [ %42, %39 ], [ %37, %35 ]
  %46 = phi i64 [ %40, %39 ], [ 0, %35 ]
  %47 = add i8 %45, -65
  %48 = icmp ult i8 %47, 26
  br i1 %48, label %49, label %39

49:                                               ; preds = %44, %39, %35, %2
  %50 = phi i32 [ -6, %2 ], [ 0, %35 ], [ 0, %39 ], [ -11, %44 ]
  ret i32 %50
}

; Function Attrs: nofree norecurse nosync nounwind memory(readwrite, inaccessiblemem: none) uwtable
define dso_local noundef i32 @toucase(ptr noundef readonly %0, ptr nocapture noundef %1) local_unnamed_addr #11 {
  %3 = icmp eq ptr %0, null
  br i1 %3, label %49, label %4

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
  br i1 %13, label %14, label %7, !llvm.loop !17

14:                                               ; preds = %7
  %15 = zext nneg i32 %11 to i64
  br label %16

16:                                               ; preds = %14, %4
  %17 = phi i64 [ 0, %4 ], [ %15, %14 ]
  tail call void @llvm.memcpy.p0.p0.i64(ptr align 1 %1, ptr nonnull readonly align 1 %0, i64 %17, i1 false)
  %18 = getelementptr inbounds i8, ptr %1, i64 %17
  store i8 0, ptr %18, align 1, !tbaa !13
  %19 = load i8, ptr %1, align 1, !tbaa !13
  %20 = icmp eq i8 %19, 0
  br i1 %20, label %35, label %21

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
  br i1 %32, label %33, label %21, !llvm.loop !22

33:                                               ; preds = %21
  %34 = getelementptr inbounds i8, ptr %1, i64 %29
  br label %35

35:                                               ; preds = %33, %16
  %36 = phi ptr [ %1, %16 ], [ %34, %33 ]
  store i8 0, ptr %36, align 1, !tbaa !13
  %37 = load i8, ptr %1, align 1, !tbaa !13
  %38 = icmp eq i8 %37, 0
  br i1 %38, label %49, label %44

39:                                               ; preds = %44
  %40 = add i64 %46, 1
  %41 = getelementptr inbounds i8, ptr %1, i64 %40
  %42 = load i8, ptr %41, align 1, !tbaa !13
  %43 = icmp eq i8 %42, 0
  br i1 %43, label %49, label %44, !llvm.loop !20

44:                                               ; preds = %35, %39
  %45 = phi i8 [ %42, %39 ], [ %37, %35 ]
  %46 = phi i64 [ %40, %39 ], [ 0, %35 ]
  %47 = add i8 %45, -97
  %48 = icmp ult i8 %47, 26
  br i1 %48, label %49, label %39

49:                                               ; preds = %44, %39, %35, %2
  %50 = phi i32 [ -6, %2 ], [ 0, %35 ], [ 0, %39 ], [ -12, %44 ]
  ret i32 %50
}

; Function Attrs: nofree nounwind uwtable
define dso_local range(i32 -14, 1) i32 @cmp2strs(ptr noundef readonly %0, ptr nocapture noundef readonly %1, i32 noundef %2) local_unnamed_addr #12 {
  %4 = icmp eq ptr %0, null
  br i1 %4, label %132, label %5

5:                                                ; preds = %3
  %6 = load ptr, ptr %0, align 8, !tbaa !11
  %7 = icmp eq ptr %6, null
  br i1 %7, label %132, label %8

8:                                                ; preds = %5
  %9 = load ptr, ptr %1, align 8, !tbaa !11
  %10 = icmp eq ptr %9, null
  br i1 %10, label %132, label %11

11:                                               ; preds = %8
  %12 = getelementptr inbounds i8, ptr %0, i64 8
  %13 = load i64, ptr %12, align 8, !tbaa !12
  %14 = getelementptr inbounds i8, ptr %1, i64 8
  %15 = load i64, ptr %14, align 8, !tbaa !12
  %16 = icmp eq i64 %13, %15
  br i1 %16, label %17, label %132

17:                                               ; preds = %11
  %18 = icmp eq i32 %2, 0
  br i1 %18, label %19, label %23

19:                                               ; preds = %17
  %20 = tail call i32 @bcmp(ptr nonnull %6, ptr nonnull %9, i64 %13)
  %21 = icmp eq i32 %20, 0
  %22 = select i1 %21, i32 0, i32 -13
  br label %132

23:                                               ; preds = %17
  %24 = add i64 %13, 1
  %25 = tail call ptr @llvm.stacksave.p0()
  %26 = alloca i8, i64 %24, align 16
  %27 = load i64, ptr %14, align 8, !tbaa !12
  %28 = add i64 %27, 1
  %29 = alloca i8, i64 %28, align 16
  %30 = load ptr, ptr %0, align 8, !tbaa !11
  %31 = icmp eq ptr %30, null
  br i1 %31, label %130, label %32

32:                                               ; preds = %23
  %33 = load i8, ptr %30, align 1, !tbaa !13
  %34 = icmp eq i8 %33, 0
  br i1 %34, label %44, label %35

35:                                               ; preds = %32, %35
  %36 = phi i32 [ %39, %35 ], [ 0, %32 ]
  %37 = phi ptr [ %38, %35 ], [ %30, %32 ]
  %38 = getelementptr inbounds i8, ptr %37, i64 1
  %39 = add nuw nsw i32 %36, 1
  %40 = load i8, ptr %38, align 1, !tbaa !13
  %41 = icmp eq i8 %40, 0
  br i1 %41, label %42, label %35, !llvm.loop !17

42:                                               ; preds = %35
  %43 = zext nneg i32 %39 to i64
  br label %44

44:                                               ; preds = %42, %32
  %45 = phi i64 [ 0, %32 ], [ %43, %42 ]
  call void @llvm.memcpy.p0.p0.i64(ptr nonnull align 16 %26, ptr nonnull readonly align 1 %30, i64 %45, i1 false)
  %46 = getelementptr inbounds i8, ptr %26, i64 %45
  store i8 0, ptr %46, align 1, !tbaa !13
  %47 = load i8, ptr %26, align 16, !tbaa !13
  %48 = icmp eq i8 %47, 0
  br i1 %48, label %63, label %49

49:                                               ; preds = %44, %49
  %50 = phi i64 [ %57, %49 ], [ 0, %44 ]
  %51 = phi i8 [ %59, %49 ], [ %47, %44 ]
  %52 = getelementptr inbounds i8, ptr %26, i64 %50
  %53 = add i8 %51, -65
  %54 = icmp ult i8 %53, 26
  %55 = or disjoint i8 %51, 32
  %56 = select i1 %54, i8 %55, i8 %51
  store i8 %56, ptr %52, align 1, !tbaa !13
  %57 = add nuw nsw i64 %50, 1
  %58 = getelementptr inbounds i8, ptr %26, i64 %57
  %59 = load i8, ptr %58, align 1, !tbaa !13
  %60 = icmp eq i8 %59, 0
  br i1 %60, label %61, label %49, !llvm.loop !21

61:                                               ; preds = %49
  %62 = getelementptr inbounds i8, ptr %26, i64 %57
  br label %63

63:                                               ; preds = %61, %44
  %64 = phi ptr [ %26, %44 ], [ %62, %61 ]
  store i8 0, ptr %64, align 1, !tbaa !13
  %65 = load i8, ptr %26, align 16, !tbaa !13
  %66 = icmp eq i8 %65, 0
  br i1 %66, label %77, label %72

67:                                               ; preds = %72
  %68 = add i64 %74, 1
  %69 = getelementptr inbounds i8, ptr %26, i64 %68
  %70 = load i8, ptr %69, align 1, !tbaa !13
  %71 = icmp eq i8 %70, 0
  br i1 %71, label %77, label %72, !llvm.loop !19

72:                                               ; preds = %63, %67
  %73 = phi i8 [ %70, %67 ], [ %65, %63 ]
  %74 = phi i64 [ %68, %67 ], [ 0, %63 ]
  %75 = add i8 %73, -65
  %76 = icmp ult i8 %75, 26
  br i1 %76, label %130, label %67

77:                                               ; preds = %67, %63
  %78 = load ptr, ptr %1, align 8, !tbaa !11
  %79 = icmp eq ptr %78, null
  br i1 %79, label %130, label %80

80:                                               ; preds = %77
  %81 = load i8, ptr %78, align 1, !tbaa !13
  %82 = icmp eq i8 %81, 0
  br i1 %82, label %92, label %83

83:                                               ; preds = %80, %83
  %84 = phi i32 [ %87, %83 ], [ 0, %80 ]
  %85 = phi ptr [ %86, %83 ], [ %78, %80 ]
  %86 = getelementptr inbounds i8, ptr %85, i64 1
  %87 = add nuw nsw i32 %84, 1
  %88 = load i8, ptr %86, align 1, !tbaa !13
  %89 = icmp eq i8 %88, 0
  br i1 %89, label %90, label %83, !llvm.loop !17

90:                                               ; preds = %83
  %91 = zext nneg i32 %87 to i64
  br label %92

92:                                               ; preds = %90, %80
  %93 = phi i64 [ 0, %80 ], [ %91, %90 ]
  call void @llvm.memcpy.p0.p0.i64(ptr nonnull align 16 %29, ptr nonnull readonly align 1 %78, i64 %93, i1 false)
  %94 = getelementptr inbounds i8, ptr %29, i64 %93
  store i8 0, ptr %94, align 1, !tbaa !13
  %95 = load i8, ptr %29, align 16, !tbaa !13
  %96 = icmp eq i8 %95, 0
  br i1 %96, label %111, label %97

97:                                               ; preds = %92, %97
  %98 = phi i64 [ %105, %97 ], [ 0, %92 ]
  %99 = phi i8 [ %107, %97 ], [ %95, %92 ]
  %100 = getelementptr inbounds i8, ptr %29, i64 %98
  %101 = add i8 %99, -65
  %102 = icmp ult i8 %101, 26
  %103 = or disjoint i8 %99, 32
  %104 = select i1 %102, i8 %103, i8 %99
  store i8 %104, ptr %100, align 1, !tbaa !13
  %105 = add nuw nsw i64 %98, 1
  %106 = getelementptr inbounds i8, ptr %29, i64 %105
  %107 = load i8, ptr %106, align 1, !tbaa !13
  %108 = icmp eq i8 %107, 0
  br i1 %108, label %109, label %97, !llvm.loop !21

109:                                              ; preds = %97
  %110 = getelementptr inbounds i8, ptr %29, i64 %105
  br label %111

111:                                              ; preds = %109, %92
  %112 = phi ptr [ %29, %92 ], [ %110, %109 ]
  store i8 0, ptr %112, align 1, !tbaa !13
  %113 = load i8, ptr %29, align 16, !tbaa !13
  %114 = icmp eq i8 %113, 0
  br i1 %114, label %125, label %120

115:                                              ; preds = %120
  %116 = add i64 %122, 1
  %117 = getelementptr inbounds i8, ptr %29, i64 %116
  %118 = load i8, ptr %117, align 1, !tbaa !13
  %119 = icmp eq i8 %118, 0
  br i1 %119, label %125, label %120, !llvm.loop !19

120:                                              ; preds = %111, %115
  %121 = phi i8 [ %118, %115 ], [ %113, %111 ]
  %122 = phi i64 [ %116, %115 ], [ 0, %111 ]
  %123 = add i8 %121, -65
  %124 = icmp ult i8 %123, 26
  br i1 %124, label %130, label %115

125:                                              ; preds = %115, %111
  %126 = load i64, ptr %12, align 8, !tbaa !12
  %127 = call i32 @bcmp(ptr nonnull %26, ptr nonnull %29, i64 %126)
  %128 = icmp eq i32 %127, 0
  %129 = select i1 %128, i32 0, i32 -13
  br label %130

130:                                              ; preds = %72, %120, %77, %23, %125
  %131 = phi i32 [ %129, %125 ], [ -14, %23 ], [ -14, %77 ], [ -14, %120 ], [ -14, %72 ]
  tail call void @llvm.stackrestore.p0(ptr %25)
  br label %132

132:                                              ; preds = %11, %3, %5, %8, %130, %19
  %133 = phi i32 [ %22, %19 ], [ %131, %130 ], [ -4, %8 ], [ -4, %5 ], [ -4, %3 ], [ -13, %11 ]
  ret i32 %133
}

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn
declare ptr @llvm.stacksave.p0() #13

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn
declare void @llvm.stackrestore.p0(ptr) #13

; Function Attrs: nofree norecurse nosync nounwind memory(argmem: readwrite) uwtable
define dso_local range(i32 -6, 18) i32 @findchar(ptr noundef readonly %0, i8 noundef signext %1, i32 noundef %2, ptr nocapture noundef writeonly %3) local_unnamed_addr #14 {
  %5 = icmp eq ptr %0, null
  br i1 %5, label %47, label %6

6:                                                ; preds = %4
  %7 = icmp eq i32 %2, 0
  %8 = load i8, ptr %0, align 1, !tbaa !13
  %9 = icmp eq i8 %8, 0
  br i1 %7, label %16, label %10

10:                                               ; preds = %6
  br i1 %9, label %43, label %11

11:                                               ; preds = %10
  %12 = add i8 %1, -65
  %13 = icmp ult i8 %12, 26
  %14 = or disjoint i8 %1, 32
  %15 = select i1 %13, i8 %14, i8 %1
  br label %17

16:                                               ; preds = %6
  br i1 %9, label %43, label %32

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
  br i1 %31, label %43, label %17, !llvm.loop !23

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
  br i1 %42, label %43, label %32, !llvm.loop !24

43:                                               ; preds = %17, %32, %10, %16
  %44 = phi i32 [ 0, %16 ], [ 0, %10 ], [ %38, %32 ], [ %27, %17 ]
  %45 = icmp eq i32 %44, 0
  br i1 %45, label %47, label %46

46:                                               ; preds = %43
  store i32 %44, ptr %3, align 4, !tbaa !25
  br label %47

47:                                               ; preds = %46, %43, %4
  %48 = phi i32 [ -6, %4 ], [ 0, %46 ], [ 17, %43 ]
  ret i32 %48
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(readwrite, inaccessiblemem: none) uwtable
define dso_local range(i32 -4, 1) i32 @exportdyntobuff(ptr noundef readonly %0, ptr nocapture noundef writeonly %1) local_unnamed_addr #8 {
  %3 = icmp eq ptr %0, null
  br i1 %3, label %10, label %4

4:                                                ; preds = %2
  %5 = load ptr, ptr %0, align 8, !tbaa !11
  %6 = icmp eq ptr %5, null
  br i1 %6, label %10, label %7

7:                                                ; preds = %4
  %8 = getelementptr inbounds i8, ptr %0, i64 8
  %9 = load i64, ptr %8, align 8, !tbaa !12
  tail call void @llvm.memcpy.p0.p0.i64(ptr align 1 %1, ptr nonnull align 1 %5, i64 %9, i1 false)
  br label %10

10:                                               ; preds = %2, %4, %7
  %11 = phi i32 [ 0, %7 ], [ -4, %4 ], [ -4, %2 ]
  ret i32 %11
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(write, argmem: readwrite, inaccessiblemem: none) uwtable
define dso_local range(i32 -4, 1) i32 @clearStr(ptr noundef %0) local_unnamed_addr #15 {
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
define dso_local range(i32 -4, 1) i32 @freeStr(ptr noundef %0) local_unnamed_addr #16 {
  %2 = icmp eq ptr %0, null
  br i1 %2, label %8, label %3

3:                                                ; preds = %1
  %4 = load ptr, ptr %0, align 8, !tbaa !11
  %5 = icmp eq ptr %4, null
  br i1 %5, label %8, label %6

6:                                                ; preds = %3
  tail call void @free(ptr noundef %4) #25
  %7 = getelementptr inbounds i8, ptr %0, i64 8
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 8 dereferenceable(16) %7, i8 0, i64 16, i1 false)
  br label %8

8:                                                ; preds = %1, %3, %6
  %9 = phi i32 [ 0, %6 ], [ -4, %3 ], [ -4, %1 ]
  ret i32 %9
}

; Function Attrs: mustprogress nounwind willreturn allockind("free") memory(argmem: readwrite, inaccessiblemem: readwrite)
declare void @free(ptr allocptr nocapture noundef) local_unnamed_addr #17

; Function Attrs: nofree norecurse nosync nounwind uwtable
define dso_local noundef i32 @kmp_search(ptr noundef readonly %0, ptr noundef readonly %1, ptr nocapture noundef %2) local_unnamed_addr #18 {
  %4 = icmp ne ptr %0, null
  %5 = icmp ne ptr %1, null
  %6 = and i1 %4, %5
  br i1 %6, label %7, label %115

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
  br i1 %16, label %17, label %10, !llvm.loop !17

17:                                               ; preds = %10, %7
  %18 = phi i32 [ 0, %7 ], [ %14, %10 ]
  %19 = load i8, ptr %1, align 1, !tbaa !13
  %20 = icmp eq i8 %19, 0
  br i1 %20, label %28, label %21

21:                                               ; preds = %17, %21
  %22 = phi i32 [ %25, %21 ], [ 0, %17 ]
  %23 = phi ptr [ %24, %21 ], [ %1, %17 ]
  %24 = getelementptr inbounds i8, ptr %23, i64 1
  %25 = add nuw nsw i32 %22, 1
  %26 = load i8, ptr %24, align 1, !tbaa !13
  %27 = icmp eq i8 %26, 0
  br i1 %27, label %28, label %21, !llvm.loop !17

28:                                               ; preds = %21, %17
  %29 = phi i32 [ 0, %17 ], [ %25, %21 ]
  %30 = icmp sgt i32 %29, %18
  br i1 %30, label %115, label %31

31:                                               ; preds = %28
  %32 = zext i32 %29 to i64
  %33 = tail call ptr @llvm.stacksave.p0()
  %34 = alloca i64, i64 %32, align 16
  %35 = sext i32 %29 to i64
  %36 = icmp eq i32 %29, 0
  br i1 %36, label %64, label %37

37:                                               ; preds = %31
  store i64 0, ptr %34, align 16, !tbaa !27
  %38 = getelementptr i8, ptr %34, i64 -8
  %39 = icmp eq i32 %29, 1
  br i1 %39, label %64, label %40

40:                                               ; preds = %37, %60
  %41 = phi i64 [ %62, %60 ], [ 1, %37 ]
  %42 = phi i64 [ %61, %60 ], [ 0, %37 ]
  %43 = getelementptr inbounds i8, ptr %1, i64 %41
  %44 = load i8, ptr %43, align 1, !tbaa !13
  %45 = getelementptr inbounds i8, ptr %1, i64 %42
  %46 = load i8, ptr %45, align 1, !tbaa !13
  %47 = icmp eq i8 %44, %46
  br i1 %47, label %48, label %52

48:                                               ; preds = %40
  %49 = add i64 %42, 1
  %50 = getelementptr inbounds i64, ptr %34, i64 %41
  store i64 %49, ptr %50, align 8, !tbaa !27
  %51 = add nuw i64 %41, 1
  br label %60

52:                                               ; preds = %40
  %53 = icmp eq i64 %42, 0
  br i1 %53, label %57, label %54

54:                                               ; preds = %52
  %55 = getelementptr i64, ptr %38, i64 %42
  %56 = load i64, ptr %55, align 8, !tbaa !27
  br label %60

57:                                               ; preds = %52
  %58 = getelementptr inbounds i64, ptr %34, i64 %41
  store i64 0, ptr %58, align 8, !tbaa !27
  %59 = add nuw i64 %41, 1
  br label %60

60:                                               ; preds = %57, %54, %48
  %61 = phi i64 [ %49, %48 ], [ %56, %54 ], [ 0, %57 ]
  %62 = phi i64 [ %51, %48 ], [ %41, %54 ], [ %59, %57 ]
  %63 = icmp ult i64 %62, %35
  br i1 %63, label %40, label %64, !llvm.loop !28

64:                                               ; preds = %60, %31, %37
  %65 = phi i32 [ -6, %31 ], [ 0, %37 ], [ 0, %60 ]
  br i1 %36, label %113, label %66

66:                                               ; preds = %64
  %67 = sext i32 %18 to i64
  %68 = getelementptr i8, ptr %34, i64 -8
  %69 = icmp eq i32 %18, 0
  br i1 %69, label %105, label %70

70:                                               ; preds = %66
  %71 = getelementptr inbounds i8, ptr %2, i64 8
  %72 = getelementptr i64, ptr %34, i64 %35
  %73 = getelementptr i8, ptr %72, i64 -8
  br label %74

74:                                               ; preds = %70, %100
  %75 = phi i64 [ 0, %70 ], [ %103, %100 ]
  %76 = phi i64 [ 0, %70 ], [ %102, %100 ]
  %77 = phi i64 [ 0, %70 ], [ %101, %100 ]
  %78 = getelementptr inbounds i8, ptr %0, i64 %77
  %79 = load i8, ptr %78, align 1, !tbaa !13
  %80 = getelementptr inbounds i8, ptr %1, i64 %76
  %81 = load i8, ptr %80, align 1, !tbaa !13
  %82 = icmp eq i8 %79, %81
  br i1 %82, label %83, label %93

83:                                               ; preds = %74
  %84 = add nuw i64 %77, 1
  %85 = add i64 %76, 1
  %86 = icmp eq i64 %85, %35
  br i1 %86, label %87, label %100

87:                                               ; preds = %83
  %88 = sub i64 %77, %76
  %89 = load ptr, ptr %71, align 8, !tbaa !29
  %90 = getelementptr inbounds i64, ptr %89, i64 %75
  store i64 %88, ptr %90, align 8, !tbaa !27
  %91 = add i64 %75, 1
  %92 = load i64, ptr %73, align 8, !tbaa !27
  br label %100

93:                                               ; preds = %74
  %94 = icmp eq i64 %76, 0
  br i1 %94, label %98, label %95

95:                                               ; preds = %93
  %96 = getelementptr i64, ptr %68, i64 %76
  %97 = load i64, ptr %96, align 8, !tbaa !27
  br label %100

98:                                               ; preds = %93
  %99 = add nuw i64 %77, 1
  br label %100

100:                                              ; preds = %95, %98, %83, %87
  %101 = phi i64 [ %84, %87 ], [ %84, %83 ], [ %77, %95 ], [ %99, %98 ]
  %102 = phi i64 [ %92, %87 ], [ %85, %83 ], [ %97, %95 ], [ 0, %98 ]
  %103 = phi i64 [ %91, %87 ], [ %75, %83 ], [ %75, %95 ], [ %75, %98 ]
  %104 = icmp ult i64 %101, %67
  br i1 %104, label %74, label %105, !llvm.loop !31

105:                                              ; preds = %100, %66
  %106 = phi i64 [ 0, %66 ], [ %103, %100 ]
  %107 = icmp eq i64 %106, 0
  br i1 %107, label %108, label %110

108:                                              ; preds = %105
  %109 = getelementptr inbounds i8, ptr %2, i64 8
  store ptr null, ptr %109, align 8, !tbaa !29
  br label %110

110:                                              ; preds = %105, %108
  %111 = phi i64 [ 0, %108 ], [ %106, %105 ]
  %112 = phi i32 [ -16, %108 ], [ 0, %105 ]
  store i64 %111, ptr %2, align 8, !tbaa !32
  br label %113

113:                                              ; preds = %64, %110
  %114 = phi i32 [ %112, %110 ], [ %65, %64 ]
  tail call void @llvm.stackrestore.p0(ptr %33)
  br label %115

115:                                              ; preds = %113, %28, %3
  %116 = phi i32 [ -6, %3 ], [ %114, %113 ], [ -6, %28 ]
  ret i32 %116
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read) uwtable
define dso_local range(i32 -16, 1) i32 @isin(ptr noundef readonly %0) local_unnamed_addr #19 {
  %2 = icmp eq ptr %0, null
  br i1 %2, label %7, label %3

3:                                                ; preds = %1
  %4 = load i64, ptr %0, align 8, !tbaa !32
  %5 = icmp eq i64 %4, 0
  %6 = select i1 %5, i32 -16, i32 0
  br label %7

7:                                                ; preds = %3, %1
  %8 = phi i32 [ -15, %1 ], [ %6, %3 ]
  ret i32 %8
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(read, argmem: readwrite, inaccessiblemem: none) uwtable
define dso_local range(i32 -16, 1) i32 @firstOccurrence(ptr noundef readonly %0, ptr nocapture noundef writeonly %1) local_unnamed_addr #20 {
  %3 = icmp eq ptr %0, null
  br i1 %3, label %17, label %4

4:                                                ; preds = %2
  %5 = load i64, ptr %0, align 8, !tbaa !32
  %6 = icmp eq i64 %5, 0
  br i1 %6, label %14, label %7

7:                                                ; preds = %4
  %8 = getelementptr inbounds i8, ptr %0, i64 8
  %9 = load ptr, ptr %8, align 8, !tbaa !29
  %10 = icmp eq ptr %9, null
  br i1 %10, label %14, label %11

11:                                               ; preds = %7
  %12 = load i64, ptr %9, align 8, !tbaa !27
  %13 = trunc i64 %12 to i32
  br label %14

14:                                               ; preds = %4, %7, %11
  %15 = phi i32 [ %13, %11 ], [ -1, %7 ], [ -1, %4 ]
  %16 = phi i32 [ 0, %11 ], [ -16, %7 ], [ -16, %4 ]
  store i32 %15, ptr %1, align 4, !tbaa !25
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
  %6 = load i64, ptr %0, align 8, !tbaa !32
  %7 = icmp eq i64 %6, 0
  br i1 %7, label %12, label %8

8:                                                ; preds = %5
  %9 = getelementptr inbounds i8, ptr %0, i64 8
  %10 = load ptr, ptr %9, align 8, !tbaa !29
  %11 = icmp eq ptr %10, null
  br i1 %11, label %12, label %13

12:                                               ; preds = %8, %5
  store i32 -1, ptr %2, align 4, !tbaa !25
  store ptr null, ptr %1, align 8, !tbaa !18
  br label %15

13:                                               ; preds = %8
  store ptr %10, ptr %1, align 8, !tbaa !18
  %14 = trunc i64 %6 to i32
  store i32 %14, ptr %2, align 4, !tbaa !25
  br label %15

15:                                               ; preds = %3, %13, %12
  %16 = phi i32 [ -16, %12 ], [ 0, %13 ], [ -15, %3 ]
  ret i32 %16
}

; Function Attrs: nofree nounwind willreturn memory(argmem: read)
declare i32 @bcmp(ptr nocapture, ptr nocapture, i64) local_unnamed_addr #21

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr nocapture writeonly, i8, i64, i1 immarg) #22

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
attributes #11 = { nofree norecurse nosync nounwind memory(readwrite, inaccessiblemem: none) uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #12 = { nofree nounwind uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #13 = { mustprogress nocallback nofree nosync nounwind willreturn }
attributes #14 = { nofree norecurse nosync nounwind memory(argmem: readwrite) uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #15 = { mustprogress nofree norecurse nosync nounwind willreturn memory(write, argmem: readwrite, inaccessiblemem: none) uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #16 = { mustprogress nounwind willreturn uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #17 = { mustprogress nounwind willreturn allockind("free") memory(argmem: readwrite, inaccessiblemem: readwrite) "alloc-family"="malloc" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #18 = { nofree norecurse nosync nounwind uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #19 = { mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read) uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #20 = { mustprogress nofree norecurse nosync nounwind willreturn memory(read, argmem: readwrite, inaccessiblemem: none) uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #21 = { nofree nounwind willreturn memory(argmem: read) }
attributes #22 = { nocallback nofree nounwind willreturn memory(argmem: write) }
attributes #23 = { nounwind allocsize(0) }
attributes #24 = { nounwind allocsize(1) }
attributes #25 = { nounwind }

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
!14 = distinct !{!14, !15, !16}
!15 = !{!"llvm.loop.mustprogress"}
!16 = !{!"llvm.loop.unroll.disable"}
!17 = distinct !{!17, !15, !16}
!18 = !{!7, !7, i64 0}
!19 = distinct !{!19, !15, !16}
!20 = distinct !{!20, !15, !16}
!21 = distinct !{!21, !15, !16}
!22 = distinct !{!22, !15, !16}
!23 = distinct !{!23, !15, !16}
!24 = distinct !{!24, !15, !16}
!25 = !{!26, !26, i64 0}
!26 = !{!"int", !8, i64 0}
!27 = !{!10, !10, i64 0}
!28 = distinct !{!28, !15, !16}
!29 = !{!30, !7, i64 8}
!30 = !{!"", !10, i64 0, !7, i64 8}
!31 = distinct !{!31, !15, !16}
!32 = !{!30, !10, i64 0}
