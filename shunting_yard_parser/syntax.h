#ifndef __SYNTAX_H__
#define __SYNTAX_H__

#include "datalist.h"

#define LX_ADD '+'
#define LX_SUBMINUS '-'
#define LX_MULTIPLY '*'
#define LX_DIVIDE '/'
#define LX_POWER '^'
#define LX_LEFTBRACE '('
#define LX_RIGHTBRACE ')'

typedef enum {
  TK_NUMBER,
  TK_VARIABLE,
  TK_FUNC_SIN,
  TK_FUNC_COS,
  TK_FUNC_EXP,
  TK_FUNC_LOG,
  TK_FUNC_SQRT,
  TK_LEFTBRACE,
  TK_RIGHTBRACE,
  TK_OPERATION
} TokenType;

typedef enum {      //VALUE; UNION DATA
  PR_DONE,          //nothing; nothing
  PR_NEED_BRACE,    //position; opened braces count
  PR_LOST_BRACE,    //position; nothing
  PR_BAD_CHAR,      //position; char code
  PR_BAD_TOKEN,     //position; expected token
  PR_BAD_STATE,     //nothing; state
} ParseResult;

extern ParseResult parse_expr(char* expr, pDataList lst_tokens, pDataList lst_vars);
extern lst_f eval_func(TokenType func, lst_f x);

#endif // __SYNTAX_H__
