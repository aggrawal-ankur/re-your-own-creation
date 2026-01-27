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
  %11 = icmp eq i8 %10, 0       ; src[0] == '\0'
  br i1 %11, label %21, label %12

12:                                               ; preds = %9, %12
  %13 = phi i32 [ %16, %12 ], [ 0, %9 ]     ; len=0
  %14 = phi ptr [ %15, %12 ], [ %1, %9 ]    ; ptr=&src[0]
  %15 = getelementptr inbounds i8, ptr %14, i64 1   ; ptr=&src[1]
  %16 = add nuw nsw i32 %13, 1      ; len++   (len is incremented before condition check because it started from block9 and the condition was checked there)
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
  %25 = add i64 %24, %22     ; add(dest.len, lenstr(src))==nlen
  %26 = add i64 %25, 1       ; nlen+1
  %27 = getelementptr inbounds i8, ptr %0, i64 16
  %28 = load i64, ptr %27, align 8, !tbaa !5      ; dest.cap
  %29 = icmp ult i64 %28, %26     ; dest.cap < nlen+1
  br i1 %29, label %30, label %40

30:                                               ; preds = %21
  %31 = add i64 %25, 2     ; add(dest.len, lenstr(src))==nlen+1+1 (Why was nlen+1 not reused)
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
  %4 = icmp eq ptr %0, null       ; !str
  br i1 %4, label %14, label %5

5:                                                ; preds = %3
  %6 = load ptr, ptr %0, align 8, !tbaa !11
  %7 = icmp eq ptr %6, null       ; !str.data
  br i1 %7, label %14, label %8

8:                                                ; preds = %5
  %9 = getelementptr inbounds i8, ptr %0, i64 8
  %10 = load i64, ptr %9, align 8, !tbaa !12
  %11 = icmp ugt i64 %10, %1        ; boundcheck inlined
  br i1 %11, label %12, label %14

12:                                               ; preds = %8
  %13 = getelementptr inbounds i8, ptr %6, i64 %1       ; &str.data[%1]
  store ptr %13, ptr %2, align 8, !tbaa !18
  br label %14

14:                                               ; preds = %8, %3, %5, %12
  %15 = phi i32 [ 0, %12 ], [ -4, %5 ], [ -4, %3 ], [ -7, %8 ]
  ret i32 %15
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(readwrite, inaccessiblemem: none) uwtable
define dso_local range(i32 -8, 1) i32 @getslicedstr(ptr noundef readonly %0, i64 noundef %1, i64 noundef %2, ptr nocapture noundef writeonly %3) local_unnamed_addr #8 {
  %5 = icmp eq ptr %0, null       ; !str
  br i1 %5, label %19, label %6

6:                                                ; preds = %4
  %7 = load ptr, ptr %0, align 8, !tbaa !11
  %8 = icmp eq ptr %7, null       ; !str.data
  br i1 %8, label %19, label %9

9:                                                ; preds = %6
  %10 = getelementptr inbounds i8, ptr %0, i64 8      ; &str.len
  %11 = load i64, ptr %10, align 8, !tbaa !12         ; str.len
  %12 = icmp ugt i64 %11, %1        ; str.len > start
  %13 = icmp ugt i64 %11, %2        ; str.len > end
  %14 = and i1 %12, %13
  br i1 %14, label %15, label %19

15:                                               ; preds = %9
  %16 = sub i64 %2, %1        ; end-start
  %17 = getelementptr inbounds i8, ptr %7, i64 %1
  tail call void @llvm.memcpy.p0.p0.i64(ptr align 1 %3, ptr nonnull align 1 %17, i64 %16, i1 false)
  %18 = getelementptr inbounds i8, ptr %3, i64 %16    ; out[end-start]
  store i8 0, ptr %18, align 1, !tbaa !13             ; out[end-start]='\0'
  br label %19

19:                                               ; preds = %9, %4, %6, %15
  %20 = phi i32 [ 0, %15 ], [ -4, %6 ], [ -4, %4 ], [ -8, %9 ]
  ret i32 %20
}

; Function Attrs: nofree norecurse nosync nounwind memory(read, argmem: readwrite, inaccessiblemem: none) uwtable
define dso_local range(i32 -6, 7) i32 @copystr(ptr noundef readonly %0, ptr nocapture noundef writeonly %1) local_unnamed_addr #9 {
  %3 = icmp eq ptr %0, null       ; !src
  br i1 %3, label %19, label %4

4:                                                ; preds = %2
  %5 = load i8, ptr %0, align 1, !tbaa !13
  %6 = icmp eq i8 %5, 0         ; !src[0] == '\0'
  br i1 %6, label %16, label %7

7:            ; lenstr inlined                    ; preds = %4, %7
  %8 = phi i32 [ %11, %7 ], [ 0, %4 ]       ;   len=0 (init)
  %9 = phi ptr [ %10, %7 ], [ %0, %4 ]      ;   ptr=src
  %10 = getelementptr inbounds i8, ptr %9, i64 1    ; &src[1]
  %11 = add nuw nsw i32 %8, 1       ; len++
  %12 = load i8, ptr %10, align 1, !tbaa !13
  %13 = icmp eq i8 %12, 0       ; src[1] == '\0'
  br i1 %13, label %14, label %7, !llvm.loop !17

14:                                               ; preds = %7
  %15 = zext nneg i32 %11 to i64      ; zero-extend the computed length
  br label %16

16:                                               ; preds = %14, %4
  %17 = phi i64 [ 0, %4 ], [ %15, %14 ]
  tail call void @llvm.memcpy.p0.p0.i64(ptr align 1 %1, ptr nonnull align 1 %0, i64 %17, i1 false)
  %18 = getelementptr inbounds i8, ptr %1, i64 %17
  store i8 0, ptr %18, align 1, !tbaa !13       ; dest[len]='\0'
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
  %2 = icmp eq ptr %0, null       ; !str
  br i1 %2, label %16, label %3

