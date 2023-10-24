%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <ctype.h>
    #define MAX_TABLE_SIZE 5000
    #define HIGH 1
    #define LOW 0

    typedef enum variant_symbol Variant;
    enum variant_symbol{VARIABLE, FUNCTION, FUNCTION_DECL,
        FUNCTION_DEF, ARGUMENT};
    typedef enum symb_type T_Type;
    enum symb_type{T_INT, T_CHAR, T_FUNC};

    extern int yylex();
    extern char yytext[];
    void add(char);
    void insert_type();
    int search(char*);
    char *install_symbol(char *s);
    char *install_symbol_FUNC(int scope, char *name);
    char *install_symbol_INTARG(int scope, char *name);
    int look_up_symbols(char *s);
    void pop_up_symbol(int scope);

    int yydebug = 1;
    int decl_flag = 0;
    FILE *fp;

    struct dataType {
        char *name;
        T_Type type;
        // char *type_to_read;
        int value;
        int scope;
        int offset;   //i-th argument || i-th local variable || k-th field name
        Variant variant;  //what symbol? variable || function || argument
        int total_args;
        int total_locals;
        int mode;     //global || parameter || local variable
    } symbol_table[MAX_TABLE_SIZE];

    typedef struct dataType *PTR_SYMB;

    int cur_counter = 0;
    int cur_scope = 0;
    int q;
    char type[40];

    void code_gen_func_header(); //A part
    void code_gen_at_end_of_function_body(); //B part
    void func_invocation(); //C part
    void func_return(); //D part
%}
%union {
    char *program;
    char *statement;
    char *declar;
    char *expr;
    char *ident;
    char *additional;

    char *type_list;

    int intVal; 
    char character[5];
    char *str;
    double floatVal;
    double doubleVal;
    char type[50];
    char stmt[50];
    char op[5];
    char punc[5];
    char macros[20];
}
%token<ident> IDENT
%token<intVal> INTEGER
%token<floatVal> FLOATING
%token<character> CHARACTER
%token<str> STRING
%token<op> LEFT_SHIFT RIGHT_SHIFT
%token<op> LESS_OR_EQUAL GREATER_OR_EQUAL EQUALS NOT_EQUALS
%token<op> INC DEC 
%token<op> AND OR
%token<type> CONST SIGNED UNSIGNED SHORT LONG VOID INT CHAR FLOAT DOUBLE
%token<stmt> IF ELSE SWITCH CASE DEFAULT DO WHILE FOR RETURN BREAK CONTINUE


%type<op> pointer unary_op assignment_op
%type<declar> external_declaration declaration function_definition
%type<declar> init_declarator_list init_declarator
%type<declar> direct_declarator declarator declaration_list 

%type<program>program 

%type<statement> stmt compound_stmt //stmt_list
%type<statement> switch_clauses switch_clause labeled_stmt
%type<statement> expression_stmt selection_stmt iteration_stmt jump_stmt
%type<statement> compound_stmt_contents

%type<expr> initializer_list initializer
%type<expr> expression expression_in_for
%type<expr> assignment_expression
%type<expr> constant_expression
%type<expr> conditional_expression
%type<expr> logical_or_expression
%type<expr> logical_and_expression
%type<expr> inclusive_or_expression
%type<expr> exclusive_or_expression
%type<expr> and_expression
%type<expr> equality_expression
%type<expr> relational_expression
%type<expr> shift_expression
%type<expr> additive_expression
%type<expr> multiplicative_expression
%type<expr> cast_expression
%type<expr> unary_expression
%type<expr> postfix_expression
%type<expr> argument_expression_list argument_expression
%type<expr> primary_expression

%type<type> type 
%type<type_list> type_list type_name
%type<additional> parameter_list identifier_list parameter_declaration
%type<additional> abstract_declarator direct_abstract_declarator

%right '='
%left '+' '-'
%left '*' '/' '%'

%start program

%%
program: external_declaration {printf("%s", $1); free($1);}
    | program external_declaration {
        printf("%s", $2);
        free($2);
    }
    ;
external_declaration: declaration {
        $$ = (char *)malloc((strlen($1) + 1) * sizeof(char));
        sprintf($$, "%s", $1);
        free($1);
    }
    | function_definition {
        $$ = (char *)malloc((strlen($1) + 1) * sizeof(char));
        sprintf($$, "%s", $1);
        free($1);
    }
    ;
declaration: type_list init_declarator_list ';'{
        if(decl_flag == 0){//scalar decl
            $$ = (char *)malloc((strlen($1) + strlen($2) + 40) * sizeof(char));
            sprintf($$, "<scalar_decl>%s%s;</scalar_decl>", $1, $2);
        }
        else if(decl_flag == 1){//array decl
            $$ = (char *)malloc((strlen($1) + strlen($2) + 40) * sizeof(char));
            sprintf($$, "<array_decl>%s%s;</array_decl>", $1, $2);
        }
        else if(decl_flag == 2){//function decl
            $$ = (char *)malloc((strlen($1) + strlen($2) + 40) * sizeof(char));
            sprintf($$, "<func_decl>%s%s;</func_decl>", $1, $2);
        }
    }
    ;
/* @@@ functions concerned @@@ */
stmt: compound_stmt {
        $$ = (char *)malloc((strlen($1) + 1) * sizeof(char));
        sprintf($$, "%s", $1);
    }
    /* | switch_clauses {
        $$ = (char *)malloc((strlen($1) + 1) * sizeof(char));
        sprintf($$, "%s", $1);
    } */
    | expression_stmt {
        $$ = (char *)malloc((strlen($1) + 1) * sizeof(char));
        sprintf($$, "%s", $1);
    }
    | selection_stmt {
        $$ = (char *)malloc((strlen($1) + 1) * sizeof(char));
        sprintf($$, "%s", $1);
    }
    | iteration_stmt {
        $$ = (char *)malloc((strlen($1) + 1) * sizeof(char));
        sprintf($$, "%s", $1);
    }
    | jump_stmt {
        $$ = (char *)malloc((strlen($1) + 1) * sizeof(char));
        sprintf($$, "%s", $1);
    }
    ;
