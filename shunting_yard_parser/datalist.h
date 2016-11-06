#ifndef __DATALIST_H__
#define __DATALIST_H__

#define LIST_BYTES_SZ 64

typedef int lst_i;
typedef float lst_f;
typedef char lst_b[LIST_BYTES_SZ];

typedef struct _ListItem* pListItem;
typedef struct _ListItem {
  int value;
  union {
    lst_i d_int;
    lst_f d_real;
    lst_b d_raw;
  };
  pListItem prev;
  pListItem next;
} ListItem;

typedef struct {
  int length;
  pListItem first;
  pListItem last;
} DataList, *pDataList;

extern pDataList list_new();
extern void list_free(pDataList listp);
extern void list_clear(pDataList listp);
extern pListItem list_pushi(pDataList listp, int value, lst_i pushi);
extern pListItem list_pushr(pDataList listp, int value, lst_f pushr);
extern pListItem list_pushb(pDataList listp, int value, lst_b pushb);
extern ListItem list_pop(pDataList listp);
extern ListItem list_prior(pDataList listp);
extern pListItem list_findi(pDataList listp, lst_i findi, int* index);
extern pListItem list_findf(pDataList listp, lst_f findf, int* index);
extern pListItem list_findb(pDataList listp, lst_b findb, int* index);

#endif // __DATALIST_H__
