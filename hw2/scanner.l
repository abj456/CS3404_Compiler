%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include "y.tab.h"

int num_lines = 0, num_chars = 0;
// int num_key = 0, num_macro = 0, num_id = 0, num_op = 0,
//     num_punc = 0, num_int = 0, num_float = 0, num_character = 0, num_str = 0;

char input_string[1000] = {'\0'};
char token_string[1000] = {'\0'};

bool pragma_source = true, pragma_token = true;

%}
condition_key ("for"|"do"|"while"|"break"|"continue"|"if"|"else"|"return"|"struct"|"switch"|"case"|"default")
data_type_key ("const"|"signed"|"unsigned"|"short"|"long")
var_type_key  ("void"|"int"|"char"|"float"|"double"|"char4"|"char8")

macros  ("NULL"|"__COUNTER__"|"__LINE__"|"INT_MAX"|"INT_MIN"|"CHAR_MAX"|"CHAR_MIN"|"MAX"|"MIN")

ws      [ \t]+
alpha   [A-Za-z]
dig     [0-9]
oct     [0-7]
hex     [0-9A-Fa-f]
id      ({alpha}|\_)({alpha}|{dig}|\_)*
shiftop ("<<"|">>")
relop   ("<"|"<="|">"|">="|"=="|"!=")
addop   [+-]
mulop   [*/%]
incop   ("++"|"--")
logop   [&^|!~]|"&&"|"||"
punc    (":"|";"|","|"."|"["|"]"|"("|")"|"{"|"}")

integer  {dig}+
floating {dig}*\.{dig}*([eE][-+]?{dig}+)?

escape_seq ("\\a"|"\\b"|"\\e"|"\\f"|"\\n"|"\\r"|"\\t"|"\\v"|"\\0"|"\\\'"|"\\\""|"\\\?"|"\\\\"|"\\"{oct}|"\\"{oct}{oct}|"\\"{oct}{oct}{oct}|"\\x"{hex}+|"\\u"{hex}{hex}{hex}{hex}|"\\U"{hex}{hex}{hex}{hex}{hex}{hex}{hex}{hex})
character \'(.|{escape_seq})\'
string \"([^\n\"]|{escape_seq})*\"

comment1 "//".*
comment2 "/*"
%x COMMENT2

pragma "#pragma"
source "source"
token "token"
on  "on"
off "off"
pragma_source_on  {pragma}{ws}{source}{ws}{on}
pragma_source_off {pragma}{ws}{source}{ws}{off}
pragma_token_on   {pragma}{ws}{token}{ws}{on}
pragma_token_off  {pragma}{ws}{token}{ws}{off}

%%
{pragma_source_on}  {
    pragma_source = true;
    // strcat(input_string, yytext);
}
{pragma_source_off} {
    pragma_source = false;
    // strcat(input_string, yytext);
}
{pragma_token_on}   {
    pragma_token = true;
    // strcat(input_string, yytext);
}
{pragma_token_off}  {
    pragma_token = false;
    // strcat(input_string, yytext);
}

{comment1} {
    // strcat(input_string, yytext);
}
{comment2} {
    BEGIN COMMENT2;
    // strcat(input_string, yytext);
}
{data_type_key}|{var_type_key} {
    strcpy(yylval.type, yytext);
    // printf("type: %s\n", yylval.type);
    if(strcmp(yylval.type, "const") == 0) {
        return CONST;
    }
    else if(strcmp(yylval.type, "signed") == 0) {
        return SIGNED;
    }
    else if(strcmp(yylval.type, "unsigned") == 0) {
        return UNSIGNED;
    }
    else if(strcmp(yylval.type, "short") == 0) {
        return SHORT;
    }
    else if(strcmp(yylval.type, "long") == 0) {
        return LONG;
    }
    else if(strcmp(yylval.type, "void") == 0) {
        return VOID;
    }
    else if(strcmp(yylval.type, "int") == 0) {
        return INT;
    }
    else if(strcmp(yylval.type, "char") == 0) {
        return CHAR;
    }
    else if(strcmp(yylval.type, "float") == 0) {
        return FLOAT;
    }
    else if(strcmp(yylval.type, "double") == 0) {
        return DOUBLE;
    }
    else if(strcmp(yylval.type, "char4") == 0) {
        return INT;
    }
    else if(strcmp(yylval.type, "char8") == 0) {
        return LONG;
    }
}

{condition_key} {
    // ++num_key;
    if(pragma_token){
    }
    else {}

    if(pragma_source){
    }
    else {}

    strcpy(yylval.stmt, yytext);
    // printf("stmt: %s\n", yylval.stmt);
    if(strcmp(yylval.stmt, "if") == 0) {
        return IF;
    }
    else if(strcmp(yylval.stmt, "else") == 0) {
        return ELSE;
    }
    else if(strcmp(yylval.stmt, "switch") == 0) {
        return SWITCH;
    }
    else if(strcmp(yylval.stmt, "case") == 0) {
        return CASE;
    }
    else if(strcmp(yylval.stmt, "default") == 0) {
        return DEFAULT;
    }
    else if(strcmp(yylval.stmt, "do") == 0) {
        return DO;
    }
    else if(strcmp(yylval.stmt, "while") == 0) {
        return WHILE;
    }
    else if(strcmp(yylval.stmt, "for") == 0) {
        return FOR;
    }
    else if(strcmp(yylval.stmt, "return") == 0) {
        return RETURN;
    }
    else if(strcmp(yylval.stmt, "break") == 0) {
        return BREAK;
    }
    else if(strcmp(yylval.stmt, "continue") == 0) {
        return CONTINUE;
    }
}

