#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>
#include <string.h>
#include <ctype.h>
#include "intlist.h"

#define LEFTBRACE '('
#define RIGHTBRACE ')'
#define MAX_EXPR_LEN 100

typedef enum {
  TK_UNDEF,
  TK_END,
  TK_UNKNOWN,
  TK_NUMBER,
  TK_LEFTBRACE,
  TK_RIGHTBRACE,
  TK_OPERATION
} TokenType;

typedef enum {
  OP_ADD = '+',
  OP_SUBTRACT = '-',
  OP_MULTIPLY = '*',
  OP_DIVIDE = '/'
} OperType;

static TokenType get_token(char* str, int* pos, int* token) {
  *token = 0;
  TokenType result = TK_UNDEF;

  while (result == TK_UNDEF) {

    if (isdigit(str[*pos])) {
      *token = strtol(&str[*pos], NULL, 10);
      if (*token == 0) {
        (*pos)++;
      } else {
        for(int chk = *token; chk > 0; chk /= 10) {(*pos)++;}
      }
      return TK_NUMBER;
    }

    switch (str[*pos]) {

      case OP_ADD: case OP_SUBTRACT:
      case OP_MULTIPLY: case OP_DIVIDE:
        *token = str[*pos];
        result = TK_OPERATION;
      break;

      case LEFTBRACE:
        *token = str[*pos];
        result = TK_LEFTBRACE;
      break;

      case RIGHTBRACE:
        *token = str[*pos];
        result = TK_RIGHTBRACE;
      break;

      case ' ':
      break;

      case '\0':
        result = TK_END;
      break;

      default:
        *token = str[*pos];
        result = TK_UNKNOWN;
    }

    (*pos)++;
  }
  return result;
}

static int get_priority(char op) {
  switch (op) {
    case OP_MULTIPLY: case OP_DIVIDE:
      return 3; break;
    case OP_ADD: case OP_SUBTRACT:
      return 2; break;
    case '(':
      return 1; break;
  }
  return 0;
}

int main() {
  FILE* inputf = fopen("input.txt", "r");
  if (inputf == NULL)
    return EXIT_FAILURE;
  char expr[MAX_EXPR_LEN+1] = {0};
  fgets(expr, sizeof(expr), inputf);
  fclose(inputf);
  printf("%s\n\n", expr);

  pIntList out_data = list_new(),
           out_types = list_new(),
           scope = list_new();

  int token, parsepos = 0, exitcode = EXIT_SUCCESS, priority;
  bool done = false, brace;

  while (!done) {
    switch ( get_token(expr, &parsepos, &token) ) {

      case TK_UNKNOWN:
        printf("ERROR: unknown char '%c' at %d", token, parsepos);
        exitcode = EXIT_FAILURE;
        done = true;
      break;

      case TK_END:
        while ( scope->length > 0 ) {
          list_push(out_data, list_pop(scope));
          list_push(out_types, TK_OPERATION);
        }
        done = true;
      break;

      case TK_NUMBER:
        list_push(out_data, token);
        list_push(out_types, TK_NUMBER);
      break;

      case TK_LEFTBRACE:
        list_push(scope, token);
      break;

      case TK_RIGHTBRACE:
        brace = false;
        while (!brace && (scope->length > 0)) {
          token = list_pop(scope);
          if (token == LEFTBRACE) {
            brace = true;
          } else {
            list_push(out_data, token);
            list_push(out_types, TK_OPERATION);
          }
        }
        if (!brace) {
          printf("ERROR: closing brace without opening.");
          exitcode = EXIT_FAILURE;
          done = true;
        }
      break;

      case TK_OPERATION:
        priority = get_priority(token);
        while (priority <= ((scope->length > 0)?get_priority(scope->last->value):0)) {
          list_push(out_data, list_pop(scope));
          list_push(out_types, TK_OPERATION);
        }
        list_push(scope, token);
      break;
    }
  }

  //evaluating
  if (exitcode != EXIT_FAILURE) {
    int op1, op2, result;
    done = false;
    while (!done) {
      token = list_prior(out_data);
      switch (list_prior(out_types)) {
        case TK_NUMBER:
          list_push(scope, token);
          //printf("value %d\n", token);
        break;
        case TK_OPERATION:
          op2 = list_pop(scope);
          op1 = list_pop(scope);
          switch (token) {
            case OP_ADD:
              result = op1 + op2; break;
            case OP_SUBTRACT:
              result = op1 - op2; break;
            case OP_MULTIPLY:
              result = op1 * op2; break;
            case OP_DIVIDE:
              result = op1 / op2; break;
          }
          list_push(scope, result);
          printf("%d %c %d = %d\n", op1, token, op2, result);
      }
      if (out_data->length == 0)
        done = true;
    }
    printf("\nresult: %d\n", result);
  }

  list_free(out_data);
  list_free(out_types);
  list_free(scope);

  system("pause>nul");
  return exitcode;
}
