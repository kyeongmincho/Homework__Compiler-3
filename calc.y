%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

int yylex(void);
void yyerror(const char *msg);

FILE *yyin, *outfile;

char tmp_name[5];
int tmp_cnt = 0;
int next_tmp();

struct symbol_struct {
    char name[256];
    int type;
};

struct symbol_struct sym_tab[512];
int sym_cnt = 0;

int lookup_sym_tab(const char *);

enum {
    INT_TYPE = 1,
    FLOAT_TYPE
};

int type_check_flag = 0;
int idx;

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

asgn : IDENTIFIER EQ expr { idx = lookup_sym_tab($1);
                            if (idx == -1) {
                                fprintf(outfile, "Error!\n%s is unknown id\n",
                                $1);
                                exit(0);
                            }
                            fprintf(outfile, "%s = %s\n", $1, $3);
                            if (type_check_flag != sym_tab[idx].type)
                                fprintf(outfile, "//warning: type mismatch\n");
                            type_check_flag = 0;}
     ;

decl : TYPE IDENTIFIER { if (lookup_sym_tab($2) != -1) {
                            fprintf(outfile, "Error!\n%s is already declared\n",
                             $2);
                            exit(0);
                         }
                         strcpy(sym_tab[sym_cnt].name, $2);
                         sym_tab[sym_cnt++].type = $1; }
     ;

expr : FLOAT               { type_check_flag |= FLOAT_TYPE;
                             strcpy($$, $1); }
     | INT                 { type_check_flag |= INT_TYPE;
                             strcpy($$, $1); }
     | IDENTIFIER          { idx = lookup_sym_tab($1);
                             if (idx == -1) {
                                fprintf(outfile, "Error!\n%s is unknown id\n",
                                $1);
                                exit(0);
                             }
                             type_check_flag |= sym_tab[idx].type;
                             strcpy($$, $1); }
     | expr '+' expr       { sprintf(tmp_name, "t%d", next_tmp());
                             strcpy($$, tmp_name);
                             fprintf(outfile, "%s = %s + %s\n", tmp_name, $1,
                             $3); }
     | expr '-' expr       { sprintf(tmp_name, "t%d", next_tmp());
                             strcpy($$, tmp_name);
                             fprintf(outfile, "%s = %s - %s\n", $$, $1, $3); }
     | expr '*' expr       { sprintf(tmp_name, "t%d", next_tmp());
                             strcpy($$, tmp_name);
                             fprintf(outfile, "%s = %s * %s\n", $$, $1, $3); }
     | expr '/' expr       { sprintf(tmp_name, "t%d", next_tmp());
                             strcpy($$, tmp_name);
                             fprintf(outfile, "%s = %s / %s\n", $$, $1, $3); }
     | '(' expr ')'        { strcpy($$, $2); }
     | '-' expr %prec UMINUS { sprintf(tmp_name, "t%d", next_tmp());
                               strcpy($$, tmp_name);
                               fprintf(outfile, "%s = -%s\n", $$, $2); }
     ;

%%

/* error 내용을 출력 */
void yyerror(const char *s)
{
  printf("%s\n", s);
}

/* 에러가 나기 전까지 수식 계산을 반복 */
int main(int argc, char **argv)
{
  yyin = fopen(argv[1], "r");
  outfile = fopen("output.txt", "w");
  yyparse();
  fclose(yyin);
  fclose(outfile);
  return 0;
}

/* tmp 변수의 인덱스를 관리 */
int next_tmp()
{
  return tmp_cnt++;
}

/* 심볼 테이블에 변수가 선언되었는지 체크 */
int lookup_sym_tab(const char *name)
{
  int i, ret = -1;
  for (i = 0; i < sym_cnt; ++i) {
    if (!strcmp(sym_tab[i].name, name)) {
      ret = i;
      break;
    }
  }
  return ret;
}