#ifndef __INTLIST_H__
#define __INTLIST_H__

typedef struct _ListItem* pListItem;
typedef struct _ListItem {
  int value;
  pListItem prev;
  pListItem next;
} ListItem;

typedef struct {
  int length;
  pListItem first;
  pListItem last;
} IntList, *pIntList;

pIntList list_new();
void list_free(pIntList listp);
pListItem list_push(pIntList listp, int push_val);
int list_pop(pIntList listp);
int list_prior(pIntList listp);

#endif // __INTLIST_H__
