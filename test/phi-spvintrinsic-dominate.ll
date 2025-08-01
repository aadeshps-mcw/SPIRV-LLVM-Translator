; RUN: llvm-as < %s -o %t.bc
; RUN: llvm-spirv %t.bc -o %t.spv
; RUN: spirv-val %t.spv
; RUN: llvm-spirv -to-text %t.spv -o - | FileCheck %s

target datalayout = "e-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-n8:16:32:64"
target triple = "spir64-unknown-unknown"

; CHECK: Function
; CHECK: Branch
; CHECK: Label
; CHECK: Phi
; CHECK: Phi
; CHECK: Phi

define spir_kernel void @foo(ptr addrspace(1) %_arg1) {
entry:
  br label %l1

l1:
  %sw = phi <4 x double> [ %vec, %l2 ], [ <double 0.0, double 0.0, double 0.0, double poison>, %entry ]
  %in = phi <3 x double> [ %ins, %l2 ], [ zeroinitializer, %entry ]
  %r1 = phi i32 [ %r2, %l2 ], [ 0, %entry ]
  %c1 = icmp ult i32 %r1, 3
  br i1 %c1, label %l2, label %exit

l2:
  %r3 = zext nneg i32 %r1 to i64
  %r4 = getelementptr inbounds double, ptr addrspace(1) %_arg1, i64 %r3
  %r5 = load double, ptr addrspace(1) %r4, align 8
  %ins = insertelement <3 x double> %in, double %r5, i32 %r1
  %exp = shufflevector <3 x double> %ins, <3 x double> poison, <4 x i32> <i32 0, i32 1, i32 2, i32 poison>
  %vec = shufflevector <4 x double> %exp, <4 x double> %sw, <4 x i32> <i32 0, i32 1, i32 2, i32 7>
  %r2 = add nuw nsw i32 %r1, 1
  br label %l1

exit:
  ret void
}