function_definition: type_list declarator {
            char *functor = strtok($2, "(");
            printf("func_def: %s\n", functor);
            cur_scope++;
            set_scope_and_offset(functor);
            code_gen_func_header(functor);
        } compound_stmt {
        $$ = (char*)malloc((strlen($1) + strlen($2) + strlen($4) + 30) * sizeof(char));
        sprintf($$, "<func_def>%s%s%s</func_def>", $1, $2, $4);
        printf("here\n");
        
        char *functor = strtok($2, "(");
        //pop_up_symbols();
        cur_scope--;
        code_gen_at_end_of_function_body(functor);
    }
    | declarator compound_stmt{
        $$ = (char*)malloc((strlen($1) + strlen($2) + 30) * sizeof(char));
        sprintf($$, "<func_def>%s%s</func_def>", $1, $2);
    }
    | type_list declarator declaration_list compound_stmt {
        $$ = (char*)malloc((strlen($1) + strlen($2) + strlen($3) + strlen($4) + 30) * sizeof(char));
        sprintf($$, "<func_def>%s%s%s%s</func_def>", $1, $2, $3, $4);
    }
    | declarator declaration_list compound_stmt {
        $$ = (char*)malloc((strlen($1) + strlen($2) + strlen($3) + 30) * sizeof(char));
        sprintf($$, "<func_def>%s%s%s</func_def>", $1, $2, $3);
    }
    ;
declaration_list: declaration_list declaration {
        $$ = (char *)malloc((strlen($1) + strlen($2) + 1) * sizeof(char));
        sprintf($$, "%s%s", $1, $2);
    }
    | declaration {
        $$ = (char *)malloc((strlen($1) + 1) * sizeof(char));
        sprintf($$, "%s", $1);
    }
    ;
switch_clauses: '{' switch_clause '}' {
        $$ = (char *)malloc((strlen($2) + 3) * sizeof(char));
        sprintf($$, "{%s}", $2);
    }
    /* | '{' switch_clauses switch_clause '}' {
        $$ = (char *)malloc((strlen($2) + strlen($3) + 3) * sizeof(char));
        sprintf($$, "{%s%s}", $2, $3);
    } */
    | '{' '}' {
        $$ = (char *)malloc((3) * sizeof(char));
        sprintf($$, "%s", "{}");
    }
    ;
switch_clause: switch_clause stmt {
        $$ = (char *)malloc((strlen($1) + strlen($2) + 20) * sizeof(char));
        if($2[0] == '{'){
            sprintf($$, "%s<stmt>%s</stmt>", $1, $2);
        }
        else {
            sprintf($$, "%s%s", $1, $2);
        }
    }
    | switch_clause labeled_stmt {
        $$ = (char *)malloc((strlen($1) + strlen($2) + 2) * sizeof(char));
        sprintf($$, "%s%s", $1, $2);
    }
    | labeled_stmt {
        $$ = (char *)malloc((strlen($1) + 1) * sizeof(char));
        sprintf($$, "%s", $1);
    }
    ;
labeled_stmt: CASE expression ':' {
        $$ = (char *)malloc((strlen($1) + strlen($2) + 3) * sizeof(char));
        sprintf($$, "%s%s:", $1, $2);
    }
    | DEFAULT ':' {
        $$ = (char *)malloc((strlen($1) + 3) * sizeof(char));
        sprintf($$, "%s:", $1);
    }
    ;
compound_stmt: '{' '}' {
        $$ = (char *)malloc(3 * sizeof(char));
        sprintf($$, "%s", "{}");
    }
    | '{' compound_stmt_contents '}' {
        $$ = (char *)malloc((strlen($2) + 3) * sizeof(char));
        sprintf($$, "{%s}", $2);
    }
    ; 
compound_stmt_contents: declaration {
        $$ = (char *)malloc((strlen($1) + 1) * sizeof(char));
        sprintf($$, "%s", $1);
    }
    | stmt {
        // printf("compound_stmt_content's stmt: %s\n", $1);
        // 
        $$ = (char *)malloc((strlen($1) + 20) * sizeof(char));
        if($1[0] == '{'){
            sprintf($$, "<stmt>%s</stmt>", $1);
        }
        else {
            sprintf($$, "%s", $1);
        }
    }
    | compound_stmt_contents declaration {
        // printf("\ncompound_stmt_contents: declaration = %s\n", $2);
        $$ = (char *)malloc((strlen($1) + strlen($2) + 1) * sizeof(char));
        sprintf($$, "%s%s", $1, $2);
    }
    | compound_stmt_contents stmt {
        // printf("compound_stmt_contents' stmt: %s\n", $2);
        $$ = (char *)malloc((strlen($1) + strlen($2) + 20) * sizeof(char));
        if($2[0] == '{'){
            sprintf($$, "%s<stmt>%s</stmt>", $1, $2);
        }
        else {
            sprintf($$, "%s%s", $1, $2);
        }
    }
    ;
expression_stmt: ';' {
        $$ = (char *)malloc((2) * sizeof(char));
        sprintf($$, "%s", ";");
    }
    | expression ';' {
        $$ = (char *)malloc((strlen($1) + 20) * sizeof(char));
        sprintf($$, "<stmt>%s;</stmt>", $1);
    }
    ;