3:                                                ; preds = %1
  %4 = load i8, ptr %0, align 1, !tbaa !13      ; str[0]
  %5 = icmp eq i8 %4, 0       ; str[0] == '\0'
  br i1 %5, label %16, label %11

6:                                                ; preds = %11
  %7 = add i64 %13, 1       ; i++
  %8 = getelementptr inbounds i8, ptr %0, i64 %7    ; &str[i] (starting from i=1)
  %9 = load i8, ptr %8, align 1, !tbaa !13        ; str[i]
  %10 = icmp eq i8 %9, 0    ; str[i] == '\0'
  br i1 %10, label %16, label %11, !llvm.loop !19

11:                                               ; preds = %3, %6
  %12 = phi i8 [ %9, %6 ], [ %4, %3 ]     ; str[0] (init)
  %13 = phi i64 [ %7, %6 ], [ 0, %3 ]     ; i=0 (init)
  %14 = add i8 %12, -65       ; ascii_dec(str[..]) - 65
  %15 = icmp ult i8 %14, 26   ; %14 in [0, 26)
  br i1 %15, label %16, label %6

16:                                               ; preds = %11, %6, %3, %1
  %17 = phi i32 [ -6, %1 ], [ 0, %3 ], [ 0, %6 ], [ -9, %11 ]
  ret i32 %17
}

; Function Attrs: nofree norecurse nosync nounwind memory(argmem: read) uwtable
define dso_local range(i32 -10, 1) i32 @isucase(ptr noundef readonly %0) local_unnamed_addr #10 {
  %2 = icmp eq ptr %0, null       ; !str
  br i1 %2, label %16, label %3

3:                                                ; preds = %1
  %4 = load i8, ptr %0, align 1, !tbaa !13    ; str[0]
  %5 = icmp eq i8 %4, 0     ; str[0] == '\0'
  br i1 %5, label %16, label %11

6:                                                ; preds = %11
  %7 = add i64 %13, 1       ; i++ (init val 0)
  %8 = getelementptr inbounds i8, ptr %0, i64 %7     ; &str[%7]
  %9 = load i8, ptr %8, align 1, !tbaa !13        ; str[i]
  %10 = icmp eq i8 %9, 0      ; str[i] == '\0'
  br i1 %10, label %16, label %11, !llvm.loop !20

11:                                               ; preds = %3, %6
  %12 = phi i8 [ %9, %6 ], [ %4, %3 ]     ; str[0] (init)
  %13 = phi i64 [ %7, %6 ], [ 0, %3 ]     ; i=0 (init)
  %14 = add i8 %12, -97       ; ascii_dec(str[..]) - 97
  %15 = icmp ult i8 %14, 26   ; %14 in [0, 26)
  br i1 %15, label %16, label %6

16:                                               ; preds = %11, %6, %3, %1
  %17 = phi i32 [ -6, %1 ], [ 0, %3 ], [ 0, %6 ], [ -10, %11 ]
  ret i32 %17
}

; Function Attrs: nofree norecurse nosync nounwind memory(readwrite, inaccessiblemem: none) uwtable
define dso_local noundef i32 @tolcase(ptr noundef readonly %0, ptr nocapture noundef %1) local_unnamed_addr #11 {
  %3 = icmp eq ptr %0, null     ; !str
  br i1 %3, label %46, label %4

4:                                                ; preds = %2
  %5 = load i8, ptr %0, align 1, !tbaa !13    ; str[0]
  %6 = icmp eq i8 %5, 0   ; str[0] == '\0'
  br i1 %6, label %16, label %7

7:              ; lesntr inlined                  ; preds = %4, %7
  %8 = phi i32 [ %11, %7 ], [ 0, %4 ]     ; len=0 (init val)
  %9 = phi ptr [ %10, %7 ], [ %0, %4 ]    ; ptr=str[0] (init val)
  %10 = getelementptr inbounds i8, ptr %9, i64 1     ; &str[.. + 1]
  %11 = add nuw nsw i32 %8, 1     ; len++
  %12 = load i8, ptr %10, align 1, !tbaa !13    ; str[.. + 1]
  %13 = icmp eq i8 %12, 0      ; str[.. + 1] == '\0'
  br i1 %13, label %14, label %7, !llvm.loop !17

14:                                               ; preds = %7
  %15 = zext nneg i32 %11 to i64    ; zero extend len to i64
  br label %16

16:               ; copystr inlined               ; preds = %14, %4
  %17 = phi i64 [ 0, %4 ], [ %15, %14 ]   ; computed len
  tail call void @llvm.memcpy.p0.p0.i64(ptr align 1 %1, ptr nonnull readonly align 1 %0, i64 %17, i1 false)
  %18 = getelementptr inbounds i8, ptr %1, i64 %17    ; &lcase[%17] (the end of lcase)
  store i8 0, ptr %18, align 1, !tbaa !13     ; lcase[len] = '\0'
  %19 = load i8, ptr %1, align 1, !tbaa !13   ; lcase[0]
  %20 = icmp eq i8 %19, 0         ; lcase[0] = '\0'
  br i1 %20, label %46, label %21

21:          ; char2lcase inlined                 ; preds = %16, %21
  %22 = phi i64 [ %29, %21 ], [ 0, %16 ]       ; i=0 (init val)
  %23 = phi i8 [ %31, %21 ], [ %19, %16 ]      ; 
  %24 = getelementptr inbounds i8, ptr %1, i64 %22    ; &lcase[0]
  %25 = add i8 %23, -65       ; ascii_dec(lcase[0]) - 65
  %26 = icmp ult i8 %25, 26   ; %25 in [0, 26)
  %27 = or disjoint i8 %23, 32    ; (turn ON the 6th bit from LHS (mag:32))
  %28 = select i1 %26, i8 %27, i8 %23       ; select the right value of character after conversion to lcase
  store i8 %28, ptr %24, align 1, !tbaa !13     ; lcase[i] = char2lcase(lcase[i])
  %29 = add nuw nsw i64 %22, 1      ; i++
  %30 = getelementptr inbounds i8, ptr %1, i64 %29    ; &lcase[%29]
  %31 = load i8, ptr %30, align 1, !tbaa !13       ; lcase[i]
  %32 = icmp eq i8 %31, 0       ; lcase[i] == '\0'
  br i1 %32, label %33, label %21, !llvm.loop !21

