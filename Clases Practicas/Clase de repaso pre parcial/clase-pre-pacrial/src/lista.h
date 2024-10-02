#include <stddef.h>
#include <stdint.h>

/** Lista **/
typedef struct string_proc_list_t {
	struct string_proc_node_t* first;
	struct string_proc_node_t* last;
} string_proc_list;
/** Nodo **/
typedef struct string_proc_node_t {
	struct string_proc_node_t* next;
	struct string_proc_node_t* previous;
	uint8_t type;
	char* hash;
} string_proc_node;