selection_stmt: IF '(' expression ')' compound_stmt {
        $$ = (char *)malloc((strlen($1) + strlen($3) + strlen($5) + 20) * sizeof(char));
        sprintf($$, "<stmt>%s(%s)%s</stmt>", $1, $3, $5);
    }
    | IF '(' expression ')' compound_stmt ELSE compound_stmt {
        int stmt_len = strlen($1) + strlen($3) + strlen($5) + strlen($6) + strlen($7);
        $$ = (char *)malloc((stmt_len + 20) * sizeof(char));
        sprintf($$, "<stmt>%s(%s)%s%s%s</stmt>", $1, $3, $5, $6, $7);
    }
    | SWITCH '(' expression ')' switch_clauses {
        $$ = (char *)malloc((strlen($1) + strlen($3) + strlen($5) + 20) * sizeof(char));
        sprintf($$, "<stmt>%s(%s)%s</stmt>", $1, $3, $5);
    }
    ;
expression_in_for: expression {
        $$ = (char*)malloc((strlen($1) + 1) * sizeof(char));
        sprintf($$, "%s", $1);
    }
    | {
        $$ = (char*)malloc(1 * sizeof(char));
        sprintf($$, "%s", "");
    }
    ;
iteration_stmt: WHILE '(' expression ')' stmt {
        $$ = (char *)malloc((strlen($1) + strlen($3) + strlen($5) + 40) * sizeof(char));
        if($5[0] == '{'){
            sprintf($$, "<stmt>%s(%s)<stmt>%s</stmt></stmt>", $1, $3, $5);
        }
        else {
            sprintf($$, "<stmt>%s(%s)%s</stmt>", $1, $3, $5);
        }
    }
    | DO stmt WHILE '(' expression ')' ';' {
        int stmt_len = strlen($1) + strlen($2) + strlen($3) + strlen($5);
        $$ = (char *)malloc((stmt_len + 40) * sizeof(char));
        if($2[0] == '{'){
            sprintf($$, "<stmt>%s<stmt>%s</stmt>%s(%s);</stmt>", $1, $2, $3, $5);
        }
        else {
            sprintf($$, "<stmt>%s%s%s(%s);</stmt>", $1, $2, $3, $5);
        }
    }
    | FOR '(' expression_in_for ';' expression_in_for ';' expression_in_for ')' stmt { // 3 expr in for
        int stmt_len = strlen($1) + strlen($3) + strlen($5) + strlen($7) + strlen($9);
        $$ = (char *)malloc((stmt_len + 40) * sizeof(char));
        if($9[0] == '{'){
            sprintf($$, "<stmt>%s(%s;%s;%s)<stmt>%s</stmt></stmt>", $1, $3, $5, $7, $9);
        }
        else {
            sprintf($$, "<stmt>%s(%s;%s;%s)%s</stmt>", $1, $3, $5, $7, $9);
        }
    }
    ;
jump_stmt: CONTINUE ';' {
        $$ = (char *)malloc((strlen($1) + 20) * sizeof(char));
        sprintf($$, "<stmt>%s;</stmt>", $1);
    }
    | BREAK ';' {
        $$ = (char *)malloc((strlen($1) + 20) * sizeof(char));
        sprintf($$, "<stmt>%s;</stmt>", $1);
    }
    | RETURN ';' {
        $$ = (char *)malloc((strlen($1) + 20) * sizeof(char));
        sprintf($$, "<stmt>%s;</stmt>", $1);
    }
    | RETURN expression ';' {
        $$ = (char *)malloc((strlen($1) + strlen($2) + 20) * sizeof(char));
        sprintf($$, "<stmt>%s%s;</stmt>", $1, $2);
    }
    ;
/* @@@variables concerned@@@ */
type_list: type_list type {
        $$ = (char*)malloc((strlen($1) + strlen($2) + 1) * sizeof(char));
        sprintf($$, "%s%s", $1, $2);
    }
    | type {
        $$ = (char*)malloc((strlen($1) + 1)* sizeof(char));
        sprintf($$, "%s", $1);
    }
    ;
type: CONST {
        sprintf($$, "%s", $1);
    }
    | SIGNED {sprintf($$, "%s", $1);}
    | UNSIGNED {sprintf($$, "%s", $1);}
    | SHORT {sprintf($$, "%s", $1);}
    | LONG {sprintf($$, "%s", $1);}
    | VOID {
        sprintf($$, "%s", $1);
        strcpy(type, $1);
    }
    | INT {sprintf($$, "%s", $1);}
    | CHAR {sprintf($$, "%s", $1);}
    | FLOAT {sprintf($$, "%s", $1);}
    | DOUBLE {sprintf($$, "%s", $1);}
    ;
init_declarator_list: init_declarator_list ',' init_declarator{
        $$ = (char*)malloc((strlen($1) + strlen($3) + 2) * sizeof(char));
        sprintf($$, "%s,%s", $1, $3);
    }
    | init_declarator { 
        $$ = (char*)malloc((strlen($1) + 1)* sizeof(char));

        sprintf($$, "%s", $1);
    }
    ;
/* ### ASSIGNMENT lefthand-side start ### */
init_declarator: declarator {
        $$ = (char*)malloc((strlen($1) + 1)* sizeof(char));
        sprintf($$, "%s", $1);
    }
    | declarator '=' initializer {
        $$ = (char*)malloc((strlen($1) + strlen($3) + 2) * sizeof(char));
        sprintf($$, "%s=%s", $1, $3);
        
        install_symbol_INTVAR(cur_scope, $1);
        int local_value = atoi($3);
        symbol_table[cur_counter - 1].value = local_value;

        
    }
    ;
declarator: pointer direct_declarator{
        $$ = (char*)malloc((strlen($1) + strlen($2) + 1) * sizeof(char));
        sprintf($$, "%s%s", $1, $2);
    }
    | direct_declarator {
        $$ = (char*)malloc((strlen($1) + 1)* sizeof(char));
        sprintf($$, "%s", $1);

    }
    ;