33:                                               ; preds = %21, %16
  %34 = load i8, ptr %1, align 1, !tbaa !13     ; lcase[0]
  %35 = icmp eq i8 %34, 0         ; lcase[0] == '\0'
  br i1 %35, label %46, label %41

36:                                               ; preds = %41
  %37 = add i64 %43, 1    ; i++ (init val 0)
  %38 = getelementptr inbounds i8, ptr %1, i64 %37    ; &lcase[i]
  %39 = load i8, ptr %38, align 1, !tbaa !13        ; lcase[i]
  %40 = icmp eq i8 %39, 0       ; lcase[0] == '\0'
  br i1 %40, label %46, label %41, !llvm.loop !19

41:            ; islcase inlined                  ; preds = %33, %36
  %42 = phi i8 [ %39, %36 ], [ %34, %33 ]   ; lcase[0] (init val)
  %43 = phi i64 [ %37, %36 ], [ 0, %33 ]    ; i=0 (init val)
  %44 = add i8 %42, -65         ; ascii_dec(lcase[0]) - 65
  %45 = icmp ult i8 %44, 26     ; %47 in 0, 26)
  br i1 %45, label %46, label %36

46:                                               ; preds = %41, %36, %33, %2
  %47 = phi i32 [ -6, %2 ], [ 0, %33 ], [ 0, %36 ], [ -11, %41 ]
  ret i32 %47
}

; Function Attrs: nofree norecurse nosync nounwind memory(readwrite, inaccessiblemem: none) uwtable
define dso_local noundef i32 @toucase(ptr noundef readonly %0, ptr nocapture noundef %1) local_unnamed_addr #11 {
  %3 = icmp eq ptr %0, null       ; !str
  br i1 %3, label %46, label %4

4:                                                ; preds = %2
  %5 = load i8, ptr %0, align 1, !tbaa !13    ; str[0]
  %6 = icmp eq i8 %5, 0   ; str[0] == '\0'
  br i1 %6, label %16, label %7

7:              ; lenstr inlined                  ; preds = %4, %7
  %8 = phi i32 [ %11, %7 ], [ 0, %4 ]     ; len=0 (init val)
  %9 = phi ptr [ %10, %7 ], [ %0, %4 ]    ; ptr=str[0] (init val)
  %10 = getelementptr inbounds i8, ptr %9, i64 1    ; str[..+1]
  %11 = add nuw nsw i32 %8, 1    ; len++
  %12 = load i8, ptr %10, align 1, !tbaa !13
  %13 = icmp eq i8 %12, 0   ; str[.] == '\0'
  br i1 %13, label %14, label %7, !llvm.loop !17

14:                                               ; preds = %7
  %15 = zext nneg i32 %11 to i64      ; zero-extend len to i64
  br label %16

16:              ; copystr inlined                ; preds = %14, %4
  %17 = phi i64 [ 0, %4 ], [ %15, %14 ]     ; computed len
  tail call void @llvm.memcpy.p0.p0.i64(ptr align 1 %1, ptr nonnull readonly align 1 %0, i64 %17, i1 false)
  %18 = getelementptr inbounds i8, ptr %1, i64 %17    ; &ucase[len]  (the end of ucase)
  store i8 0, ptr %18, align 1, !tbaa !13       ; ucase[len] = '\0'
  %19 = load i8, ptr %1, align 1, !tbaa !13   ; ucase[0]
  %20 = icmp eq i8 %19, 0     ; ucase[0] = '\0'
  br i1 %20, label %33, label %21

21:            ; char2ucase inlined               ; preds = %16, %21
  %22 = phi i64 [ %29, %21 ], [ 0, %16 ]     ; i=0 (init val)
  %23 = phi i8 [ %31, %21 ], [ %19, %16 ]    ; ucase (init val)
  %24 = getelementptr inbounds i8, ptr %1, i64 %22    ; ucase[%22] or ucase[i]
  %25 = add i8 %23, -97       ; ascii_dec(ucase[i]) -97
  %26 = icmp ult i8 %25, 26   ; %25 in [0, 26)
  %27 = and i8 %23, 95        ; turn the 6th bit from LHS OFF (that gives mag:32)
  %28 = select i1 %26, i8 %27, i8 %23     ; choose the appropriate value of character after conversion
  store i8 %28, ptr %24, align 1, !tbaa !13     ; ucase[i] = char2ucase(ucase[i])
  %29 = add nuw nsw i64 %22, 1      ; i++
  %30 = getelementptr inbounds i8, ptr %1, i64 %29    ; &ucase[%29] or &ucase[i]
  %31 = load i8, ptr %30, align 1, !tbaa !13    ; ucase[i]
  %32 = icmp eq i8 %31, 0       ; ucase[i] == '\0'
  br i1 %32, label %33, label %21, !llvm.loop !22

33:                                               ; preds = %21, %16
  %34 = load i8, ptr %1, align 1, !tbaa !13   ; ucase[0]
  %35 = icmp eq i8 %34, 0       ; ucase[0] == '\0'
  br i1 %35, label %46, label %41

36:                                               ; preds = %41
  %37 = add i64 %43, 1    ; i++
  %38 = getelementptr inbounds i8, ptr %1, i64 %37    ; &ucase[%37] or &ucase[i]
  %39 = load i8, ptr %38, align 1, !tbaa !13      ; ucase[i]
  %40 = icmp eq i8 %39, 0     ; ucase[i] == '\0'
  br i1 %40, label %46, label %41, !llvm.loop !20

