%{
#include <stdio.h>
#include <stdlib.h>
void yyerror(const char*);
#define YYSTYPE char *
%}

%token T_IntConstant T_Identifier
%token KW_IF KW_FOR KW_RETURN KW_ELSE KW_WHILE KW_INT KW_DOUBLE

%left '+' '-'
%left '*' '/'
%right U_neg



%%

S   :   Stmt
    |   S Stmt
    ;

Stmt:   T_Identifier '=' E ';'  { printf("pop %s\n\n", $1); }
    ;

E   :   E '+' E                 { printf("add\n"); }
    |   E '-' E                 { printf("sub\n"); }
    |   E '*' E                 { printf("mul\n"); }
    |   E '/' E                 { printf("div\n"); }
    |   '-' E %prec U_neg       { printf("neg\n"); }
    |   T_IntConstant           { printf("push %s\n", $1); }
    |   T_Identifier            { printf("push %s\n", $1); }
    |   '(' E ')'               { /* empty */ }
    ;

primary_expression: 
	IDENTIFIER 
	|
	TRUE 
	|
	FALSE 
	| 
	T_IntConstant 
	| 
	T_FloatConstant 
	|
	 '(' expression ')'
    ;
/*后缀表达式*/
postfix_expression:
	primary_expression
	| 	
	postfix_expression '[' expression ']'
		//数组调用
	| 	
	postfix_expression '(' ')'
		//函数调用
	| 	
	postfix_expression '(' argument_expression_list ')'
		//函数调用
	| 	
	postfix_expression INC_OP
		//++
	| 	
	postfix_expression DEC_OP
		//--
    ;
		
argument_expression_list:
	assignment_expression
	| 	
	argument_expression_list ',' assignment_expression 
    ;

/*一元表达式*/
unary_expression:
	postfix_expression	
	| 	
	INC_OP unary_expression
		//++
	| 	
	DEC_OP unary_expression
		//--	
	| 	
	unary_operator unary_expression
    ;
	
/*单目运算符*/
unary_operator:
	'+' 
	| '-' 
	| '~' 
	| '!' 
	;

/*可乘表达式*/
multiplicative_expression:
	unary_expression
	| 
	multiplicative_expression '*' unary_expression
	| 
	multiplicative_expression '/' unary_expression 
	| 
	multiplicative_expression '%' unary_expression 
    ;

/*可加表达式*/
additive_expression:
	multiplicative_expression 
	| additive_expression '+' multiplicative_expression 
	| additive_expression '-' multiplicative_expression 
    ;
	
/*左移右移*/
shift_expression:
	additive_expression 
	| 
	shift_expression LEFT_OP additive_expression 
		//<<
	| 
	shift_expression RIGHT_OP additive_expression 
		//<<
    ;
		
/*关系表达式*/
relational_expression:
	shift_expression 
	| relational_expression '<' shift_expression 
	| relational_expression '>' shift_expression 
	| relational_expression LE_OP shift_expression 
		// <= 
	| relational_expression GE_OP shift_expression 
		// >=
    ;

/*相等表达式*/
equality_expression:
	relational_expression 
	| equality_expression EQ_OP relational_expression 
		// ==
	| equality_expression NE_OP relational_expression 
		// !=
    ;

and_expression:
	equality_expression
	| and_expression '&' equality_expression 
    ;
	
/*异或*/
exclusive_or_expression:
	and_expression 
	| exclusive_or_expression '^' and_expression 
    ;


/*或*/
inclusive_or_expression:
	exclusive_or_expression 
	| inclusive_or_expression '|' exclusive_or_expression 
    ;
	
/*and逻辑表达式*/
logical_and_expression:
	inclusive_or_expression 
	| logical_and_expression AND_OP inclusive_or_expression 
		//&&
    ;

/*or 逻辑表达式*/
logical_or_expression:
	logical_and_expression 
	| logical_or_expression OR_OP logical_and_expression 
		//||
    ;

/*赋值表达式*/
assignment_expression:
	logical_or_expression 
		//条件表达式
	| unary_expression assignment_operator assignment_expression 	
    ;
	
/*赋值运算符*/
assignment_operator:
	'=' 
	| MUL_ASSIGN 
		//*=
	| DIV_ASSIGN 
		// /=
	| MOD_ASSIGN 
		// %=
	| ADD_ASSIGN 
		// += 
	| SUB_ASSIGN 
		// -=
	| LEFT_ASSIGN 
		// <<=
	| RIGHT_ASSIGN 
		// >>=
	| AND_ASSIGN 
		// &=
	| XOR_ASSIGN 
		// ^=
	| OR_ASSIGN 
		// |=
    ;

