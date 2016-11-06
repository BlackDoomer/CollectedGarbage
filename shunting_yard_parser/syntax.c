#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <ctype.h>
#include <math.h>
#include "syntax.h"

#define CHR_CR (char)0xD
#define CHR_LF (char)0xA

#define RAW_AS_REAL(x) (*((lst_f*)x))

typedef enum {
  PS_DEFAULT,     //need operation
  PS_NEED_VALUE,  //need number/variable
  PS_FUNC_START,  //need open brace
  PS_FUNC_ARG,    //need number/variable
  PS_FUNC_END     //need close brace
} ParseState;

// return value:
// <0 - got number, return its negated length
//  0 - got nothing
// >0 - got name, return its length (without '\0')
static int get_value(const char* expr, lst_b data) {
  //try to interpret next chars as a float
  char* newpos;
  RAW_AS_REAL(data) = strtod(expr, &newpos);
  if (newpos > expr) {return (int)(expr-newpos);}

  //if it isn't float, let's try to take a variable name
  int i;
  for(i = 0; i < LIST_BYTES_SZ-1; ++i) {
    if ( (isalnum(expr[i])) || (expr[i] == '_') ) {
      data[i] = expr[i];
    } else break;
  }
  data[i] = '\0';
  return i;
}

ParseResult parse_expr(char* expr, pDataList lst_tokens, pDataList lst_vars) {
  int brace_cnt = 0;
  char* startptr = expr;
  ParseState state = PS_NEED_VALUE;
  TokenType func_token = TK_OPERATION;

  while (expr[0] != '\0') {

    //skip whitespace and newlines
    if ( (isblank(expr[0])) || (expr[0] == CHR_CR) || (expr[0] == CHR_LF) ) {
      expr++;
      continue;
    }

    //ERROR: control (except newlines) or non-ASCII char
    if ( (iscntrl(expr[0])) || ((unsigned)expr[0] > 0x7F) ) {
      list_pushi(lst_tokens, (int)(expr-startptr), expr[0]);
      return PR_BAD_CHAR;
    }

    //try to interpret next chars as number or name
    lst_b value;
    int length = 0;
    if ( (state == PS_NEED_VALUE) || (state == PS_FUNC_ARG) ) {
      length = get_value(expr, value);
    }

    if (length < 0) { //we got number
      if (state == PS_FUNC_ARG) {
        //replace this number by function result
        RAW_AS_REAL(value) = eval_func(func_token, RAW_AS_REAL(value));
        state = PS_FUNC_END;
      } else {
        state = PS_DEFAULT;
      }
      list_pushb(lst_tokens, TK_NUMBER, value);
      length = -length;

    } else if (length > 0) { //we got name
      if (state == PS_FUNC_ARG) {
        state = PS_FUNC_END;
      } else {
        //check if it is a function name
        state = PS_FUNC_START;
        if (strcmp(value, "sin") == 0) {
          func_token = TK_FUNC_SIN;
        } else if (strcmp(value, "cos") == 0) {
          func_token = TK_FUNC_COS;
        } else if (strcmp(value, "exp") == 0) {
          func_token = TK_FUNC_EXP;
        } else if (strcmp(value, "log") == 0) {
          func_token = TK_FUNC_LOG;
        } else if (strcmp(value, "sqrt") == 0) {
          func_token = TK_FUNC_SQRT;
        } else {
          //if name is unknown, consider it as a variable name
          state = PS_DEFAULT;
          func_token = TK_VARIABLE;
        }
      }
      if ( (func_token == TK_VARIABLE) || (state == PS_FUNC_END) ) {
        list_pushb(lst_tokens, func_token, value);
        if (list_findb(lst_vars, value, NULL) == NULL) {
          list_pushb(lst_vars, length, value);
        }
      }
    }

    if (length > 0) {
      expr += length;
      continue;
    }

    //otherwise, try to interpret current char as operation
    bool wrong_char = false;
    switch (expr[0]) {

      case LX_ADD: case LX_SUBMINUS:
      case LX_MULTIPLY: case LX_DIVIDE: case LX_POWER:
        if (state == PS_DEFAULT) {
          list_pushi(lst_tokens, TK_OPERATION, expr[0]);
          state = PS_NEED_VALUE;
        } else {
          wrong_char = true;
        }
      break;

      case LX_LEFTBRACE:
        brace_cnt++;
        switch (state) {
          case PS_NEED_VALUE:
            list_pushi(lst_tokens, TK_LEFTBRACE, brace_cnt);
            break;
          case PS_FUNC_START:
            state = PS_FUNC_ARG;
            break;
          default:
            wrong_char = true;
        }
      break;

      case LX_RIGHTBRACE:
        if (brace_cnt == 0) { //ERROR: lost brace
          list_pushi(lst_tokens, (int)(expr-startptr), 0);
          return PR_LOST_BRACE;
        }
        brace_cnt--;
        switch (state) {
          case PS_DEFAULT:
            list_pushi(lst_tokens, TK_RIGHTBRACE, brace_cnt);
            break;
          case PS_FUNC_END:
            state = PS_DEFAULT;
            break;
          default:
            wrong_char = true;
        }
      break;

      default:
        wrong_char = true;
    }

    //ERROR: unexpected token
    char expected = '?';
    if (wrong_char) {
      switch (state) {
        case PS_DEFAULT:    expected = 'o'; break;
        case PS_NEED_VALUE: expected = 'V'; break;
        case PS_FUNC_START: expected = LX_LEFTBRACE; break;
        case PS_FUNC_ARG:   expected = 'A'; break;
        case PS_FUNC_END:   expected = LX_RIGHTBRACE; break;
      }
      list_pushi(lst_tokens, (int)(expr-startptr), expected);
      return PR_BAD_TOKEN;
    }

    expr++;
  }

  //ERROR: still opened brackets
  if (brace_cnt > 0) {
    list_pushi(lst_tokens, (int)(expr-startptr), brace_cnt);
    return PR_NEED_BRACE;
  }

  //ERROR: non-default state after all
  if (state != PS_DEFAULT) {
    list_pushi(lst_tokens, 0, state);
    return PR_BAD_STATE;
  }

  return PR_DONE;
}

lst_f eval_func(TokenType func, lst_f x) {
  lst_f result;
  switch (func) {
    case TK_FUNC_SIN:
      result = sin(x); break;
    case TK_FUNC_COS:
      result = cos(x); break;
    case TK_FUNC_EXP:
      result = exp(x); break;
    case TK_FUNC_LOG:
      result = log(x); break;
    case TK_FUNC_SQRT:
      result = sqrt(x); break;
    default:
      result = x;
  }
  return result;
}