41:            ; isucase inlined                  ; preds = %33, %36
  %42 = phi i8 [ %39, %36 ], [ %34, %33 ]   ; ucase[0] (init val)
  %43 = phi i64 [ %37, %36 ], [ 0, %33 ]    ; i=0 (init val)
  %44 = add i8 %42, -97     ; ascii_dec(ucase[0]) - 97
  %45 = icmp ult i8 %44, 26     ; %44 in [0, 26)
  br i1 %45, label %46, label %36

46:                                               ; preds = %41, %36, %33, %2
  %47 = phi i32 [ -6, %2 ], [ 0, %33 ], [ 0, %36 ], [ -12, %41 ]
  ret i32 %47
}

; Function Attrs: nofree nounwind uwtable
define dso_local range(i32 -14, 1) i32 @cmp2strs(ptr noundef readonly %0, ptr noundef readonly %1, i32 noundef %2) local_unnamed_addr #11 {
  %4 = icmp eq ptr %0, null       ; !str1
  br i1 %4, label %128, label %5

5:                                                ; preds = %3
  %6 = load ptr, ptr %0, align 8, !tbaa !11   ; str1.data
  %7 = icmp ne ptr %6, null   ; !str1.data
  %8 = icmp ne ptr %1, null   ; !str2
  %9 = and i1 %8, %7
  br i1 %9, label %10, label %128

10:                                               ; preds = %5
  %11 = load ptr, ptr %1, align 8, !tbaa !11    ; str2.data
  %12 = icmp eq ptr %11, null       ; !str2.data
  br i1 %12, label %128, label %13

13:                                               ; preds = %10
  %14 = getelementptr inbounds i8, ptr %0, i64 8    ; &str1.len
  %15 = load i64, ptr %14, align 8, !tbaa !12       ; str1.len
  %16 = getelementptr inbounds i8, ptr %1, i64 8    ; &str2.len
  %17 = load i64, ptr %16, align 8, !tbaa !12       ; str2.len
  %18 = icmp eq i64 %15, %17         ; str1.len == str2.len
  br i1 %18, label %19, label %128

19:                                               ; preds = %13
  %20 = icmp eq i32 %2, 0         ; sensitivity == 0
  br i1 %20, label %21, label %25

21:                                               ; preds = %19
  %22 = tail call i32 @bcmp(ptr nonnull %6, ptr nonnull %11, i64 %15)   ; memcmp(str1.data, str2.data)
  %23 = icmp eq i32 %22, 0      ; 0 for success
  %24 = select i1 %23, i32 0, i32 -13
  br label %128     ; ret block

25:                                               ; preds = %19
  %26 = add i64 %15, 1    ; str1.len + 1 (to count for '\0')
  %27 = tail call ptr @llvm.stacksave.p0()
  %28 = alloca i8, i64 %26, align 16        ; Allocate tmp1[%26] on stack
  %29 = load i64, ptr %16, align 8, !tbaa !12
  %30 = add i64 %29, 1    ; str2.len + 1 (to count for '\0')
  %31 = alloca i8, i64 %30, align 16        ; tmp2[%31]
  ; tolcase(str1->data, tmp1) inlined
  %32 = load ptr, ptr %0, align 8, !tbaa !11    ; &str1.data
  %33 = icmp eq ptr %32, null       ; !str1.data
  br i1 %33, label %126, label %34

34:                                               ; preds = %25
  %35 = load i8, ptr %32, align 1, !tbaa !13    ; str1.data[0]
  %36 = icmp eq i8 %35, 0       ; str1.data[0] == '\0'
  br i1 %36, label %46, label %37

37:                                               ; preds = %34, %37
  %38 = phi i32 [ %41, %37 ], [ 0, %34 ]      ; len=0 (init val)
  %39 = phi ptr [ %40, %37 ], [ %32, %34 ]    ; &str1.data
  %40 = getelementptr inbounds i8, ptr %39, i64 1   ; &str1.data[..+1]
  %41 = add nuw nsw i32 %38, 1    ; len++
  %42 = load i8, ptr %40, align 1, !tbaa !13    ; str1.data[.]
  %43 = icmp eq i8 %42, 0    ; str1.data[.] == '\0'
  br i1 %43, label %44, label %37, !llvm.loop !17

44:                                               ; preds = %37
  %45 = zext nneg i32 %41 to i64      ; zero-extend len to i64
  br label %46

46:       ; copystr(str1.data, tmp1) inlined      ; preds = %44, %34
  %47 = phi i64 [ 0, %34 ], [ %45, %44 ]    ; computed len
  call void @llvm.memcpy.p0.p0.i64(ptr nonnull align 16 %28, ptr nonnull readonly align 1 %32, i64 %47, i1 false)
  %48 = getelementptr inbounds i8, ptr %28, i64 %47    ; &tmp1[len]  (the end of tmp1 buff)
  store i8 0, ptr %48, align 1, !tbaa !13       ; tmp1[len] = '\0'
  %49 = load i8, ptr %28, align 16, !tbaa !13   ; tmp1[0]
  %50 = icmp eq i8 %49, 0     ; tmp1[0] == '\0'
  br i1 %50, label %76, label %51

51:            ; char2lcase loop inlined          ; preds = %46, %51
  %52 = phi i64 [ %59, %51 ], [ 0, %46 ]     ; i=0 (init val)
  %53 = phi i8 [ %61, %51 ], [ %49, %46 ]    ; tmp1[0]
  %54 = getelementptr inbounds i8, ptr %28, i64 %52   ; tmp1[i]
  %55 = add i8 %53, -65       ; ascii_dec(tmp1[i]) - 65
  %56 = icmp ult i8 %55, 26   ; %55 in [0, 26)
  %57 = or disjoint i8 %53, 32    ; Turn the 6th bit (mag:32) ON
  %58 = select i1 %56, i8 %57, i8 %53     ; choose the right char value after conversion
  store i8 %58, ptr %54, align 1, !tbaa !13     ; tmp[1] = char2lcase(tmp[1])
  %59 = add nuw nsw i64 %52, 1      ; i++
  %60 = getelementptr inbounds i8, ptr %28, i64 %59     ; &tmp1[i]
  %61 = load i8, ptr %60, align 1, !tbaa !13    ; tmp1[i]
  %62 = icmp eq i8 %61, 0     ; tmp1[i] == '\0'
  br i1 %62, label %63, label %51, !llvm.loop !21