/*表达式*/
expression:
	assignment_expression 
		//赋值表达式
	| expression ',' assignment_expression 
		//逗号表达式
    ;
		
declaration:
	type_specifier ';' 
	| type_specifier init_declarator_list ';' 
    ;

init_declarator_list:
	init_declarator 
	| init_declarator_list ',' init_declarator 
    ;

init_declarator:
	declarator 
	| declarator '=' initializer 
    ;

/*类型说明符*/
type_specifier:
	VOID 
	| CHAR 
	| KW_INT 
	| KW_DOUBLE 
	| BOOL 
    ;

declarator:
	IDENTIFIER 
		//变量
	| '(' declarator ')' 
		//.....
	| declarator '[' assignment_expression ']' 
		//数组
	| declarator '[' '*' ']' 
		//....
	| declarator '[' ']' 
		//数组
	| declarator '(' parameter_list ')' 
		//函数
	| declarator '(' identifier_list ')' 
		//函数
	| declarator '(' ')' 
		//函数
    ;
		
//参数列表
parameter_list:
	parameter_declaration 
	| parameter_list ',' parameter_declaration 
    ;

parameter_declaration:
	type_specifier declarator 
	| type_specifier abstract_declarator 
	| type_specifier 
    ;

identifier_list:
	IDENTIFIER 
	| identifier_list ',' IDENTIFIER
    ;

abstract_declarator:
	'(' abstract_declarator ')' 
	| '[' ']' 
	| '[' assignment_expression ']' 
	| abstract_declarator '[' ']' 
	| abstract_declarator '[' assignment_expression ']' 
	| '[' '*' ']' 
	| abstract_declarator '[' '*' ']' 
	| '(' ')' 
	| '(' parameter_list ')' 
	| abstract_declarator '(' ')' 
	| abstract_declarator '(' parameter_list ')' 
    ;
	
//初始化
initializer:
	assignment_expression 
	| '{' initializer_list '}' 
		//列表初始化 {1,1,1}
	| '{' initializer_list ',' '}' 
		//列表初始化 {1,1,1,}
    ;

initializer_list:
	initializer 
	| designation initializer 
	| initializer_list ',' initializer 
	| initializer_list ',' designation initializer
    ; 

designation:
	designator_list '=' 
    ;

designator_list:
	designator 
	| designator_list designator 
    ;

designator: 
	'[' logical_or_expression ']' 
	| '.' IDENTIFIER 
    ;

//声明
statement:
	labeled_statement 
	| compound_statement 
	| expression_statement
	| selection_statement 
	| iteration_statement 
	| jump_statement 
    ;

//标签声明
labeled_statement:
	IDENTIFIER ':' statement 
	| CASE logical_or_expression ':' statement 
    ;

//复合语句
compound_statement:
	'{' '}' 
	| '{' block_item_list '}' 
    ;

block_item_list:
	block_item 
	| block_item_list block_item 
    ;

block_item:
	declaration 
	| statement 
    ;

expression_statement:
	';' 
	| expression ';' 
    ;

//条件语句
selection_statement:
	KW_IF '(' expression ')' statement %prec LOWER_THAN_ELSE 
    | KW_IF '(' expression ')' statement KW_ELSE statement 
    | SWITCH '(' expression ')' statement
    ;

 //循环语句
iteration_statement:
	KW_WHILE '(' expression ')' statement 
	| DO statement KW_WHILE '(' expression ')' ';' 
	| KW_FOR '(' expression_statement expression_statement ')' statement 
	| KW_FOR '(' expression_statement expression_statement expression ')' statement 
	| KW_FOR '(' declaration expression_statement ')' statement 
	| KW_FOR '(' declaration expression_statement expression ')' statement 
    ;

//跳转指令
jump_statement:
	GOTO IDENTIFIER ';' 
	| CONTINUE ';' 
	| BREAK ';' 
	| KW_RETURN ';' 
	| KW_RETURN expression ';' 
    ;

translation_unit:
	external_declaration 
	| translation_unit external_declaration 
    ;

external_declaration:
	function_definition 
		//函数定义
	| declaration
		//变量声明
    ;
		
function_definition:
	type_specifier declarator declaration_list compound_statement 
	| type_specifier declarator compound_statement 
    ;

declaration_list:
	declaration 
	| declaration_list declaration 
	;

%%

int main() {
    return yyparse();
}