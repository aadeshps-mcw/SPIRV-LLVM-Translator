; RUN: llvm-as < %s -o %t.bc
; RUN: llvm-spirv %t.bc -o %t.spv
; RUN: spirv-val %t.spv
; RUN: llvm-spirv -to-text %t.spv -o - | FileCheck %s

target datalayout = "e-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-n8:16:32:64"
target triple = "spir64-unknown-unknown"

; CHECK-DAG: Name [[#GV:]] "v"
; CHECK-DAG: Name [[#FunBar:]] "bar"
; CHECK-DAG: Decorate [[#GV]] LinkageAttributes "v" Export
; CHECK-DAG: Decorate [[#GV]] Constant
; CHECK-DAG: Decorate [[#Idx:]] UserSemantic "SemanticValue"
; CHECK: Function 6 15 0 14
; CHECK: InBoundsPtrAccessChain 3 [[#Idx]]

@v = addrspace(1) global i32 0, !spirv.Decorations !0

define spir_kernel void @foo() {
entry:
  %pv = load ptr addrspace(1), ptr addrspace(1) @v
  store i32 3, ptr addrspace(1) %pv
  ret void
}

define spir_kernel void @bar(ptr addrspace(1) %arg) {
entry:
  %idx = getelementptr inbounds i32, ptr addrspace(1) %arg, i64 1, !spirv.Decorations !3
  ret void
}

!0 = !{!1, !2}
!1 = !{i32 22}                     ; 22 is Constant decoration
!2 = !{i32 41, !"v", i32 0}        ; 41 is LinkageAttributes decoration with 2 extra operands
!3 = !{!4}
!4 = !{i32 5635, !"SemanticValue"} ; 5635 is UserSemantic decoration