direct_declarator: IDENT {
        decl_flag = 0;
        $$ = (char*)malloc((strlen($1) + 1)* sizeof(char));
        sprintf($$, "%s", $1); 

    }
    | direct_declarator '[' expression ']'{
        decl_flag = 1;
        $$ = (char*)malloc((strlen($1) + strlen($3) + 3) * sizeof(char));
        sprintf($$, "%s[%s]", $1, $3);
    }
    | direct_declarator '[' ']'{
        decl_flag = 1;
        $$ = (char*)malloc((strlen($1) + 3) * sizeof(char));
        sprintf($$, "%s[]", $1);
    }
    | '(' declarator ')'{
        $$ = (char*)malloc((strlen($2) + 3) * sizeof(char));
        sprintf($$, "(%s)", $2);
    }
    | direct_declarator '(' parameter_list ')'{
        decl_flag = 2;
        $$ = (char*)malloc((strlen($1) + strlen($3) + 3) * sizeof(char));
        sprintf($$, "%s(%s)", $1, $3);

        // printf("func_name:%s\n", $1);
    }
    | direct_declarator '(' identifier_list ')'{
        decl_flag = 2;
        $$ = (char*)malloc((strlen($1) + strlen($3) + 3) * sizeof(char));
        sprintf($$, "%s(%s)", $1, $3);

        // printf("func_name:%s\n", $1);
    }
    | direct_declarator '(' ')'{
        decl_flag = 2;
        $$ = (char*)malloc((strlen($1) + 3) * sizeof(char));
        sprintf($$, "%s()", $1);
        
        int idx = look_up_symbols($1);
        if(idx == -1){
            install_symbol_FUNC(cur_scope, $1);
            idx = look_up_symbols($1);
            if(symbol_table[idx].scope == 0){
                fprintf(fp, ".global %s\n", symbol_table[idx].name);
            }
        }
    }
    ;
parameter_list: parameter_declaration {
        $$ = (char*)malloc((strlen($1) + 1)* sizeof(char));
        sprintf($$, "%s", $1);
    }
    | parameter_list ',' parameter_declaration {
        $$ = (char*)malloc((strlen($1) + strlen($3) + 2) * sizeof(char));
        sprintf($$, "%s,%s", $1, $3);
    }
    ;
parameter_declaration: type_list declarator {
        $$ = (char*)malloc((strlen($1) + strlen($2)) * sizeof(char));
        sprintf($$, "%s%s", $1, $2);
    }
    | type_list abstract_declarator {
        $$ = (char*)malloc((strlen($1) + strlen($2)) * sizeof(char));
        sprintf($$, "%s%s", $1, $2);
    }
    | type_list {
        $$ = (char*)malloc((strlen($1) + 1)* sizeof(char));
        sprintf($$, "%s", $1);
    }
    ;
identifier_list: IDENT { 
        $$ = (char*)malloc((strlen($1) + 1)* sizeof(char));
        sprintf($$, "%s", $1);
    }
    | identifier_list ',' IDENT {
        $$ = (char*)malloc((strlen($1) + strlen($3) + 2) * sizeof(char));
        sprintf($$, "%s,%s", $1, $3);
    }
    ;
pointer: '*' {sprintf($$, "%s", "*");}
    | pointer '*' {sprintf($$, "%s%s", $1, "*");}
    ;
/* ### ASSIGNMENT left hand side end ### */
/* ### ASSIGNMENT right hand side start ### */
initializer: assignment_expression {
        $$ = (char*)malloc((strlen($1) + 1)* sizeof(char));
        sprintf($$, "%s", $1);
    }
    | '{' initializer_list '}' {
        $$ = (char*)malloc((strlen($2) + 3) * sizeof(char));
        sprintf($$, "{%s}", $2);
    }
    ;
initializer_list: initializer {
        $$ = (char*)malloc((strlen($1) + 1)* sizeof(char));
        sprintf($$, "%s", $1);
    }
    | initializer_list ',' initializer {
        $$ = (char*)malloc((strlen($1) + strlen($3) + 3) * sizeof(char));
        sprintf($$, "%s,%s", $1, $3);
    }
    ;
/* ### ASSIGNMENT right hand side end ### */

/* expression rules start*/
expression: assignment_expression {
        $$ = (char*)malloc((strlen($1) + 1)* sizeof(char));
        sprintf($$, "%s", $1);
    }
    | expression ',' assignment_expression{
        $$ = (char*)malloc((strlen($1) + strlen($3) + 3) * sizeof(char));
        sprintf($$, "%s,%s", $1, $3);
    }
    ;
assignment_expression: conditional_expression {
        $$ = (char*)malloc((strlen($1) + 1)* sizeof(char));
        sprintf($$, "%s", $1);
    }
    | constant_expression assignment_op assignment_expression{
        $$ = (char*)malloc((strlen($1) + strlen($2) + strlen($3) + 20) * sizeof(char));
        sprintf($$, "<expr>%s%s%s</expr>", $1, $2, $3);
    }
    ;
assignment_op: '=' {sprintf($$, "%s", "=");}
    ;
constant_expression: conditional_expression {
        $$ = (char*)malloc((strlen($1) + 1)* sizeof(char));
        sprintf($$, "%s", $1);
    }
    ;
conditional_expression: logical_or_expression {
        $$ = (char*)malloc((strlen($1) + 1)* sizeof(char));

        sprintf($$, "%s", $1);
    }
    | logical_or_expression '?' expression ':' conditional_expression {
        $$ = (char*)malloc((strlen($1) + strlen($3) + strlen($5) + 40) * sizeof(char));
        sprintf($$, "<expr>%s?<expr>%s</expr>:%s</expr>", $1, $3, $5);
    }
    ;
logical_or_expression: logical_and_expression {
        $$ = (char*)malloc((strlen($1) + 1)* sizeof(char));

        sprintf($$, "%s", $1);
    }
    | logical_or_expression OR logical_and_expression {
        $$ = (char*)malloc((strlen($1) + strlen($3) + 20) * sizeof(char));
        sprintf($$, "<expr>%s||%s</expr>", $1, $3);
    }
    ;
