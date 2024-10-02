%define OFFSET_LIST_FIRST 0
%define OFFSET_LIST_LAST 8
%define STRUCT_SIZE_LIST 16
%define OFFSET_NODE_NEXT 0
%define OFFSET_NODE_PREVIOUS 8
%define OFFSET_NODE_TYPE 16
%define OFFSET_NODE_HASH 24
%define STRUCT_SIZE_NODE 32

global string_proc_list_create_asm
global string_proc_node_create_asm
global string_proc_list_add_node_asm
global string_proc_list_apply_asm

string_proc_list_create_asm:
push rbp
mov rbp, rsp ; prologo + alinear
mov rdi, STRUCT_SIZE_LIST
call malloc
mov qword [rax + OFFSET_LIST_FIRST], 0
mov qword [rax + OFFSET_LIST_LAST], 0
pop rbp ; epilogo
ret

;dil=type, rsi=hash
string_proc_node_create_asm:
push rbp
mov rbp, rsp ; prologo + alinear
push rdi
push rsi
mov rdi, STRUCT_SIZE_NODE
call malloc
pop rsi
pop rdi
mov qword [rax + OFFSET_NODE_NEXT], 0
mov qword [rax + OFFSET_NODE_PREVIOUS], 0
mov [rax + OFFSET_NODE_TYPE], dil
mov [rax + OFFSET_NODE_HASH], rsi
pop rbp ; epilogo
ret


rdi=list, rsi=type, rdx=hash
string_proc_list_add_node_asm:
push rbp
mov rbp, rsp
push rdi
sub rsp, 8 ; alineado
mov rdi, rsi ; param type
mov rsi, rdx ; param hash
call string_proc_node_create_asm
add rsp, 8
pop rdi
mov rsi, [rdi+OFFSET_LIST_LAST]; nodo_actual = list->last
mov [rdi+OFFSET_LIST_LAST], rax; list->last=nuevo_nodo
cmp rsi, 0; nodo_actual != null
jne .insertarNuevo
mov [rdi+OFFSET_LIST_FIRST], rax; list->first=nuevo_nodo
jmp .fin

.insertarNuevo:
mov [rsi+OFFSET_NODE_NEXT], rax
mov [rsi+OFFSET_NODE_PREVIOUS], rsi
.fin:
pop rbp
ret

rdi=list, rsi=type, rdx=hash
string_proc_list_apply_asm:
; for item in list
; if item.type == type then append(res,
item.hash)
; vamos a tener que usar funciones de libc
push rbp
mov rbp, rsp
sub rsp, 16
push r12
push r13
push r14
push r15

mov r15, rdi ;list
mov r14, rsi ;type
mov r13, rdx ;hash
mov rdi, 1

call malloc ; res = “”
mov byte [rax], 0
mov [rbp - 8], rax ; guardo tmp=rax
mov rdi, rax ; guardo res = “”
mov rsi, rdx ; preparo con hash

call str_concat
mov [rbp - 16], rax ; guardo res=hash (copia)
mov rdi, [rbp - 8] ; borro reserva tmp
call free

;[rbp-16]=res, r13=hash, r14=type, r15=list
mov r12, [r15] ;r12 = nodo_actual
.while:
    cmp r12, 0
    je .fin ; if list->first == null then ret hash
    cmp [r12+OFFSET_NODE_TYPE], r14b
    ; nodo_actual->type == type
    je .mismoTipo
    .next:
    mov r12, [r12] ; r12 = nodo_actual->next
    jmp .while


.mismoTipo:
mov rdi, [rbp-16]; rdi=base
mov rsi, [r12+OFFSET_NODE_HASH]
; rsi=nodo_actual->hash
call str_concat
; rax = concat(hash,nodo_actual->hash)
mov rdi, [rbp-16] ; tmp = old_hash
mov [rbp-16], rax ; [rbp-8]=new_concat_hash
call free ; free old_hash
jmp .next
.fin
mov rax, [rbp-16]
pop r15..r12
add rsp, 16
ret
