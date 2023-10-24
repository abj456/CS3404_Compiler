%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

int num_lines = 0, num_chars = 0;
int num_key = 0, num_macro = 0, num_id = 0, num_op = 0,
    num_punc = 0, num_int = 0, num_float = 0, num_character = 0, num_str = 0;

char input_string[1000] = {'\0'};
char token_string[1000] = {'\0'};

bool pragma_source = true, pragma_token = true;

//pragma is waited to be solved
%}
condition_key ("for"|"do"|"while"|"break"|"continue"|"if"|"else"|"return"|"struct"|"switch"|"case"|"default")
data_type_key ("const"|"signed"|"unsigned"|"short"|"long")
var_type_key  ("void"|"int"|"char"|"float"|"double")
keywords      ({condition_key}|{data_type_key}|{var_type_key})

macros  ("NULL"|"__COUNTER__"|"__LINE__"|"INT_MAX"|"INT_MIN"|"CHAR_MAX"|"CHAR_MIN"|"MAX"|"MIN")

ws      [ \t]+
alpha   [A-Za-z]
dig     [0-9]
oct     [0-7]
hex     [0-9A-Fa-f]
id      ({alpha}|\_)({alpha}|{dig}|\_)*
op      ([-+*/%]|"++"|"--"|"<"|"<="|">"|">="|"=="|"!="|"="|"&&"|"||"|"!"|"&"|"|")
punc    (":"|";"|","|"."|"["|"]"|"("|")"|"{"|"}")

integer  [-+]?{dig}+
floating [-+]?{dig}*\.{dig}*([eE][-+]?{dig}+)?

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
pragma_direc {pragma}{ws}({source}|{token}){ws}({on}|{off})
pragma_source_on  {pragma}{ws}{source}{ws}{on}
pragma_source_off {pragma}{ws}{source}{ws}{off}
pragma_token_on   {pragma}{ws}{token}{ws}{on}
pragma_token_off  {pragma}{ws}{token}{ws}{off}

%%
{pragma_source_on}  {
    pragma_source = true;
    strcat(input_string, yytext);
}
{pragma_source_off} {
    pragma_source = false;
    strcat(input_string, yytext);
}
{pragma_token_on}   {
    pragma_token = true;
    strcat(input_string, yytext);
}
{pragma_token_off}  {
    pragma_token = false;
    strcat(input_string, yytext);
}

{comment1} {
    strcat(input_string, yytext);
}
{comment2} {
    BEGIN COMMENT2;
    strcat(input_string, yytext);
}

{keywords} {
    ++num_key;
    if(pragma_token){
        strcat(token_string, "#key:");
        strcat(token_string, yytext);
        strcat(token_string, "\n");
    }
    else {}

    if(pragma_source){
        strcat(input_string, yytext);
    }
    else {}
}

{macros} {
    ++num_macro;
    if(pragma_token){
        strcat(token_string, "#macro:");
        strcat(token_string, yytext);
        strcat(token_string, "\n");
    }
    else {}

    if(pragma_source){
        strcat(input_string, yytext);
    }
    else {}
}

{id}    {
    ++num_id;
    if(pragma_token){
        strcat(token_string, "#id:");
        strcat(token_string, yytext);
        strcat(token_string, "\n");
    }
    else {}

    if(pragma_source){
        strcat(input_string, yytext);
    }
    else {}
}

{op}    {
    ++num_op;
    if(pragma_token){
        strcat(token_string, "#op:");
        strcat(token_string, yytext);
        strcat(token_string, "\n");
    }
    else {}

    if(pragma_source){
        strcat(input_string, yytext);
    }
    else {}
}

{punc} {
    ++num_punc;
    if(pragma_token){
        strcat(token_string, "#punc:");
        strcat(token_string, yytext);
        strcat(token_string, "\n");
    }
    else {}

    if(pragma_source){
        strcat(input_string, yytext);
    }
    else {}
}

{integer} {
    ++num_int;
    if(pragma_token){
        strcat(token_string, "#integer:");
        strcat(token_string, yytext);
        strcat(token_string, "\n");
    }
    else {}

    if(pragma_source){
        strcat(input_string, yytext);
    }
    else {}
}

{floating} {
    ++num_float;
    if(pragma_token){
        strcat(token_string, "#float:");
        strcat(token_string, yytext);
        strcat(token_string, "\n");
    }
    else {}

    if(pragma_source){
        strcat(input_string, yytext);
    }
    else {}
}

{character} {
    ++num_character;
    if(pragma_token){
        strcat(token_string, "#char:");
        strcat(token_string, yytext);
        strcat(token_string, "\n");
    }
    else {}

    if(pragma_source){
        strcat(input_string, yytext);
    }
    else {}
}

{string} {
    ++num_str;
    if(pragma_token){
        strcat(token_string, "#string:");
        strcat(token_string, yytext);
        strcat(token_string, "\n");
    }
    else {}

    if(pragma_source){
        strcat(input_string, yytext);
    }
    else {}
}



\n {
    ++num_lines; num_chars += strlen(input_string) + 1;
    if(pragma_token){
        printf("%s", token_string);
    }
    if(pragma_source){
        printf("%d:", num_lines); 
        printf("%s\n", input_string);
    }

    memset(token_string, '\0', strlen(token_string));
    memset(input_string, '\0', strlen(input_string));
}

<COMMENT2>\n {
    ++num_lines; num_chars += strlen(input_string) + 1;

    if(pragma_token){
        printf("%s", token_string);
    }
    if(pragma_source){
        printf("%d:", num_lines);
        printf("%s\n", input_string);
    }

    memset(token_string, '\0', strlen(token_string));
    memset(input_string, '\0', strlen(input_string));
}
<COMMENT2>"*/" {
    strcat(input_string, yytext);
    BEGIN 0;
}


. {
    strcat(input_string, yytext);
}
<COMMENT2>. {
    strcat(input_string, yytext);
}

%%

int main(int argc, char* argv[]){
    yylex(); 

    return 0;
}
