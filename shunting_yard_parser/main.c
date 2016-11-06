#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>
#include <math.h>
#include "datalist.h"
#include "syntax.h"

static int get_priority(char op) {
  int result = 0;
  switch (op) {
    case LX_POWER:
      result = 4; break;
    case LX_MULTIPLY: case LX_DIVIDE:
      result = 3; break;
    case LX_ADD: case LX_SUBMINUS:
      result = 2; break;
    case LX_LEFTBRACE:
      result = 1; break;
  }
  return result;
}

int main() {
  FILE* inputf = fopen("input.txt", "rb");
  if (inputf == NULL)
    return EXIT_FAILURE;

  fseek(inputf, 0, SEEK_END);
  long int expr_sz = ftell(inputf);
  fseek(inputf, 0, SEEK_SET);

  char expr[expr_sz+1];
  fread(expr, sizeof(char), expr_sz, inputf);
  expr[expr_sz] = '\0';

  fclose(inputf);
  printf("%s\n\n", expr);

  pDataList tokens = list_new();
  pDataList var_names = list_new();
  bool failure = true;

  switch (parse_expr(expr, tokens, var_names)) {

    case PR_DONE:
      printf("Successfully parsed: %d tokens, %d variables",
        tokens->length, var_names->length);
      failure = false;
    break;

    case PR_NEED_BRACE:
      printf("Syntax error at %d: %d opened brackets left",
        tokens->last->value, tokens->last->d_int);
    break;

    case PR_LOST_BRACE:
      printf("Syntax error at %d: right brace without left",
        tokens->last->value);
    break;

    case PR_BAD_CHAR:
      printf("Syntax error at %d: control or non-ASCII char #%hhu",
        tokens->last->value, tokens->last->d_int);
    break;

    case PR_BAD_TOKEN:
      printf("Syntax error at %d: expected '%c'",
        tokens->last->value, tokens->last->d_int);
    break;

    case PR_BAD_STATE:
      printf("Parser error: non-default state #%d after processing",
        tokens->last->d_int);
    break;
  }

  puts("\n");
  if (failure) {
    list_free(tokens);
    list_free(var_names);
    system("pause>nul");
    return EXIT_FAILURE;
  }

  lst_f var_vals[var_names->length];
  pListItem var = var_names->first;
  for(int i = 0; i < var_names->length; ++i) {
    printf("Enter value for '%s': ", var->d_raw);
    scanf("%g", &var_vals[i]);
    var = var->next;
  }

  int priority;
  ListItem item;
  pDataList out = list_new();
  pDataList scope = list_new();

  while (tokens->length > 0) {
    item = list_prior(tokens);
    switch (item.value) {
      case TK_NUMBER:
      case TK_VARIABLE: case TK_FUNC_SIN: case TK_FUNC_COS:
      case TK_FUNC_EXP: case TK_FUNC_LOG: case TK_FUNC_SQRT:
        list_pushb(out, item.value, item.d_raw);
      break;

      case TK_LEFTBRACE:
        list_pushi(scope, TK_LEFTBRACE, LX_LEFTBRACE);
      break;

      case TK_RIGHTBRACE:
        while (scope->length > 0) {
          item = list_pop(scope);
          if (item.value == TK_LEFTBRACE) {break;}
          list_pushi(out, TK_OPERATION, item.d_int);
        }
      break;

      case TK_OPERATION:
        priority = get_priority(item.d_int);
        while (scope->length > 0) {
          if (priority > get_priority(scope->last->d_int)) {break;}
          list_pushi(out, TK_OPERATION, list_pop(scope).d_int);
        }
        list_pushi(scope, TK_OPERATION, item.d_int);
      break;
    }
  }

  //flush scope
  while (scope->length > 0) {
    list_pushi(out, TK_OPERATION, list_pop(scope).d_int);
  }

  //evaluating
  lst_f op1, op2, result;
  int var_num;
  while (out->length > 0) {
    item = list_prior(out);
    switch (item.value) {

      case TK_NUMBER:
        list_pushr(scope, 0, item.d_real);
      break;

      case TK_VARIABLE: case TK_FUNC_SIN: case TK_FUNC_COS:
      case TK_FUNC_EXP: case TK_FUNC_LOG: case TK_FUNC_SQRT:
        var_num = 0;
        list_findb(var_names, item.d_raw, &var_num);
        list_pushr(scope, 0, eval_func(item.value, var_vals[var_num]));
      break;

      case TK_OPERATION:
        op2 = list_pop(scope).d_real;
        op1 = list_pop(scope).d_real;
        switch (item.d_int) {
          case LX_ADD:
            result = op1 + op2; break;
          case LX_SUBMINUS:
            result = op1 - op2; break;
          case LX_MULTIPLY:
            result = op1 * op2; break;
          case LX_DIVIDE:
            result = op1 / op2; break;
          case LX_POWER:
            result = pow(op1, op2); break;
          default: //somethin' weird
            result = NAN;
        }
        list_pushr(scope, 0, result);
        printf("%g %c %g = %g\n", op1, item.d_int, op2, result);
    }
  }
  printf("\nResult: %g\n", list_pop(scope).d_real);

  list_free(tokens);
  list_free(var_names);
  list_free(out);
  list_free(scope);

  system("pause>nul");
  return EXIT_SUCCESS;
}