logical_and_expression: inclusive_or_expression {
        $$ = (char*)malloc((strlen($1) + 1)* sizeof(char));
        sprintf($$, "%s", $1);
    }
    | logical_and_expression AND inclusive_or_expression {
        $$ = (char*)malloc((strlen($1) + strlen($3) + 20) * sizeof(char));
        sprintf($$, "<expr>%s&&%s</expr>", $1, $3);
    }
    ;
inclusive_or_expression: exclusive_or_expression {
        $$ = (char*)malloc((strlen($1) + 1)* sizeof(char));
        sprintf($$, "%s", $1);
    }
    | inclusive_or_expression '|' exclusive_or_expression  {
        $$ = (char*)malloc((strlen($1) + strlen($3) + 20) * sizeof(char));
        sprintf($$, "<expr>%s|%s</expr>", $1, $3);
    }
    ;
exclusive_or_expression: and_expression {
        $$ = (char*)malloc((strlen($1) + 1)* sizeof(char));
        sprintf($$, "%s", $1);
    }
    | exclusive_or_expression '^' and_expression {
        $$ = (char*)malloc((strlen($1) + strlen($3) + 20) * sizeof(char));
        sprintf($$, "<expr>%s^%s</expr>", $1, $3);
    }
    ;
and_expression: equality_expression {
        $$ = (char*)malloc((strlen($1) + 1)* sizeof(char));
        sprintf($$, "%s", $1);
    }
    | and_expression '&' equality_expression {
        $$ = (char*)malloc((strlen($1) + strlen($3) + 20) * sizeof(char));
        sprintf($$, "<expr>%s&%s</expr>", $1, $3);
    }
    ;
equality_expression: relational_expression {
        $$ = (char*)malloc((strlen($1) + 1)* sizeof(char));
        sprintf($$, "%s", $1);
    }
    | equality_expression EQUALS relational_expression {
        $$ = (char*)malloc((strlen($1) + strlen($3) + 20) * sizeof(char));
        sprintf($$, "<expr>%s==%s</expr>", $1, $3);
    }
    | equality_expression NOT_EQUALS relational_expression {
        $$ = (char*)malloc((strlen($1) + strlen($3) + 20) * sizeof(char));
        sprintf($$, "<expr>%s!=%s</expr>", $1, $3);
    }
    ;
relational_expression: shift_expression {
        $$ = (char*)malloc((strlen($1) + 1)* sizeof(char));
        sprintf($$, "%s", $1);
    }
    | relational_expression '<' shift_expression {
        $$ = (char*)malloc((strlen($1) + strlen($3) + 20) * sizeof(char));
        sprintf($$, "<expr>%s<%s</expr>", $1, $3);
    }
    | relational_expression '>' shift_expression {
        $$ = (char*)malloc((strlen($1) + strlen($3) + 20) * sizeof(char));
        sprintf($$, "<expr>%s>%s</expr>", $1, $3);
    }
    | relational_expression LESS_OR_EQUAL shift_expression {
        $$ = (char*)malloc((strlen($1) + strlen($3) + 20) * sizeof(char));
        sprintf($$, "<expr>%s<=%s</expr>", $1, $3);
    }
    | relational_expression GREATER_OR_EQUAL shift_expression {
        $$ = (char*)malloc((strlen($1) + strlen($3) + 20) * sizeof(char));
        sprintf($$, "<expr>%s>=%s</expr>", $1, $3);
    }
    ;
shift_expression: additive_expression {
        $$ = (char*)malloc((strlen($1) + 1)* sizeof(char));
        sprintf($$, "%s", $1);
    }
    | shift_expression LEFT_SHIFT additive_expression {
        $$ = (char*)malloc((strlen($1) + strlen($3) + 20) * sizeof(char));
        sprintf($$, "<expr>%s<<%s</expr>", $1, $3);
    }
    | shift_expression RIGHT_SHIFT additive_expression {
        $$ = (char*)malloc((strlen($1) + strlen($3) + 20) * sizeof(char));
        sprintf($$, "<expr>%s>>%s</expr>", $1, $3);
    }
    ;
additive_expression: multiplicative_expression {
        $$ = (char*)malloc((strlen($1) + 1)* sizeof(char));
        sprintf($$, "%s", $1);
    }
    | additive_expression '+' multiplicative_expression {
        $$ = (char*)malloc((strlen($1) + strlen($3) + 20) * sizeof(char));
        // sprintf($$, "%s+%s", $1, $3);
        int t0, t1, t2;
        if(isalpha($1[0])){
            int idx = look_up_symbols($1);
            if(idx != -1){
                t1 = symbol_table[idx].value;
            }
        }
        else {
            t1 = atoi($1);
        }

        if(isalpha($3[0])){
            int idx = look_up_symbols($3);
            if(idx != -1){
                t2 = symbol_table[idx].value;
            }
        }
        else {
            t2 = atoi($3);
        }
        t0 = t1 + t2;
        sprintf($$, "%d", t0);
    }
    | additive_expression '-' multiplicative_expression {
        $$ = (char*)malloc((strlen($1) + strlen($3) + 20) * sizeof(char));
        // sprintf($$, "%s-%s", $1, $3);

        int t0, t1, t2;
        if(isalpha($1[0])){
            int idx = look_up_symbols($1);
            if(idx != -1){
                t1 = symbol_table[idx].value;
            }
        }
        else {
            t1 = atoi($1);
        }

        if(isalpha($3[0])){
            int idx = look_up_symbols($3);
            if(idx != -1){
                t2 = symbol_table[idx].value;
            }
        }
        else {
            t2 = atoi($3);
        }
        t0 = t1 - t2;
        sprintf($$, "%d", t0);
    }
    ;
