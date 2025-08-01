; RUN: llvm-as < %s -o %t.bc
; RUN: llvm-spirv %t.bc -o %t.spv
; RUN: spirv-val %t.spv
; RUN: llvm-spirv -to-text %t.spv -o - | FileCheck %s

target datalayout = "e-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-n8:16:32:64"
target triple = "spir64-unknown-unknown"

; CHECK-DAG: TypeBool [[#BoolTy:]]
; CHECK-DAG: TypePointer 7 7 [[#BoolTy]]
; CHECK-DAG: ConstantFalse [[#BoolTy]] [[#False:]]
; CHECK: Function
; CHECK: Variable 7 8 7
; CHECK: Store 8 [[#False]] 2 1

define spir_func void @foo() {
entry:
  %bvar = alloca i1, align 1
  store i1 false, ptr %bvar, align 1
  ret void
}
