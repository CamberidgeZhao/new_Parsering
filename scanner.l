%{
#define YYSTYPE char *
#include "y.tab.h"
#include <stdio.h>   
#include <stdlib.h>
#include <string.h>
int cur_line = 1;
void yyerror(const char *msg);
void unrecognized_char(char c);
%}
                
digit [0-9]

FLOAT           (({digit}*\.{digit}+|{digit}+\.)([eE][+-]?{digit}+)?)|({digit}+[eE][+-]?{digit}+)
STRING          \"([^"\n])*\"
OPERATOR        [-/+*()=;]
INTEGER         [0-9]+
IDENTIFIER      [_a-zA-Z][_a-zA-Z0-9]*
WHITESPACE      [ \t]*

%%
"int"           {return (KW_INT);}
"double"         {return (KW_DOUBLE);}
"if"            {printf("KW_IF");return (KW_IF);}
"else"          {return (KW_ELSE);}
"for"           {return (KW_FOR);}
"while"         {return (KW_WHILE);}
"return"        {return (KW_RETURN);}

{OPERATOR}      { return yytext[0]; }
{INTEGER}       { yylval = strdup(yytext); return (T_IntConstant); }
{FLOAT}         { yylval = strdup(yytext); return (T_FloatConstant); }
{STRING}        {yylval = strdup(yytext); return (T_StringConstant);}
{IDENTIFIER}    { yylval = strdup(yytext); return (T_Identifier); }
{WHITESPACE}    { /* ignore every whitespcace */ }
\n              { cur_line++; }

","         	{ return COMMA; }
"["         	{ return LEFT_BRACKET; }
"]"         	{ return RIGHT_BRACKET; }	
"("             { return LEFT_PARENTHESES;}	
")"             { return RIGHT_PARENTHESES;}
.               { unrecognized_char(yytext[0]); }
"//".*      	{ /* omit comment*/ }
[ \t]       	{ /*ignore white space*/ }
"++"			{ return INC_OP; }

%%

int yywrap(void) { 
    return 1;
}

void unrecognized_char(char c) {
    char buf[32] = "Unrecognized character: ?";
    buf[24] = c;
    yyerror(buf);
}

void yyerror(const char *msg) {
    printf("Error at line %d:\n\t%s\n", cur_line, msg);
    exit(1);
}