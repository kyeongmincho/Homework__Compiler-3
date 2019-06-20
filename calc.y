%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

void yyerror(char *);
int yylex(void);

char tmp_name[5];
int tmp_cnt = 0;
int next_tmp();

struct symbol_struct {
    char name[256];
    int type;
};

struct symbol_struct sym_tab[512];
int sym_cnt = 0;

int exist_sym_tab(const char *);

%}

/* yylval에 다양한 타입을 담기 위한 union */
%union  {
                float f_val;
                int i_val;
                char s_val[256];
        }

%token <s_val> FLOAT
%token <s_val> INT
%token <i_val> TYPE
%token <s_val> IDENTIFIER
%token <s_val> EQ
%token OTHER

/* 연산자 우선순위의 오름차순 */
%left '+' '-'
%left '*' '/'
%right UMINUS

%type <s_val> expr

%%

lines : lines stmts
      | lines '\n'
      | /* empty */
      ;

stmts : stmt ';'
      ;

stmt : asgn
     | decl
     ;

asgn : IDENTIFIER EQ expr { printf("%s = %s\n", $1, $3); }
     ;

decl : TYPE IDENTIFIER { if (exist_sym_tab($2)) {
                            printf("Error!\n%s is already declared\n", $2);
                            exit(0);
                         }
                         strcpy(sym_tab[sym_cnt].name, $2);
                         sym_tab[sym_cnt++].type = $1; }
     ;

expr : FLOAT               { strcpy($$, $1); }
     | INT                 { strcpy($$, $1); }
     | IDENTIFIER          { if (!exist_sym_tab($1)) {
                                printf("Error!\n%s is unknown id\n", $1);
                                exit(0);
                             }
                             strcpy($$, $1); }
     | expr '+' expr       { sprintf(tmp_name, "t%d", next_tmp());
                             strcpy($$, tmp_name);
                             printf("%s = %s + %s\n", tmp_name, $1, $3); }
     | expr '-' expr       { sprintf(tmp_name, "t%d", next_tmp());
                             strcpy($$, tmp_name);
                             printf("%s = %s - %s\n", $$, $1, $3); }
     | expr '*' expr       { sprintf(tmp_name, "t%d", next_tmp());
                             strcpy($$, tmp_name);
                             printf("%s = %s * %s\n", $$, $1, $3); }
     | expr '/' expr       { sprintf(tmp_name, "t%d", next_tmp());
                             strcpy($$, tmp_name);
                             printf("%s = %s / %s\n", $$, $1, $3); }
     | '(' expr ')'        { strcpy($$, $2); }
     | '-' expr %prec UMINUS { sprintf(tmp_name, "t%d", next_tmp());
                               strcpy($$, tmp_name);
                               printf("%s = -%s\n", $$, $2); }
     ;

%%

/* error 내용을 출력 */
void yyerror(char *s)
{
  printf("%s\n", s);
}

/* 에러가 나기 전까지 수식 계산을 반복 */
int main(void)
{
  yyparse();
  return 0;
}

/* tmp 변수의 인덱스를 관리 */
int next_tmp()
{
  return tmp_cnt++;
}

/* 심볼 테이블에 변수가 선언되었는지 체크 */
int exist_sym_tab(const char *name)
{
  int i, ret = 0;
  for (i = 0; i < sym_cnt; ++i) {
    if (!strcmp(sym_tab[i].name, name)) {
      ret = 1;
      break;
    }
  }
  return ret;
}