multiplicative_expression: cast_expression {
        $$ = (char*)malloc((strlen($1) + 1)* sizeof(char));
        sprintf($$, "%s", $1);
    }
    | multiplicative_expression '*' cast_expression {
        $$ = (char*)malloc((strlen($1) + strlen($3) + 20) * sizeof(char));
        // sprintf($$, "%s*%s", $1, $3);

        int t0, t1, t2;
        if(isalpha($1[0])){
            int idx = look_up_symbols($1);
            if(idx != -1){
                t1 = symbol_table[idx].value;
            }
        }
        else {
            t1 = atoi($1);
        }

        if(isalpha($3[0])){
            int idx = look_up_symbols($3);
            if(idx != -1){
                t2 = symbol_table[idx].value;
            }
        }
        else {
            t2 = atoi($3);
        }
        t0 = t1 * t2;
        sprintf($$, "%d", t0);
    }
    | multiplicative_expression '/' cast_expression {
        $$ = (char*)malloc((strlen($1) + strlen($3) + 20) * sizeof(char));
        // sprintf($$, "%s/%s", $1, $3);

        int t0, t1, t2;
        if(isalpha($1[0])){
            int idx = look_up_symbols($1);
            if(idx != -1){
                t1 = symbol_table[idx].value;
            }
        }
        else {
            t1 = atoi($1);
        }

        if(isalpha($3[0])){
            int idx = look_up_symbols($3);
            if(idx != -1){
                t2 = symbol_table[idx].value;
            }
        }
        else {
            t2 = atoi($3);
        }
        t0 = t1 / t2;
        sprintf($$, "%d", t0);
    }
    | multiplicative_expression '%' cast_expression {
        $$ = (char*)malloc((strlen($1) + strlen($3) + 20) * sizeof(char));
        // sprintf($$, "%s%%%s", $1, $3);

        int t0, t1, t2;
        if(isalpha($1[0])){
            int idx = look_up_symbols($1);
            if(idx != -1){
                t1 = symbol_table[idx].value;
            }
        }
        else {
            t1 = atoi($1);
        }

        if(isalpha($3[0])){
            int idx = look_up_symbols($3);
            if(idx != -1){
                t2 = symbol_table[idx].value;
            }
        }
        else {
            t2 = atoi($3);
        }
        t0 = t1 % t2;
        sprintf($$, "%d", t0);
    }
    ;
cast_expression: unary_expression {
        $$ = (char*)malloc((strlen($1) + 1)* sizeof(char));
        sprintf($$, "%s", $1);
    }
    | '(' type_name ')' cast_expression {
        $$ = (char*)malloc((strlen($2) + strlen($4) + 20) * sizeof(char));
        sprintf($$, "<expr>(%s)%s</expr>", $2, $4);
    }
    ;
unary_expression: postfix_expression {
        $$ = (char*)malloc((strlen($1) + 1)* sizeof(char));
        sprintf($$, "%s", $1);
    }
    | unary_op cast_expression {
        $$ = (char*)malloc((strlen($1) + strlen($2) + 20) * sizeof(char));
        sprintf($$, "<expr>%s%s</expr>", $1, $2);
    }
    ;
postfix_expression: primary_expression {
        $$ = (char*)malloc((strlen($1) + 20)* sizeof(char));
        sprintf($$, "%s", $1);
    }
    | postfix_expression '(' ')' {
        $$ = (char*)malloc((strlen($1) + 20) * sizeof(char));
        sprintf($$, "%s()", $1);
    }
    | postfix_expression '(' argument_expression_list ')'{
        $$ = (char*)malloc((strlen($1) + strlen($3) + 20) * sizeof(char));
        sprintf($$, "%s(%s)", $1, $3);

        install_symbol_FUNC(cur_scope, $1);
        
        int num_of_arg = 0;
        char *arg_name = strtok($3, ",");
        while(arg_name != NULL){
            install_symbol_INTARG(cur_scope, arg_name);

            int idx = look_up_symbols(arg_name);
            if(idx != -1){
                // printf("idx: %d\n", idx);
                if(strcmp($1, "digitalWrite") == 0 && strcmp(arg_name, "HIGH") == 0){
                    symbol_table[idx].value = 1;
                }
                else if(strcmp($1, "digitalWrite") == 0 && strcmp(arg_name, "LOW") == 0){
                    symbol_table[idx].value = 0;
                }
                else {
                    symbol_table[idx].value = atoi(arg_name);
                }
            }
            arg_name = strtok(NULL, ",");
        }
        int idx = look_up_symbols($1);
        int func_total_args = (cur_counter - 1) - idx;
        symbol_table[idx].total_args = func_total_args;
        printf("%s.total_args = %d\n", $1, symbol_table[idx].total_args);

        func_invocation($1);
        func_return();
    }
    | postfix_expression INC {
        $$ = (char*)malloc((strlen($1) + 20) * sizeof(char));
        sprintf($$, "<expr>%s++</expr>", $1);
    }
    | postfix_expression DEC {
        $$ = (char*)malloc((strlen($1) + 20) * sizeof(char));
        sprintf($$, "<expr>%s--</expr>", $1);
    }
    ;
argument_expression_list: argument_expression {
        $$ = (char*)malloc((strlen($1) + 1)* sizeof(char));
        sprintf($$, "%s", $1);
    }
    | argument_expression_list ',' argument_expression {
        $$ = (char*)malloc((strlen($1) + strlen($3) + 2) * sizeof(char));
        sprintf($$, "%s,%s", $1, $3);
    }
    ;
argument_expression: assignment_expression {
        $$ = (char*)malloc((strlen($1) + 1)* sizeof(char));
        sprintf($$, "%s", $1);
    }
