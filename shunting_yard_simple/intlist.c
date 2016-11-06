#include <malloc.h>
#include "intlist.h"

#define new(type) (type*)( malloc( sizeof(type) ) )

pIntList list_new() {
  pIntList list = new(IntList);
  list->length = 0;
  list->first = NULL;
  list->last = NULL;
  return list;
}

void list_free(pIntList listp) {
  if (listp == NULL) {return;}
  while (listp->length > 0) {list_pop(listp);}
  free(listp);
}

pListItem list_push(pIntList listp, int push_val) {
  if (listp == NULL) {return NULL;}
  pListItem item = new(ListItem);
  item->value = push_val;

  item->prev = listp->last;
  item->next = NULL;
  if (listp->last != NULL) {listp->last->next = item;} else {listp->first = item;}
  listp->last = item;

  listp->length++;
  return item;
}

int list_pop(pIntList listp) {
  pListItem item = listp->last;
  int result = item->value;
  listp->last = item->prev;
  free(item);
  if (listp->last != NULL) {listp->last->next = NULL;} else {listp->first = NULL;}
  listp->length--;
  return result;
}

int list_prior(pIntList listp) {
  pListItem item = listp->first;
  int result = item->value;
  listp->first = item->next;
  free(item);
  if (listp->first != NULL) {listp->first->prev = NULL;} else {listp->last = NULL;}
  listp->length--;
  return result;
}