63:                                               ; preds = %51, %46
  %64 = load i8, ptr %28, align 16, !tbaa !13   ; tmp1[0]
  %65 = icmp eq i8 %64, 0     ; tmp1[0] == '\0'
  br i1 %65, label %76, label %71

66:            ; islcase inlined                  ; preds = %71
  %67 = add i64 %73, 1    ; i++ (init val 0)
  %68 = getelementptr inbounds i8, ptr %28, i64 %67   ; &tmp1[%67] or tmp1[i]
  %69 = load i8, ptr %68, align 1, !tbaa !13    ; tmp1[i]
  %70 = icmp eq i8 %69, 0     ; tmp1[i] == '\0'
  br i1 %70, label %76, label %71, !llvm.loop !19

71:                                               ; preds = %63, %66
  %72 = phi i8 [ %69, %66 ], [ %64, %63 ]   ; tmp1[0]
  %73 = phi i64 [ %67, %66 ], [ 0, %63 ]    ; i=0 (init val)
  %74 = add i8 %72, -65         ; ascii_dec(tmp1[0]) - 65
  %75 = icmp ult i8 %74, 26     ; %74 in [0, 26)
  br i1 %75, label %126, label %66

76:                                               ; preds = %66, %63
  %77 = load ptr, ptr %1, align 8, !tbaa !11    ; str2.data
  %78 = icmp eq ptr %77, null       ; !str2.data
  br i1 %78, label %126, label %79

79:      ; copystr(str2.data, tmp2) inlined       ; preds = %76
  %80 = load i8, ptr %77, align 1, !tbaa !13   ; str2.data[0]
  %81 = icmp eq i8 %80, 0   ; str2.data[0] == '\0'
  br i1 %81, label %91, label %82

82:              ; lenstr inlined               ; preds = %79, %82
  %83 = phi i32 [ %86, %82 ], [ 0, %79 ]      ; len=0 (init val)
  %84 = phi ptr [ %85, %82 ], [ %77, %79 ]    ; ptr=str2.data (init val)
  %85 = getelementptr inbounds i8, ptr %84, i64 1   ; str2.data[..+1]
  %86 = add nuw nsw i32 %83, 1      ; len++
  %87 = load i8, ptr %85, align 1, !tbaa !13    ; str2.data[.]
  %88 = icmp eq i8 %87, 0     ; str2.data[.] == '\0'
  br i1 %88, label %89, label %82, !llvm.loop !17

89:                                               ; preds = %82
  %90 = zext nneg i32 %86 to i64    ; zero-extend to i64
  br label %91

91:                                               ; preds = %89, %79
  %92 = phi i64 [ 0, %79 ], [ %90, %89 ]    ; computed len
  call void @llvm.memcpy.p0.p0.i64(ptr nonnull align 16 %31, ptr nonnull readonly align 1 %77, i64 %92, i1 false)
  %93 = getelementptr inbounds i8, ptr %31, i64 %92   ; &tmp2[len]
  store i8 0, ptr %93, align 1, !tbaa !13       ; tmp2[len] == '\0'
  %94 = load i8, ptr %31, align 16, !tbaa !13   ; tmp2[0]
  %95 = icmp eq i8 %94, 0         ; tmp2[0] == '\0'
  br i1 %95, label %108, label %96

96:                                               ; preds = %91, %96
  %97 = phi i64 [ %104, %96 ], [ 0, %91 ]     ; i=0 (init val)
  %98 = phi i8 [ %106, %96 ], [ %94, %91 ]    ; tmp2[0] (init val)
  %99 = getelementptr inbounds i8, ptr %31, i64 %97   ; &tmp2[%97] or tmp2[i]
  %100 = add i8 %98, -65          ; ascii_dec(tmp2[i]) - 65
  %101 = icmp ult i8 %100, 26     ; %100 in [0, 26)
  %102 = or disjoint i8 %98, 32   ; turn the 6th bit (mag:32) ON
  %103 = select i1 %101, i8 %102, i8 %98    ; choose the correct char after conversion
  store i8 %103, ptr %99, align 1, !tbaa !13    ; tmp2[i] = char2lcase(tmp2[i])
  %104 = add nuw nsw i64 %97, 1   ; i++
  %105 = getelementptr inbounds i8, ptr %31, i64 %104     ; &tmp2[i]
  %106 = load i8, ptr %105, align 1, !tbaa !13    ;tmp2[i]
  %107 = icmp eq i8 %106, 0   ; tmp2[i] == '\0'
  br i1 %107, label %108, label %96, !llvm.loop !21

108:          ; islcase inlined                   ; preds = %96, %91
  %109 = load i8, ptr %31, align 16, !tbaa !13  ; tmp2[0]
  %110 = icmp eq i8 %109, 0     ; tmp2[0] == '\0'
  br i1 %110, label %121, label %116

111:                                              ; preds = %116
  %112 = add i64 %118, 1     ; i++
  %113 = getelementptr inbounds i8, ptr %31, i64 %112    ; &tmp2[i]
  %114 = load i8, ptr %113, align 1, !tbaa !13      ; tmp2[i]
  %115 = icmp eq i8 %114, 0     ; tmp2[i] == '\0'
  br i1 %115, label %121, label %116, !llvm.loop !19

116:                                              ; preds = %108, %111
  %117 = phi i8 [ %114, %111 ], [ %109, %108 ]    ; tmp2[0] (init val)
  %118 = phi i64 [ %112, %111 ], [ 0, %108 ]      ; i=0 (init val)
  %119 = add i8 %117, -65       ; tmp2[i] - 65
  %120 = icmp ult i8 %119, 26   ; %119 in [0, 26)
  br i1 %120, label %126, label %111

