#include "lista.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

string_proc_list* string_proc_list_create_asm() {
// calculamos sizeof(string_proc_list)
// string_proc_node_t* mide 8 bytes,
// por lo tanto, string_proc_list
// mide 16 bytes

string_proc_list* res = malloc(16);
	res->first = NULL;
	res->last = NULL;
	return res;
}

void string_proc_list_add_node_asm(string_proc_list* list, uint8_t type,
char* hash) {
	string_proc_node* nuevo_nodo = string_proc_node_create_asm(type, hash);
	string_proc_node* nodo_actual = list->last;
	list->last=nuevo_nodo;
	
	if (nodo_actual == NULL) { 
		list->first=nuevo_nodo; 
		return ;
	};
	
	nodo_actual->next = nuevo_nodo;
	nuevo_nodo->previous = nodo_actual;
}
