%{
#include "calc.tab.h"
#include <stdlib.h>
void yyerror(char *);
%}

/* regexp definitions */
delim [ \t]
ws {delim}+
digit [0-9]
letter [A-Za-z]
id {letter}({letter}|{digit})*
integer (0|([1-9]{digit}*))
number {integer}\.{digit}+((E|e)[+\-]?{digit}+)?
operator [-+()/*]
semicolon ;
newline \n

%%

{number} { strcpy(yylval.s_val, yytext);
           return FLOAT; }
{integer} { strcpy(yylval.s_val, yytext);
            return INT; }
{id} { return IDENTIFIER; }
{operator} { return *yytext; }
(=) { strcpy(yylval.s_val, yytext);
      return EQ; }
{ws} ;
{semicolon} { return *yytext; }
{newline} { return *yytext; }
. { return OTHER; }

%%

/* 선언하지 않으면 컴파일 에러 발생 */
int yywrap(void)
{
  return 1;
}