121:            ; memcmp, finally                 ; preds = %111, %108
  %122 = load i64, ptr %14, align 8, !tbaa !12    ; str1.len
  %123 = call i32 @bcmp(ptr nonnull %28, ptr nonnull %31, i64 %122)
  %124 = icmp eq i32 %123, 0    ; 0 for SUCCESS
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
  ; (%0 : str), (%1 : char), (%2 : sensitivity), (%3 : *count)
  %5 = icmp eq ptr %0, null       ; !str
  br i1 %5, label %47, label %6

6:                                                ; preds = %4
  %7 = icmp eq i32 %2, 0    ; sensitivity == 0
  %8 = load i8, ptr %0, align 1, !tbaa !13    ; str[0]
  %9 = icmp eq i8 %8, 0     ; str[0] =='\0'
  br i1 %7, label %16, label %10    ; decision on sensitivity

10:          ; if sensitivity!=0                  ; preds = %6
  br i1 %9, label %43, label %11    ; if the str is empty (str[0] == '\0'), branch to %43 where *count=occ=0, otherwise, go with the flow

11:         ; char2lcase inlined                  ; preds = %10
  %12 = add i8 %1, -65          ; ascii_dec(char) - 65
  %13 = icmp ult i8 %12, 26     ; %12 in [0, 26)
  %14 = or disjoint i8 %1, 32   ; Turn the 6th bit (mag:32) ON
  %15 = select i1 %13, i8 %14, i8 %1    ; choose the correct value of character after transformation
  br label %17

16:           ; if sensitivity==0                 ; preds = %6
  br i1 %9, label %43, label %32    ; if the str is empty (str[0] == '\0'), branch to %43 where *count=occ=0, otherwise, go with the flow

17:         ; sensitive check loop                ; preds = %11, %17
  %18 = phi i64 [ 0, %11 ], [ %28, %17 ]    ; i=0 (init val)
  %19 = phi i8 [ %8, %11 ], [ %30, %17 ]    ; c=str[0](init val)
  %20 = phi i32 [ 0, %11 ], [ %27, %17 ]    ; occ=0 (init val)
  %21 = add i8 %19, -65       ; c-65
  %22 = icmp ult i8 %21, 26   ; %21 in [0, 26)
  %23 = or disjoint i8 %19, 32    ; Turn the 6th bit (mag: 32) ON
  %24 = select i1 %22, i8 %23, i8 %19   ; choose the correct value of character after transformation
  %25 = icmp eq i8 %24, %15   ; char2lcase(str[.]) == char2lcase(char)
  %26 = zext i1 %25 to i32    ; zero extend %25 to 32-bit
  %27 = add nuw nsw i32 %20, %26  ; occ += %26 (or occ++) ; Clever. Since occ++ requires a decision, clang avoids it by adding the result of the decision itself.
  %28 = add nuw nsw i64 %18, 1    ; i++
  %29 = getelementptr inbounds i8, ptr %0, i64 %28    ; &str[%28] or &str[i]
  %30 = load i8, ptr %29, align 1, !tbaa !13    ; str[i]
  %31 = icmp eq i8 %30, 0   ; str[i] == '\0'
  br i1 %31, label %43, label %17, !llvm.loop !23

32:        ; insensitive check loop               ; preds = %16, %32
  %33 = phi i64 [ %39, %32 ], [ 0, %16 ]    ; i=0 (init val)
  %34 = phi i8 [ %41, %32 ], [ %8, %16 ]    ; str[0] (init val)
  %35 = phi i32 [ %38, %32 ], [ 0, %16 ]    ; occ=0 (init val)
  %36 = icmp eq i8 %34, %1    ; str[0] = char
  %37 = zext i1 %36 to i32    ; zero-extend %36 to 32-bit
  %38 = add nuw nsw i32 %35, %37    ; occ += %36 (or occ++)
  %39 = add nuw nsw i64 %33, 1    ; i++
  %40 = getelementptr inbounds i8, ptr %0, i64 %39    ; &str[%39] or &str[i]
  %41 = load i8, ptr %40, align 1, !tbaa !13    ; str[i]
  %42 = icmp eq i8 %41, 0       ; str[i] == '\0'
  br i1 %42, label %43, label %32, !llvm.loop !24

43:                                               ; preds = %17, %32, %10, %16
  %44 = phi i32 [ 0, %16 ], [ 0, %10 ], [ %38, %32 ], [ %27, %17 ]    ; occ
  %45 = icmp eq i32 %44, 0        ; !occ
  br i1 %45, label %47, label %46

46:                                               ; preds = %43
  store i32 %44, ptr %3, align 4, !tbaa !25     ; *count=occ
  br label %47

47:                                               ; preds = %46, %43, %4
  %48 = phi i32 [ -6, %4 ], [ 0, %46 ], [ 17, %43 ]
  ret i32 %48
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(write, argmem: readwrite, inaccessiblemem: none) uwtable
define dso_local range(i32 -4, 1) i32 @clearStr(ptr noundef %0) local_unnamed_addr #14 {
  %2 = icmp eq ptr %0, null     ; !str
  br i1 %2, label %8, label %3

3:                                                ; preds = %1
  %4 = load ptr, ptr %0, align 8, !tbaa !11   ; str.data
  %5 = icmp eq ptr %4, null     ; !str.data
  br i1 %5, label %8, label %6

6:                                                ; preds = %3
  %7 = getelementptr inbounds i8, ptr %0, i64 8   ; &str.len
  store i64 0, ptr %7, align 8, !tbaa !12   ; str.len = 0
  store i8 0, ptr %4, align 1, !tbaa !13    ; str.data[0] = '\0'
  br label %8

8:                                                ; preds = %6, %1, %3
  %9 = phi i32 [ -4, %3 ], [ -4, %1 ], [ 0, %6 ]
  ret i32 %9
}

