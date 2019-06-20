%{
#include <stdio.h>
#include <string.h>

void yyerror(char *);
int yylex(void);

char tmp_name[5];
int tmp_cnt = 0;
int next_tmp();
%}

/* yylval에 다양한 타입을 담기 위한 union */
%union  {
                float f_val;
                int i_val;
                char s_val[256];
        }

%token <s_val> FLOAT
%token <s_val> INT
%token <s_val> IDENTIFIER
%token <s_val> EQ
%token OTHER

/* 연산자 우선순위의 오름차순 */
%left '+' '-'
%left '*' '/'
%right UMINUS

%type <s_val> expr

%%

lines : lines stmt
      | lines '\n'
      | /* empty */
      ;

stmt : expr ';'
     ;

expr : FLOAT               { strcpy($$, $1); }
     | INT                 { strcpy($$, $1); }
     | expr '+' expr       { sprintf(tmp_name, "t%d", next_tmp());
                             strcpy($$, tmp_name);
                             printf("%s = %s + %s\n", $$, $1, $3); }
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