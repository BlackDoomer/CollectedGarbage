#include <stdlib.h>
#include <memory.h>
#include "datalist.h"

#define new(type) (type*)( malloc( sizeof(type) ) )

pDataList list_new() {
  pDataList list = new(DataList);
  list->length = 0;
  list->first = NULL;
  list->last = NULL;
  return list;
}

void list_free(pDataList listp) {
  list_clear(listp);
  free(listp);
}

void list_clear(pDataList listp) {
  if (listp == NULL) {return;}
  while (listp->length > 0) {list_pop(listp);}
}

static pListItem list_push(pDataList listp, int value) {
  if (listp == NULL) {return NULL;}
  pListItem item = new(ListItem);
  item->value = value;

  item->prev = listp->last;
  item->next = NULL;
  if (listp->last != NULL) {listp->last->next = item;} else {listp->first = item;}
  listp->last = item;

  listp->length++;
  return item;
}

pListItem list_pushi(pDataList listp, int value, lst_i pushi) {
  pListItem result = list_push(listp, value);
  if (result != NULL) {result->d_int = pushi;}
  return result;
}

pListItem list_pushr(pDataList listp, int value, lst_f pushr) {
  pListItem result = list_push(listp, value);
  if (result != NULL) {result->d_real = pushr;}
  return result;
}

pListItem list_pushb(pDataList listp, int value, lst_b pushb) {
  pListItem result = list_push(listp, value);
  if (result != NULL) {memcpy(result->d_raw, pushb, LIST_BYTES_SZ);}
  return result;
}

ListItem list_pop(pDataList listp) {
  pListItem item = listp->last;
  ListItem result = *item;
  listp->last = item->prev;
  free(item);
  if (listp->last != NULL) {listp->last->next = NULL;} else {listp->first = NULL;}
  listp->length--;
  return result;
}

ListItem list_prior(pDataList listp) {
  pListItem item = listp->first;
  ListItem result = *item;
  listp->first = item->next;
  free(item);
  if (listp->first != NULL) {listp->first->prev = NULL;} else {listp->last = NULL;}
  listp->length--;
  return result;
}

pListItem list_findi(pDataList listp, lst_i findi, int* index) {
  pListItem item;
  for(item = listp->first; item != NULL; item = item->next) {
    if (item->d_int == findi) {break;}
    if (index != NULL) {(*index)++;}
  }
  return item;
}

pListItem list_findf(pDataList listp, lst_f findf, int* index) {
  pListItem item;
  for(item = listp->first; item != NULL; item = item->next) {
    if (item->d_real == findf) {break;}
    if (index != NULL) {(*index)++;}
  }
  return item;
}

pListItem list_findb(pDataList listp, lst_b findb, int* index) {
  pListItem item;
  for(item = listp->first; item != NULL; item = item->next) {
    if (strcmp(item->d_raw, findb) == 0) {break;}
    if (index != NULL) {(*index)++;}
  }
  return item;
}