; Function Attrs: mustprogress nounwind willreturn uwtable
define dso_local range(i32 -4, 1) i32 @freeStr(ptr noundef %0) local_unnamed_addr #15 {
  %2 = icmp eq ptr %0, null     ; !str
  br i1 %2, label %8, label %3

3:                                                ; preds = %1
  %4 = load ptr, ptr %0, align 8, !tbaa !11   ; str.data[0]
  %5 = icmp eq ptr %4, null       ; !str.data[0]
  br i1 %5, label %8, label %6

6:                                                ; preds = %3
  tail call void @free(ptr noundef %4) #24    ; free(str.data)
  %7 = getelementptr inbounds i8, ptr %0, i64 8   ; &str.len
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 8 dereferenceable(16) %7, i8 0, i64 16, i1 false)    ; str.len=0
  br label %8

8:                                                ; preds = %1, %3, %6
  %9 = phi i32 [ 0, %6 ], [ -4, %3 ], [ -4, %1 ]
  ret i32 %9
}

; Function Attrs: mustprogress nounwind willreturn allockind("free") memory(argmem: readwrite, inaccessiblemem: readwrite)
declare void @free(ptr allocptr nocapture noundef) local_unnamed_addr #16

; Function Attrs: nofree norecurse nosync nounwind uwtable
define dso_local noundef i32 @kmp_search(ptr noundef readonly %0, ptr noundef readonly %1, ptr nocapture noundef %2) local_unnamed_addr #17 {
  %4 = icmp ne ptr %0, null   ; !str
  %5 = icmp ne ptr %1, null   ; !pat
  %6 = and i1 %4, %5
  br i1 %6, label %7, label %115

7:                                                ; preds = %3
  %8 = load i8, ptr %0, align 1, !tbaa !13    ; str[0]
  %9 = icmp eq i8 %8, 0   ; str[0] != '\0'
  br i1 %9, label %17, label %10

10:            ; lenstr(str) inlined              ; preds = %7, %10
  %11 = phi i32 [ %14, %10 ], [ 0, %7 ]     ; len=0 (init val)
  %12 = phi ptr [ %13, %10 ], [ %0, %7 ]    ; ptr=str[0] (init val)
  %13 = getelementptr inbounds i8, ptr %12, i64 1   ; &str[..+1]
  %14 = add nuw nsw i32 %11, 1    ; len++
  %15 = load i8, ptr %13, align 1, !tbaa !13    ; str[..+1]
  %16 = icmp eq i8 %15, 0   ; str[..+1] == '\0'
  br i1 %16, label %17, label %10, !llvm.loop !17

17:                                               ; preds = %10, %7
  %18 = phi i32 [ 0, %7 ], [ %14, %10 ]
  %19 = load i8, ptr %1, align 1, !tbaa !13    ; pat[0]
  %20 = icmp eq i8 %19, 0    ; pat[0] != '\0'
  br i1 %20, label %28, label %21

21:            ; lenstr(pat) inlined              ; preds = %17, %21
  %22 = phi i32 [ %25, %21 ], [ 0, %17 ]     ; len=0 (init val)
  %23 = phi ptr [ %24, %21 ], [ %1, %17 ]    ; ptr=pat[0] (init val)
  %24 = getelementptr inbounds i8, ptr %23, i64 1   ; &pat[..+1]
  %25 = add nuw nsw i32 %22, 1    ; len++
  %26 = load i8, ptr %24, align 1, !tbaa !13  ; pat[..+1]
  %27 = icmp eq i8 %26, 0   ; pat[..+1] == '\0'
  br i1 %27, label %28, label %21, !llvm.loop !17

28:                                               ; preds = %21, %17
  %29 = phi i32 [ 0, %17 ], [ %25, %21 ]
  %30 = icmp sgt i32 %29, %18
  br i1 %30, label %115, label %31

31:                                               ; preds = %28
  %32 = zext i32 %29 to i64   ; pat_len or plen is zero extended to i64 so that `size_t lps[plen]` is possible
  %33 = tail call ptr @llvm.stacksave.p0()
  %34 = alloca i64, i64 %32, align 16       ; size_t lps[plen]
  %35 = sext i32 %29 to i64   ; sign-extend plen to i64
  %36 = icmp eq i32 %29, 0    ; plen==0
  br i1 %36, label %64, label %37

37:           ; kmp_build_lps inlined             ; preds = %31
  store i64 0, ptr %34, align 16, !tbaa !27    ; lps[0]=0
  %38 = getelementptr i8, ptr %34, i64 -8      ; &lps[0] - 8
  %39 = icmp eq i32 %29, 1        ; plen==1
  br i1 %39, label %64, label %40

40:         ; if (pat[i] == pat[len])             ; preds = %37, %60
  %41 = phi i64 [ %62, %60 ], [ 1, %37 ]    ; i=1 (init val)
  %42 = phi i64 [ %61, %60 ], [ 0, %37 ]    ; len=0 (init val)
  %43 = getelementptr inbounds i8, ptr %1, i64 %41    ; &pat[i]
  %44 = load i8, ptr %43, align 1, !tbaa !13    ; pat[i]
  %45 = getelementptr inbounds i8, ptr %1, i64 %42    ; &pat[len]
  %46 = load i8, ptr %45, align 1, !tbaa !13    ; pat[len]
  %47 = icmp eq i8 %44, %46       ; pat[i] == pat[len]
  br i1 %47, label %48, label %52

48:         ; body (on true)                      ; preds = %40
  %49 = add i64 %42, 1    ; len++
  %50 = getelementptr inbounds i64, ptr %34, i64 %41    ; &lps[i]
  store i64 %49, ptr %50, align 8, !tbaa !27    ; lps[i] = latest_val_of_len
  %51 = add nuw i64 %41, 1    ; i++
  br label %60

52:         ; else if (len != 0)                  ; preds = %40
  %53 = icmp eq i64 %42, 0        ; len == 0
  br i1 %53, label %57, label %54