{macros} {
    // ++num_macro;
    if(pragma_token){
        // strcat(token_string, "#macro:");
        // strcat(token_string, yytext);
        // strcat(token_string, "\n");
    }
    else {}

    if(pragma_source){
        // strcat(input_string, yytext);
    }
    else {}

    // printf("macros is %s\n", yytext);
    if(strcmp(yytext, "NULL") == 0){
        yylval.intVal = 0;
        return INTEGER;
    }
}

{id}    {
    yylval.ident = (char*)malloc(sizeof(char)*strlen(yytext));
    strcpy(yylval.ident, yytext);
    // printf("ident is %s, length is %d\n", yylval.ident, (int)strlen(yylval.ident));
    return IDENT;
}

{addop}    {
    strcpy(yylval.op, yytext);
    // printf("addop is \'%s\'\n", yylval.op);
    return *yylval.op;
}
{mulop}    {
    strcpy(yylval.op, yytext);
    // printf("mulop is \'%s\'\n", yylval.op);
    return *yylval.op;
}
{shiftop} {
    strcpy(yylval.op, yytext);
    // printf("relop is \'%s\'\n", yylval.op);
    if(strcmp(yylval.op, "<<") == 0) {
        return LEFT_SHIFT;
    }
    else if(strcmp(yylval.op, ">>") == 0) {
        return RIGHT_SHIFT;
    }
}
{relop} {
    strcpy(yylval.op, yytext);
    // printf("relop is \'%s\'\n", yylval.op);
    if(strcmp(yylval.op, "<=") == 0) {
        return LESS_OR_EQUAL;
    }
    else if(strcmp(yylval.op, ">=") == 0) {
        return GREATER_OR_EQUAL;
    }
    else if(strcmp(yylval.op, "==") == 0) {
        return EQUALS;
    }
    else if(strcmp(yylval.op, "!=") == 0) {
        return NOT_EQUALS;
    }
    else return *yylval.op;
}
{incop} {
    strcpy(yylval.op, yytext);
    // printf("incop is \'%s\'\n", yylval.op);
    if(strcmp(yylval.op, "++") == 0){
        return INC;
    }
    else if(strcmp(yylval.op, "--") == 0) {
        return DEC;
    }
}
{logop} {
    strcpy(yylval.op, yytext);
    // printf("logop is \'%s\'\n", yylval.op);
    if(strcmp(yylval.op, "&&") == 0){
        return AND;
    }
    else if(strcmp(yylval.op, "||") == 0) {
        return OR;
    }
    else {
        return *yylval.op;
    }
}
"=" {
    strcpy(yylval.op, yytext);
    // printf("op is \'%s\'\n", yylval.op);
    return *yylval.op;
}

{punc} {
    // ++num_punc;
    if(pragma_token){
    }
    else {}

    if(pragma_source){
    }
    else {}

    strcpy(yylval.punc, yytext);
    // printf("punc is \'%s\'\n", yylval.punc);
    return *yytext;
}

{integer} {
    // ++num_int;
    if(pragma_token){
    }
    else {}

    if(pragma_source){
    }
    else {}

    yylval.intVal = atoi(yytext);
    // printf("integer = %d\n", yylval.intVal);
    return INTEGER;
}

{floating} {
    // ++num_float;
    if(pragma_token){
    }
    else {}

    if(pragma_source){
    }
    else {}

    yylval.floatVal = atof(yytext);
    // printf("float = %f\n", yylval.floatVal);
    return FLOATING;
}

{character} {
    // ++num_character;
    strcpy(yylval.character, yytext);
    // printf("char = %s\n", yylval.character);
    return CHARACTER;
}

{string} {
    // ++num_str;
    if(pragma_token){
    }
    else {}

    if(pragma_source){
    }
    else {}
    
    strcpy(yylval.str, yytext);
    // printf("string = %s\n", yylval.str);
    return STRING;
}



\n {
    if(pragma_token){
    }
    if(pragma_source){
    }

    memset(token_string, '\0', strlen(token_string));
    memset(input_string, '\0', strlen(input_string));
}

<COMMENT2>\n {
    if(pragma_token){
    }
    if(pragma_source){
    }

    memset(token_string, '\0', strlen(token_string));
    memset(input_string, '\0', strlen(input_string));
}
<COMMENT2>"*/" {
    // strcat(input_string, yytext);
    BEGIN 0;
}


. {
    // strcat(input_string, yytext);
}
<COMMENT2>. {
    // strcat(input_string, yytext);
}
%%