primary_expression: IDENT {
        $$ = (char*)malloc((strlen($1) + 20) * sizeof(char));
        sprintf($$, "%s", $1);
        // printf("IDENT: %s\n", $1);

        // int idx = look_up_symbols($1);
        // if(idx != -1){
        //     sprintf($$, "%d", symbol_table[idx].value);
        // }
    }
    | primary_expression '[' expression ']' {
        $$ = (char*)malloc((strlen($1) + strlen($3) + 20) * sizeof(char));
        sprintf($$, "%s[%s]", $1, $3);
    }
    | INTEGER {
        $$ = (char*)malloc((20) * sizeof(char) + sizeof(int));
        sprintf($$, "%d", $1);
        // printf("%d\n", atoi(yytext));
        // symbol_table[cur_counter].name = strdup(yytext);
        // symbol_table[cur_counter].name = (char*)malloc((strlen(yytext) + 1) * sizeof(char));
        // strcpy(symbol_table[cur_counter].name, yytext);
        // printf("%s\n", symbol_table[cur_counter].name);
    }
    | FLOATING {
        $$ = (char*)malloc((20) * sizeof(char) + sizeof(double));
        sprintf($$, "%f", $1);
    }
    | STRING {
        $$ = (char*)malloc((strlen($1) + 20) * sizeof(char));
        sprintf($$, "%s", $1);
    }
    | CHARACTER {
        $$ = (char*)malloc((strlen($1) + 20) * sizeof(char));
        sprintf($$, "%s", $1);
        // sprintf($$, "<expr>%s</expr>", $1);
    }
    | '(' expression ')' {
        $$ = (char*)malloc((strlen($2) + 20) * sizeof(char));
        // sprintf($$, "(%s)", $2);
        sprintf($$, "%s", $2);
        // sprintf($$, "<expr>(%s)</expr>", $2);
    }
    ;
unary_op: '&' {sprintf($$, "%s", "&");}
    |'*' {sprintf($$, "%s", "*");}
    |'+' {sprintf($$, "%s", "+");}
    |'-' {sprintf($$, "%s", "-");}
    |'~' {sprintf($$, "%s", "~");}
    |'!' {sprintf($$, "%s", "!");}
    | INC {sprintf($$, "%s", "++");}
    | DEC {sprintf($$, "%s", "--");}
    ;
/* expression rules end */

/* additional events start */
type_name: type_list {
        $$ = (char*)malloc((strlen($1) + 10) * sizeof(char));
        sprintf($$, "%s", $1);
    }
    | type_list abstract_declarator {
        $$ = (char*)malloc((strlen($1) + strlen($2) + 10) * sizeof(char));
        sprintf($$, "%s%s", $1, $2);
    }
    ;
abstract_declarator: pointer {
        $$ = (char*)malloc((strlen($1) + 10) * sizeof(char));
        sprintf($$, "%s", $1);
    }
    | direct_abstract_declarator {
        $$ = (char*)malloc((strlen($1) + 10) * sizeof(char));
        sprintf($$, "%s", $1);
    }
    | pointer direct_abstract_declarator {
        $$ = (char*)malloc((strlen($1) + strlen($2) + 10) * sizeof(char));
        sprintf($$, "%s%s", $1, $2);
    }
    ;
direct_abstract_declarator: '(' abstract_declarator ')' {
        $$ = (char*)malloc((strlen($2) + 10) * sizeof(char));
        sprintf($$, "(%s)", $2);
    }
    | '[' ']' {
        $$ = (char*)malloc((10) * sizeof(char));
        sprintf($$, "%s", "[]");
    }
    | '[' expression ']' {
        $$ = (char*)malloc((strlen($2) + 10) * sizeof(char));
        sprintf($$, "[%s]", $2);
    }
    | direct_abstract_declarator '[' ']' {
        $$ = (char*)malloc((strlen($1) + 10) * sizeof(char));
        sprintf($$, "%s[]", $1);
    }
    | direct_abstract_declarator '[' expression ']' {
        $$ = (char*)malloc((strlen($1) + strlen($3) + 10) * sizeof(char));
        sprintf($$, "%s[%s]", $1, $3);
    }
    | '(' ')' {
        $$ = (char*)malloc((10) * sizeof(char));
        sprintf($$, "%s", "()");
    }
    | '(' parameter_list ')' {
        $$ = (char*)malloc((strlen($2) + 10) * sizeof(char));
        sprintf($$, "[%s]", $2);
    }
    | direct_abstract_declarator '(' ')' {
        $$ = (char*)malloc((strlen($1) + 10) * sizeof(char));
        sprintf($$, "%s()", $1);
    }
    | direct_abstract_declarator '(' parameter_list ')' {
        $$ = (char*)malloc((strlen($1) + strlen($3) + 10) * sizeof(char));
        sprintf($$, "%s(%s)", $1, $3);
    }
    ;
/* additional events end */

%%

int main(){
    fp = fopen("codegen.S", "w+");

    /* install_symbol("digitalWrite");
    install_symbol("delay"); */

    yyparse();
    fclose(fp);

    printf("\n");
    printf("symbol_table \tname\tscope\ttype\tvalue\ttotal_args\n");
    for(int i = 0; i < cur_counter; i++){
        printf("symbol table[%d]: %s\t%d\t%d\t%d\t%d\n", i, symbol_table[i].name,
        symbol_table[i].scope, symbol_table[i].type, symbol_table[i].value, 
        symbol_table[i].total_args);

    }
    return 0;
}
int yyerror(char *s){
    fprintf(stderr, "%s\n", s);
    return 0;
}
int yywrap(){
     return 1;
}
char *copy(char *s, int i){
    char *tmp = (char*)malloc((strlen(s) + i) * sizeof(char));
    strcpy(tmp, s);
    return tmp;
}
char *install_symbol(char *s){
    if(cur_counter >= MAX_TABLE_SIZE){
        perror("Symbol Table Full\n");
        return 0;
    }
    else {
        printf("install symbol: %s\n", s);
        symbol_table[cur_counter].scope = cur_scope;
        symbol_table[cur_counter].name = copy(s, 1);
        cur_counter++;
    }
    return s;
}