54:         ; body (on false)                     ; preds = %52
  %55 = getelementptr i64, ptr %38, i64 %42     ; &lps[0]-8
  %56 = load i64, ptr %55, align 8, !tbaa !27   ; *(&lps[0]-8 + 8*len)  (same as lps[len-1])
  br label %60

57:         ; else (else if is true)              ; preds = %52
  %58 = getelementptr inbounds i64, ptr %34, i64 %41    ; &lps[i]
  store i64 0, ptr %58, align 8, !tbaa !27    ; lps[i] = 0
  %59 = add nuw i64 %41, 1    ; i++
  br label %60

60:                                               ; preds = %57, %54, %48
  %61 = phi i64 [ %49, %48 ], [ %56, %54 ], [ 0, %57 ]      ; len
  %62 = phi i64 [ %51, %48 ], [ %41, %54 ], [ %59, %57 ]    ; i
  %63 = icmp ult i64 %62, %35       ; i < sign_extended(plen)
  br i1 %63, label %40, label %64, !llvm.loop !28

64:                                               ; preds = %60, %31, %37
  %65 = phi i32 [ -6, %31 ], [ 0, %37 ], [ 0, %60 ]    ; (-6 when plen==0)
  br i1 %36, label %113, label %66

; kmp_build_lps completed
  ; branch to %113 if INVALID_BUFF (-6) was returned
  ; branch to %66, where kmp_search continued, if kmp_build_lps was a success

66:                                               ; preds = %64
  %67 = sext i32 %18 to i64     ; (slen sign-extended to i64)
  %68 = getelementptr i8, ptr %34, i64 -8      ; &lps[0]-8    (why not reuse %38?)
  %69 = icmp eq i32 %18, 0          ; slen==0
  br i1 %69, label %105, label %70

70:                                               ; preds = %66
  %71 = getelementptr inbounds i8, ptr %2, i64 8    ; &kmp_obj->indices
  %72 = getelementptr i64, ptr %34, i64 %35    ; &lps[plen]
  %73 = getelementptr i8, ptr %72, i64 -8      ; &lps[plen]-8    (&lps[plen-1] ?)
  br label %74

74:                                               ; preds = %70, %100
  %75 = phi i64 [ 0, %70 ], [ %103, %100 ]    ; count
  %76 = phi i64 [ 0, %70 ], [ %102, %100 ]    ; k
  %77 = phi i64 [ 0, %70 ], [ %101, %100 ]    ; i (main str iter)
  %78 = getelementptr inbounds i8, ptr %0, i64 %77    ; &str[i]
  %79 = load i8, ptr %78, align 1, !tbaa !13    ; str[i]
  %80 = getelementptr inbounds i8, ptr %1, i64 %76    ; &pat[k]
  %81 = load i8, ptr %80, align 1, !tbaa !13    ; pat[k]
  %82 = icmp eq i8 %79, %81       ; str[i] == pat[k]
  br i1 %82, label %83, label %93

83:         ; characters matched                  ; preds = %74
  %84 = add nuw i64 %77, 1    ; i++
  %85 = add i64 %76, 1        ; k++
  %86 = icmp eq i64 %85, %35  ; i == plen    (if number of characters matched so far eq to the number of characters in the pattern, we are done for now until the next difference comes or the str ends)
  br i1 %86, label %87, label %100

87:       ; all chars have matched so far         ; preds = %83
  %88 = sub i64 %77, %76    ; i-k
  %89 = load ptr, ptr %71, align 8, !tbaa !29   ; kmp_obj->indices
  %90 = getelementptr inbounds i64, ptr %89, i64 %75    ; kmp_obj->indices[count]
  store i64 %88, ptr %90, align 8, !tbaa !27      ; kmp_obj->indices[count] = i-k    (store the idx of the match found)
  %91 = add i64 %75, 1    ; count++
  %92 = load i64, ptr %73, align 8, !tbaa !27     ; lps[plen-1]
  br label %100

93:             ; str[i] != pat[k]                ; preds = %74
  %94 = icmp eq i64 %76, 0        ; k==0
  br i1 %94, label %98, label %95

95:                                               ; preds = %93
  %96 = getelementptr i64, ptr %68, i64 %76     ; (&lps[0]-8) + k
  %97 = load i64, ptr %96, align 8, !tbaa !27   ; *((&lps[0]-8) + k)    lps[k-1]
  br label %100

98:                                               ; preds = %93
  %99 = add nuw i64 %77, 1    ; i++
  br label %100

100:                                              ; preds = %95, %98, %83, %87
  %101 = phi i64 [ %84, %87 ], [ %84, %83 ], [ %77, %95 ], [ %99, %98 ]    ; i
  %102 = phi i64 [ %92, %87 ], [ %85, %83 ], [ %97, %95 ], [ 0, %98 ]      ; k
  %103 = phi i64 [ %91, %87 ], [ %75, %83 ], [ %75, %95 ], [ %75, %98 ]    ; count
  %104 = icmp ult i64 %101, %67
  br i1 %104, label %74, label %105, !llvm.loop !31

105:                                              ; preds = %100, %66
  %106 = phi i64 [ 0, %66 ], [ %103, %100 ]    ; count
  %107 = icmp eq i64 %106, 0          ; count==0
  br i1 %107, label %108, label %110

108:                                              ; preds = %105
  %109 = getelementptr inbounds i8, ptr %2, i64 8    ; &kmp_obj->indices
  store ptr null, ptr %109, align 8, !tbaa !29       ; kmp_obj->indices = NULL (if count is 0)
  br label %110

110:                                              ; preds = %105, %108
  %111 = phi i64 [ 0, %108 ], [ %106, %105 ]    ; count
  %112 = phi i32 [ -16, %108 ], [ 0, %105 ]     ; SUBSTR_NOT_FOUND
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
define dso_local range(i32 -16, 1) i32 @isin(ptr noundef readonly %0) local_unnamed_addr #18 {
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
define dso_local range(i32 -16, 1) i32 @firstOccurrence(ptr noundef readonly %0, ptr nocapture noundef writeonly %1) local_unnamed_addr #19 {
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
