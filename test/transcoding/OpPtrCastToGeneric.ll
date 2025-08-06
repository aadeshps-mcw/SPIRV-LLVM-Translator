; RUN: llvm-as < %s -o %t.bc
; RUN: llvm-spirv %t.bc -o %t.spv
; RUN: spirv-val %t.spv
; RUN: llvm-spirv -to-text %t.spv -o - | FileCheck %s

target datalayout = "e-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-n8:16:32:64"
target triple = "spir64-unknown-unknown"

; CHECK: TypeInt [[#]] 8 0
; CHECK: TypeVoid [[#]]
; CHECK: TypePointer [[#Param:]] [[#]] [[#]]
; CHECK: TypePointer [[#Param1:]] [[#]] [[#]]
; CHECK: TypePointer [[#Param2:]] [[#]] [[#]]
; CHECK: Function [[#]] [[#]] 0 [[#]]
; CHECK: FunctionParameter [[#Param]] [[#ArgParam1:]]
; CHECK: PtrCastToGeneric [[#Param1]] [[#P1:]] [[#ArgParam1]]
; CHECK: GenericCastToPtr [[#Param2]] [[#]] [[#P1]]
; CHECK: FunctionEnd

define spir_kernel void @bar(ptr addrspace(1) %arg) {
entry:
  %p1 = addrspacecast ptr addrspace(1) %arg to ptr addrspace(4)
  %p2 = addrspacecast ptr addrspace(4) %p1 to ptr addrspace(3)
  ret void
}