void set_scope_and_offset(char *name){
    int i, j, index;
    int total_args;
    index = look_up_symbols(name);
    if(index < 0){
        perror("Symbol Table does not have this symbol!\n");
        return;
    }
    else {
        if(symbol_table[index].type == T_FUNC){
            total_args = (cur_counter - 1) - index;
            symbol_table[index].total_args = total_args;
            for(j = total_args, i = cur_counter - 1; i > index; i--, j--){
                symbol_table[i].scope = cur_scope;
                symbol_table[i].offset = j;
            }
        }
        return;
    }
}
char *install_symbol_FUNC(int scope, char *name){
    if(cur_counter >= MAX_TABLE_SIZE){
        perror("Symbol Table Full\n");
        return 0;
    }
    else {
        printf("install FUNC symbol:%s\n", name);
        symbol_table[cur_counter].scope = scope;
        symbol_table[cur_counter].name = copy(name, 3);
        symbol_table[cur_counter].variant = FUNCTION;
        symbol_table[cur_counter].type = T_FUNC;
        cur_counter++;
    }
    printf("FUNC install complete!\n");
    return name;
}
char *install_symbol_INTVAR(int scope, char *name){
    if(cur_counter >= MAX_TABLE_SIZE){
        perror("Symbol Table Full\n");
        return 0;
    }
    else {
        printf("install INT_VAR symbol:%s\n", name);
        symbol_table[cur_counter].scope = scope;
        symbol_table[cur_counter].name = copy(name, 3);
        symbol_table[cur_counter].variant = VARIABLE;
        symbol_table[cur_counter].type = T_INT;
        /* symbol_table[cur_counter].value = var_value; */
        cur_counter++;
    }
    printf("INT_VAR install complete!\n");
    return name;
}
char *install_symbol_INTARG(int scope, char *name){
    if(cur_counter >= MAX_TABLE_SIZE){
        perror("Symbol Table Full\n");
        return 0;
    }
    else {
        printf("install INT_ARG symbol:%s\n", name);
        symbol_table[cur_counter].scope = scope;
        symbol_table[cur_counter].name = copy(name, 3);
        symbol_table[cur_counter].variant = ARGUMENT;
        symbol_table[cur_counter].type = T_INT;
        /* symbol_table[cur_counter].value = arg_value; */
        cur_counter++;
    }
    printf("INT_ARG install complete!\n");
    return name;
}
int look_up_symbols(char *s){
    int i;
    if(cur_counter == 0)return -1;
    for (i = cur_counter - 1; i >= 0; i--){
        if(!strcmp(s, symbol_table[i].name)){
            return i;
        }
    }
    return -1;
}
void pop_up_symbol(int scope){
    int i;
    if(cur_counter == 0)return;
    for(i = cur_counter - 1; i >= 0; i--){
        if(symbol_table[i].scope != scope)break;
    }
    cur_counter = i + 1;
}
//A part: enter function body
void code_gen_func_header(char *functor){
    fprintf(fp, "%s:\n", functor);
    fprintf(fp, "  addi sp, sp, -52\n");
    fprintf(fp, "  sw sp, 48(sp)\n");
    fprintf(fp, "  sw s0, 44(sp)\n");
    fprintf(fp, "  sw s1, 44(sp)\n");
    fprintf(fp, "  sw s2, 40(sp)\n");
    fprintf(fp, "  sw s3, 36(sp)\n");
    fprintf(fp, "  sw s4, 32(sp)\n");
    fprintf(fp, "  sw s5, 28(sp)\n");
    fprintf(fp, "  sw s6, 24(sp)\n");
    fprintf(fp, "  sw s7, 16(sp)\n");
    fprintf(fp, "  sw s8, 12(sp)\n");
    fprintf(fp, "  sw s9,  8(sp)\n");
    fprintf(fp, "  sw s10, 4(sp)\n");
    fprintf(fp, "  sw s11, 0(sp)\n");
    fprintf(fp, "  addi s0, sp, 52\n\n");
}
//B part: exit function body
void code_gen_at_end_of_function_body(char *functor){
    fprintf(fp, "  lw sp, 48(sp)\n");
    fprintf(fp, "  lw s0, 44(sp)\n");
    fprintf(fp, "  lw s1, 44(sp)\n");
    fprintf(fp, "  lw s2, 40(sp)\n");
    fprintf(fp, "  lw s3, 36(sp)\n");
    fprintf(fp, "  lw s4, 32(sp)\n");
    fprintf(fp, "  lw s5, 28(sp)\n");
    fprintf(fp, "  lw s6, 24(sp)\n");
    fprintf(fp, "  lw s7, 16(sp)\n");
    fprintf(fp, "  lw s8, 12(sp)\n");
    fprintf(fp, "  lw s9,  8(sp)\n");
    fprintf(fp, "  lw s10, 4(sp)\n");
    fprintf(fp, "  lw s11, 0(sp)\n");
    fprintf(fp, "  addi sp, sp, 52\n");
    fprintf(fp, "  jalr zero, 0(ra)\n\n");
}
//C part: function invocation
void func_invocation(char *callee){
    int idx = look_up_symbols(callee);
    fprintf(fp, "  addi sp, sp, -4\n");
    fprintf(fp, "  sw ra, 0(sp)\n");
    
    int total_args = symbol_table[idx].total_args;
    for(int i = 0; i < total_args; i++){
        fprintf(fp, "  li a%d, %d\n", i, 
        symbol_table[idx + (i + 1)].value);
    }
    fprintf(fp, "  jal ra, %s\n", callee);
}
//D part: return to caller
void func_return(){
    /* fprintf(fp, "  sw a0, -40(s0)\n"); */
    fprintf(fp, "  lw ra, 0(sp)\n");
    fprintf(fp, "  addi sp, sp, 4\n\n");
}