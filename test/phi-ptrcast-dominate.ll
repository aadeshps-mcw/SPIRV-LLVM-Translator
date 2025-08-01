; RUN: llvm-as < %s -o %t.bc
; RUN: llvm-spirv %t.bc -o %t.spv
; RUN: spirv-val %t.spv
; RUN: llvm-spirv -to-text %t.spv -o - | FileCheck %s

target datalayout = "e-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-n8:16:32:64"
target triple = "spir64-unknown-unknown"

; CHECK-DAG: Name [[#STR1:]] ".str.1"
; CHECK-DAG: Name [[#STR2:]] ".str.2"
; CHECK-DAG: Name [[#CASE1:]] "case1"
; CHECK-DAG: Name [[#CASE2:]] "case2"
; CHECK-DAG: Name [[#CASE3:]] "case3"
; CHECK-DAG: Name [[#L_ENTRY:]] "entry"
; CHECK-DAG: Name [[#L_L1:]] "l1"
; CHECK-DAG: Name [[#L_L2:]] "l2"
; CHECK-DAG: Name [[#L_L3:]] "l3"
; CHECK-DAG: Name [[#L_EXIT:]] "exit"
; CHECK-DAG: Decorate [[#STR1]] Constant
; CHECK-DAG: Decorate [[#STR1]] Alignment 1
; CHECK-DAG: Decorate [[#STR2]] Constant
; CHECK-DAG: Decorate [[#STR2]] Alignment 1
; CHECK-DAG: Decorate [[#CASE1]] LinkageAttributes "case1" Export
; CHECK-DAG: Decorate [[#CASE2]] LinkageAttributes "case2" Export
; CHECK-DAG: Decorate [[#CASE3]] LinkageAttributes "case3" Export

; CHECK: Function [[#VOID_TYPE:]] [[#CASE1]]
; CHECK: FunctionParameter [[#]] [[#]]
; CHECK: Label [[#L_ENTRY]]
; CHECK: BranchConditional [[#]] [[#L_L1:]] [[#L_L2]]

; CHECK: Label [[#L_L1]]
; CHECK: Phi [[#PTR_TYPE:]] [[#]] [[#STR1]] [[#L_ENTRY]] [[#PTRCAST1:]] [[#L_L2]] [[#PTRCAST2:]] [[#L_L3]]
; CHECK: Branch [[#L_EXIT]]

; CHECK: Label [[#L_L2]]
; CHECK: Bitcast [[#PTR_TYPE]] [[#PTRCAST1]] [[#STR2]]
; CHECK: BranchConditional [[#]] [[#L_L1]] [[#L_L3]]

; CHECK: Label [[#L_L3]]
; CHECK: Bitcast [[#PTR_TYPE]] [[#PTRCAST2]] [[#STR2]]
; CHECK: BranchConditional [[#]] [[#L_L1]] [[#L_EXIT]]

; CHECK: Label [[#L_EXIT]]
; CHECK: Return

%struct1 = type { i64 }
%struct2 = type { i64, i64 }

@.str.1 = private unnamed_addr addrspace(1) constant [3 x i8] c"OK\00", align 1
@.str.2 = private unnamed_addr addrspace(1) constant [6 x i8] c"WRONG\00", align 1

define spir_func void @case1(i1 %b1, i1 %b2, i1 %b3) {
entry:
  br i1 %b1, label %l1, label %l2

l1:
  %str = phi ptr addrspace(1) [ @.str.1, %entry ], [ @.str.2, %l2 ], [ @.str.2, %l3 ]
  br label %exit
l2:
  br i1 %b2, label %l1, label %l3

l3:
  br i1 %b3, label %l1, label %exit
exit:
  ret void
}

define spir_func void @case2(i1 %b1, i1 %b2, i1 %b3, ptr addrspace(1) byval(%struct1) %str1, ptr addrspace(1) byval(%struct2) %str2) {
entry:
  br i1 %b1, label %l1, label %l2

l1:
  %str = phi ptr addrspace(1) [ %str1, %entry ], [ %str2, %l2 ], [ %str2, %l3 ]
  br label %exit
l2:
  br i1 %b2, label %l1, label %l3

l3:
  br i1 %b3, label %l1, label %exit

exit:
  ret void
}

define spir_func void @case3(i1 %b1, i1 %b2, i1 %b3, ptr addrspace(1) byval(%struct1) %_arg_str1, ptr addrspace(1) byval(%struct2) %_arg_str2) {

entry:
  br i1 %b1, label %l1, label %l2

l1:
  %str = phi ptr addrspace(1) [ %_arg_str1, %entry ], [ %str2, %l2 ], [ %str3, %l3 ]
  br label %exit

l2:
  %str2 = getelementptr inbounds %struct2, ptr addrspace(1) %_arg_str2, i32 1
  br i1 %b2, label %l1, label %l3

l3:
  %str3 = getelementptr inbounds %struct2, ptr addrspace(1) %_arg_str2, i32 2
  br i1 %b3, label %l1, label %exit

exit:
  ret void
}
