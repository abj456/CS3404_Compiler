%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <ctype.h>
    #define MAX_TABLE_SIZE 5000
    #define HIGH 1
    #define LOW 0
    #define LEFT 0
    #define RIGHT 1

    typedef enum variant_symbol Variant;
    enum variant_symbol{VARIABLE, FUNCTION, ARRAY,
        FUNCTION_DEF, ARGUMENT};
    typedef enum symb_type T_Type;
    enum symb_type{T_INT, T_CHAR, T_FUNC, T_PINT, T_CHAR4};

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
        // int total_locals;
        int mode;     //global || parameter || local variable
    } symbol_table[MAX_TABLE_SIZE];

    typedef struct dataType *PTR_SYMB;

    int cur_counter = 0;
    int cur_scope = 0;
    int cur_label = 0;
    int assign_LR_flag = LEFT;
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
%token<type> CONST SIGNED UNSIGNED SHORT LONG VOID INT CHAR FLOAT DOUBLE CHAR4
%token<stmt> IF ELSE SWITCH CASE DEFAULT DO WHILE FOR RETURN BREAK CONTINUE


%type<op> pointer unary_op
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
%type<expr> unary_expression unary_op_list
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
program: external_declaration {
        printf("%s", $1); 
        free($1);
    }
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
        
        if(strcmp($1, "char4") == 0){
            printf("%s %s\n", $1, $2);
            char *var = strtok($2, "=");
            int idx = look_up_symbols(var);
            symbol_table[idx].type = T_CHAR4;
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
        // printf("here\n");
        
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
    | FOR '(' {
        fprintf(fp, "//FOR LOOP 1st EXPR START\n");
        fprintf(fp, "_%d_FOR_1st_EXPR:\n", cur_label);
    } expression_in_for ';' {
        fprintf(fp, "//FOR LOOP 1st EXPR END\n");

        fprintf(fp, "//FOR LOOP 2nd EXPR START\n");
        fprintf(fp, "_%d_FOR_2nd_EXPR:\n", cur_label);
        fprintf(fp, "//label: %d\n", cur_label);
    } expression_in_for ';' {
        char *relop_str = strpbrk($7, "<>");
        if(relop_str[0] == '<'){
            if(relop_str[1] != '='){//<
                fprintf(fp, "  ld t2, 0(sp)\n");
                fprintf(fp, "  addi sp, sp, 8\n");
                fprintf(fp, "  ld t1, 0(sp)\n");
                fprintf(fp, "  addi sp, sp, 8\n");
                // fprintf(fp, "  slt t0, t1, t2\n");
                fprintf(fp, "  blt t1, t2, _%d_FOR_LOOP_STMT\n", cur_label);
                // fprintf(fp, "  beq t1, t2, _%d_end\n", cur_label);
            }
            else {//(t1 <= t2) 
                fprintf(fp, "  ld t2, 0(sp)\n");
                fprintf(fp, "  addi sp, sp, 8\n");
                fprintf(fp, "  ld t1, 0(sp)\n");
                fprintf(fp, "  addi sp, sp, 8\n");
                fprintf(fp, "  bge t2, t1, _%d_FOR_LOOP_STMT\n", cur_label);
            }
        }
        else if(relop_str[0] == '>'){
            if(relop_str[1] != '='){//(t1 > t2)
                fprintf(fp, "  ld t2, 0(sp)\n");
                fprintf(fp, "  addi sp, sp, 8\n");
                fprintf(fp, "  ld t1, 0(sp)\n");
                fprintf(fp, "  addi sp, sp, 8\n");
                fprintf(fp, "  blt t2, t1, _%d_FOR_LOOP_STMT\n", cur_label);
            }
            else {//>=
                fprintf(fp, "  ld t2, 0(sp)\n");
                fprintf(fp, "  addi sp, sp, 8\n");
                fprintf(fp, "  ld t1, 0(sp)\n");
                fprintf(fp, "  addi sp, sp, 8\n");
                fprintf(fp, "  bge t1, t2, _%d_FOR_LOOP_STMT\n", cur_label);
            }
        }
        fprintf(fp, "  jal x0, _%d_end\n", cur_label);
        fprintf(fp, "//FOR LOOP 2nd EXPR END\n");

        fprintf(fp, "//FOR LOOP 3rd EXPR\n");
        fprintf(fp, "_%d_FOR_3rd_EXPR:\n", cur_label);
    } expression_in_for ')' {
        // fprintf(fp, "//for(%s;%s;%s)\n", $4, $7, $10);
        fprintf(fp, "  jal x0, _%d_FOR_2nd_EXPR\n", cur_label);
        fprintf(fp, "//FOR LOOP 3rd EXPR END\n");

        // cur_scope++;
        code_gen_stmt_header();

        fprintf(fp, "//FOR LOOP STMT START\n");
        fprintf(fp, "_%d_FOR_LOOP_STMT:\n", cur_label);
    } stmt { // 3 expr in for
        int stmt_len = strlen($1) + strlen($4) + strlen($7) + strlen($10) + strlen($13);
        $$ = (char *)malloc((stmt_len + 40) * sizeof(char));
        if($13[0] == '{'){
            sprintf($$, "<stmt>%s(%s;%s;%s)<stmt>%s</stmt></stmt>", $1, $4, $7, $10, $13);
        }
        else {
            sprintf($$, "<stmt>%s(%s;%s;%s)%s</stmt>", $1, $4, $7, $10, $13);
        }
        fprintf(fp, "  jal x0, _%d_FOR_3rd_EXPR\n", cur_label);
        fprintf(fp, "//FOR LOOP STMT END\n");

        // cur_scope--;
        code_gen_at_end_of_stmt_body();
        fprintf(fp, "//FOR LOOP END\n");
        fprintf(fp, "_%d_end:\n", cur_label);
        cur_label++;
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
    | CHAR4 {sprintf($$, "%s", $1);}
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

        char *var = strtok($1, "*");
        int idx = look_up_symbols(var);
        for(int i = idx; i >= 0; i--){
            if(symbol_table[i].scope == (cur_scope - 1)){
                symbol_table[idx].offset = idx - i;
                break;
            }
        }
    }
    | declarator '=' initializer {
        $$ = (char*)malloc((strlen($1) + strlen($3) + 2) * sizeof(char));
        sprintf($$, "%s=%s", $1, $3);
        
        
        int local_value = atoi($3);
        int idx = cur_counter - 1;
        // symbol_table[idx].value = local_value;
        // set_local_vars($1);
        for(int i = idx; i >= 0; i--){
            if(symbol_table[i].scope == (cur_scope - 1)){
                symbol_table[idx].offset = idx - i;
                break;
            }
        }

        if(symbol_table[idx].type == T_INT){
            fprintf(fp, "//variable assignment\n");
            fprintf(fp, "  ld t0, 0(sp)\n");
            fprintf(fp, "  addi sp, sp, 8\n");
            // fprintf(fp, "  sd t0, %d(fp)\n", symbol_table[idx].offset*8*(-1)-104);
            fprintf(fp, "  addi sp, sp, -8\n");
            fprintf(fp, "  sd t0, 0(sp)\n");
            // fprintf(fp, "  sd t0, 0(sp)\n");
            fprintf(fp, "\n");
        }
        else if(symbol_table[idx].type == T_PINT){
            fprintf(fp, "//pointer variable assignment\n");
            fprintf(fp, "  ld t0, 0(sp)\n");
            fprintf(fp, "  addi sp, sp, 8\n");
            // fprintf(fp, "  sd t0, %d(fp)\n", symbol_table[idx].offset*8*(-1)-104);
            fprintf(fp, "  addi sp, sp, -8\n");
            fprintf(fp, "  sd t0, 0(sp)\n");
            // fprintf(fp, "  sd t0, 0(sp)\n");
            fprintf(fp, "\n");
        }
    }
    ;
declarator: direct_declarator {
        $$ = (char*)malloc((strlen($1) + 1)* sizeof(char));
        sprintf($$, "%s", $1);
    }
    ;
direct_declarator: IDENT {
        decl_flag = 0;
        $$ = (char*)malloc((strlen($1) + 1)* sizeof(char));
        sprintf($$, "%s", $1); 
        install_symbol_INTVAR(cur_scope, $1);

        int idx = look_up_symbols($1);
        if(symbol_table[idx].type == T_INT && symbol_table[idx].variant == VARIABLE){
            fprintf(fp, "//VARIABLE DECLARATION\n");
            fprintf(fp, "  add t0, x0, x0\n");
            // fprintf(fp, "  sd t0, %d(fp)\n", symbol_table[idx].offset*8*(-1)-104);
            fprintf(fp, "  addi sp, sp, -8\n");
            fprintf(fp, "  sd t0, 0(sp)\n");
            fprintf(fp, "\n");
        }
    }
    | pointer IDENT {
        $$ = (char*)malloc((strlen($1) + strlen($2) + 1) * sizeof(char));
        sprintf($$, "%s%s", $1, $2);
        install_symbol_POINTER_INTVAR(cur_scope, $2);
    }
    | IDENT '[' expression ']'{
        decl_flag = 1;
        $$ = (char*)malloc((strlen($1) + strlen($3) + 3) * sizeof(char));
        sprintf($$, "%s[%s]", $1, $3);

        int arr_len = atoi($3);
        install_symbol_ARRAYVAR(cur_scope, $1, arr_len);

        int idx = look_up_symbols($1) - arr_len + 1;
        printf("array len = %d\n", arr_len);
        fprintf(fp, "//ARRAY DECLARATION\n");
        for(int i = 0; i < arr_len; i++){
            fprintf(fp, "  li t0, 0\n");
            fprintf(fp, "  sd t0, %d(fp)\n", symbol_table[idx + i].offset*8*(-1)-104-(cur_scope-1)*1000);
            fprintf(fp, "  addi sp, sp, -8\n");
        }
    }
    | IDENT '[' ']'{
        decl_flag = 1;
        $$ = (char*)malloc((strlen($1) + 3) * sizeof(char));
        sprintf($$, "%s[]", $1);
    }
    | '(' declarator ')'{
        $$ = (char*)malloc((strlen($2) + 3) * sizeof(char));
        sprintf($$, "(%s)", $2);
    }
    | IDENT '(' parameter_list ')'{
        decl_flag = 2;
        $$ = (char*)malloc((strlen($1) + strlen($3) + 3) * sizeof(char));
        sprintf($$, "%s(%s)", $1, $3);

        // printf("func_name:%s\n", $1);
    }
    | IDENT '(' identifier_list ')'{
        decl_flag = 2;
        $$ = (char*)malloc((strlen($1) + strlen($3) + 3) * sizeof(char));
        sprintf($$, "%s(%s)", $1, $3);

        // printf("func_name:%s\n", $1);
    }
    | IDENT '(' ')'{
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
    | cast_expression '=' {assign_LR_flag = RIGHT;} assignment_expression{
        $$ = (char*)malloc((strlen($1) + strlen($4) + 20) * sizeof(char));
        sprintf($$, "<expr>%s=%s</expr>", $1, $4);

        fprintf(fp, "//ASSIGNMENT IN EXPR: L is %s, R is %s\n", $1, $4);

        char *var = strtok($1, "*[");
        int idx = look_up_symbols(var);
        if(symbol_table[idx].type == T_PINT){
            if ($1[0] == '*'){
                fprintf(fp, "//DEREFERENCE POINTER L: %s\n", $1);
                fprintf(fp, "  ld t0, 0(sp)\n");
                fprintf(fp, "  addi sp, sp, 8\n");
                fprintf(fp, "  ld t1, %d(fp)\n", symbol_table[idx].offset*8*(-1)-104-(cur_scope-1)*1000);//fetch address in *b
            
                fprintf(fp, "  sd t0, 0(t1)\n");
                fprintf(fp, "  sd t0, 0(sp)\n\n");
            }
            else {
                fprintf(fp, "//POINTER ASSIGNMENT\n");
                fprintf(fp, "  ld t0, 0(sp)\n");
                fprintf(fp, "  addi sp, sp, 8\n");
                fprintf(fp, "  sd t0, %d(fp)\n", symbol_table[idx].offset*8*(-1)-104-(cur_scope-1)*1000);
            }
            
        }
        else if(symbol_table[idx].type == T_INT){
            printf("%s\n", var);
            printf("symbol_table[%d].variant = %d\n", idx, symbol_table[idx].variant);
            if(symbol_table[idx].variant == ARRAY){
                char *index = strtok(NULL, "]");
                int base = idx;
                while(strcmp(symbol_table[base].name, var) == 0){
                    base--;
                }base++;

                fprintf(fp, "//ARRAY BASE INDEX = %d\n", base);
                fprintf(fp, "//ARRAY ASSIGNMENT EXPR: %s\n", $1);
                fprintf(fp, "  ld t1, 0(sp)\n");//array[i] = 'i';
                fprintf(fp, "  addi sp, sp, 8\n");
                fprintf(fp, "  ld t2, 0(sp)\n");//array['i'] = i;
                fprintf(fp, "  addi sp, sp, 8\n");

                fprintf(fp, "  addi t3, x0, -8\n");
                fprintf(fp, "  mul t2, t2, t3\n");
                
                fprintf(fp, "  addi t0, fp, %d\n", symbol_table[base].offset*8*(-1)-104-(cur_scope-1)*1000);
                fprintf(fp, "  add t0, t0, t2\n");//i + array[0];
                fprintf(fp, "  sd t1, 0(t0)\n");
                fprintf(fp, "\n");
            }
            else {
                fprintf(fp, "//NORMAL ASSIGNMENT EXPR: %s\n", $1);
                fprintf(fp, "  ld t0, 0(sp)\n");
                fprintf(fp, "  addi sp, sp, 8\n");
                fprintf(fp, "  sd t0, %d(fp)\n", symbol_table[idx].offset*8*(-1)-104-(cur_scope-1)*1000);
                fprintf(fp, "\n");
            }
        }
        assign_LR_flag = LEFT;
    }
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
        sprintf($$, "%s<%s", $1, $3);
    }
    | relational_expression '>' shift_expression {
        $$ = (char*)malloc((strlen($1) + strlen($3) + 20) * sizeof(char));
        sprintf($$, "%s>%s", $1, $3);
    }
    | relational_expression LESS_OR_EQUAL shift_expression {
        $$ = (char*)malloc((strlen($1) + strlen($3) + 20) * sizeof(char));
        sprintf($$, "%s<=%s", $1, $3);
    }
    | relational_expression GREATER_OR_EQUAL shift_expression {
        $$ = (char*)malloc((strlen($1) + strlen($3) + 20) * sizeof(char));
        sprintf($$, "%s>=%s", $1, $3);
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
        sprintf($$, "%s+%s", $1, $3);
        int idx1 = look_up_symbols($1);
        int idx2 = look_up_symbols($3);
        if(idx1 != -1 && idx2 != -1){
            if(symbol_table[idx1].type == T_CHAR4 && symbol_table[idx2].type == T_CHAR4){
                fprintf(fp, "//CHAR4 ADD\n");
                fprintf(fp, "  ld t1, 0(sp)\n");
                fprintf(fp, "  addi sp, sp, 8\n");
                fprintf(fp, "  ld t0, 0(sp)\n");
                fprintf(fp, "  addi sp, sp, 8\n");
                fprintf(fp, "  KADD8 t0, t0, t1\n");
                fprintf(fp, "  addi sp, sp, -8\n");
                fprintf(fp, "  sd t0, 0(sp)\n");
            }
            else if(symbol_table[idx1].variant == ARRAY && symbol_table[idx2].variant != ARRAY){
                fprintf(fp, "//ARRAY ADDRESS CALCULATION\n");
                fprintf(fp, "  ld t1, 0(sp)\n");
                fprintf(fp, "  addi sp, sp, 8\n");
                fprintf(fp, "  ld t0, 0(sp)\n");
                fprintf(fp, "  addi sp, sp, 8\n");
                fprintf(fp, "  addi t2, x0, -8\n");
                fprintf(fp, "  mul t1, t1, t2\n");

                fprintf(fp, "   t0, t0, t1\n");
                fprintf(fp, "  addi sp, sp, -8\n");
                fprintf(fp, "  sd t0, 0(sp)\n");
            }
            else {
                fprintf(fp, "//ADD BETWEEN VARS\n");
                fprintf(fp, "  ld t1, 0(sp)\n");
                fprintf(fp, "  addi sp, sp, 8\n");
                fprintf(fp, "  ld t0, 0(sp)\n");
                fprintf(fp, "  addi sp, sp, 8\n");
                fprintf(fp, "  add t0, t0, t1\n");
                fprintf(fp, "  addi sp, sp, -8\n");
                fprintf(fp, "  sd t0, 0(sp)\n");
            }
        }
        else {
            fprintf(fp, "//ADD\n");
            fprintf(fp, "  ld t1, 0(sp)\n");
            fprintf(fp, "  addi sp, sp, 8\n");
            fprintf(fp, "  ld t0, 0(sp)\n");
            fprintf(fp, "  addi sp, sp, 8\n");
            fprintf(fp, "  add t0, t0, t1\n");
            fprintf(fp, "  addi sp, sp, -8\n");
            fprintf(fp, "  sd t0, 0(sp)\n");
        }
        
    }
    | additive_expression '-' multiplicative_expression {
        $$ = (char*)malloc((strlen($1) + strlen($3) + 20) * sizeof(char));
        sprintf($$, "%s-%s", $1, $3);

        fprintf(fp, "//SUB\n");
        fprintf(fp, "  ld t1, 0(sp)\n");
        fprintf(fp, "  addi sp, sp, 8\n");
        fprintf(fp, "  ld t0, 0(sp)\n");
        fprintf(fp, "  addi sp, sp, 8\n");
        fprintf(fp, "  sub t0, t0, t1\n");
        fprintf(fp, "  addi sp, sp, -8\n");
        fprintf(fp, "  sd t0, 0(sp)\n");
    }
    ;
multiplicative_expression: cast_expression {
        $$ = (char*)malloc((strlen($1) + 1)* sizeof(char));
        sprintf($$, "%s", $1);

        char *var = strtok($1, "*[");
        int idx = look_up_symbols(var);
        if(idx != -1 && (symbol_table[idx].type == T_INT || symbol_table[idx].type == T_CHAR4)
        && symbol_table[idx].variant == VARIABLE){
            // sprintf($$, "%d", symbol_table[idx].value);
            fprintf(fp, "//FETCH VALUE FROM VAR: %s\n", $1);
            fprintf(fp, "  ld t0, %d(fp)\n", symbol_table[idx].offset*8*(-1)-104-(cur_scope-1)*1000);
            fprintf(fp, "  addi sp, sp, -8\n");
            fprintf(fp, "  sd t0, 0(sp)\n");
        }
        else if(idx != -1 && symbol_table[idx].type == T_INT
        && symbol_table[idx].variant == ARRAY){
            char *target = strtok(NULL, "]");
            if(target != NULL){
                int base = idx;
                while(strcmp(symbol_table[base].name, var) == 0){
                    base--;
                }base++;
            
                fprintf(fp, "//symbol table base of %s is %d\n", var, base);
                fprintf(fp, "//FETCH VALUE FROM ARRAY VAR: %s[%s]\n", var, target);
                fprintf(fp, "  ld t1, 0(sp)\n");
                fprintf(fp, "  addi sp, sp, 8\n");
                fprintf(fp, "  addi t2, x0, -8\n");
                fprintf(fp, "  mul t1, t1, t2\n");
                fprintf(fp, "  addi t1, t1, %d\n", symbol_table[base].offset*8*(-1)-104-(cur_scope-1)*1000);
                fprintf(fp, "  add t1, fp, t1\n");
                fprintf(fp, "  ld t0, 0(t1)\n");
            
                fprintf(fp, "  addi sp, sp, -8\n");
                fprintf(fp, "  sd t0, 0(sp)\n");
            }
            else {
                int base = idx;
                while(strcmp(symbol_table[base].name, var) == 0){
                    base--;
                }base++;

                fprintf(fp, "//FETCH ARRAY BASE ADDRESS\n");
                fprintf(fp, "  addi t0, fp, %d\n", symbol_table[base].offset*8*(-1)-104-(cur_scope-1)*1000);

                fprintf(fp, "  addi sp, sp, -8\n");
                fprintf(fp, "  sd t0, 0(sp)\n");
            }    
        }
        else if(strcmp($1, "HIGH") == 0){
            // printf("%s\n", $1);
            fprintf(fp, "//TRANSFORM HIGH TO 1\n");
            fprintf(fp, "  li t0, 1\n");
            fprintf(fp, "  addi sp, sp, -8\n");
            fprintf(fp, "  sd t0, 0(sp)\n");
        }
        else if(strcmp($1, "LOW") == 0){
            fprintf(fp, "//TRANSFORM LOW TO 0\n");
            fprintf(fp, "  li t0, 0\n");
            fprintf(fp, "  addi sp, sp, -8\n");
            fprintf(fp, "  sd t0, 0(sp)\n");
        }
    }
    | multiplicative_expression '*' multiplicative_expression {
        $$ = (char*)malloc((strlen($1) + strlen($3) + 20) * sizeof(char));
        sprintf($$, "%s*%s", $1, $3);

        fprintf(fp, "//MUL\n");
        fprintf(fp, "  ld t1, 0(sp)\n");
        fprintf(fp, "  addi sp, sp, 8\n");
        fprintf(fp, "  ld t0, 0(sp)\n");
        fprintf(fp, "  addi sp, sp, 8\n");
        fprintf(fp, "  mul t0, t0, t1\n");
        fprintf(fp, "  addi sp, sp, -8\n");
        fprintf(fp, "  sd t0, 0(sp)\n");
    }
    | multiplicative_expression '/' multiplicative_expression {
        $$ = (char*)malloc((strlen($1) + strlen($3) + 20) * sizeof(char));
        sprintf($$, "%s/%s", $1, $3);

        fprintf(fp, "//DIV\n");
        fprintf(fp, "  ld t1, 0(sp)\n");
        fprintf(fp, "  addi sp, sp, 8\n");
        fprintf(fp, "  ld t0, 0(sp)\n");
        fprintf(fp, "  addi sp, sp, 8\n");
        fprintf(fp, "  div t0, t0, t1\n");
        fprintf(fp, "  addi sp, sp, -8\n");
        fprintf(fp, "  sd t0, 0(sp)\n");
    }
    | multiplicative_expression '%' cast_expression {
        $$ = (char*)malloc((strlen($1) + strlen($3) + 20) * sizeof(char));
        // sprintf($$, "%s%%%s", $1, $3);
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
    | unary_op_list postfix_expression {
        $$ = (char*)malloc((strlen($1) + strlen($2) + 20) * sizeof(char));
        sprintf($$, "%s%s", $1, $2);
        
        int idx = look_up_symbols($2);
        if (idx != -1 && symbol_table[idx].type == T_INT){
            if(strcmp($1, "&") == 0){
                printf("pointer address: %s\n", $2);
                fprintf(fp, "//ASSIGN ADDRESS TO POINTER\n");
                fprintf(fp, "  addi t0, fp, %d\n", symbol_table[idx].offset*8*(-1)-104-(cur_scope-1)*1000);
                fprintf(fp, "  addi sp, sp, -8\n");
                fprintf(fp, "  sd t0, 0(sp)\n");
            }
            else if(strcmp($1, "-") == 0){
                fprintf(fp, "//UNARY OP: %s%s\n", "-", $2);
                fprintf(fp, "  ld t0, %d(fp)\n", symbol_table[idx].offset*8*(-1)-104-(cur_scope-1)*1000);
                fprintf(fp, "  sub t0, zero, t0\n");

                fprintf(fp, "  addi sp, sp, -8\n");
                fprintf(fp, "  sd t0, 0(sp)\n");
            }
        }
        else if(idx != 1 && symbol_table[idx].type == T_PINT){
            if(strcmp($1, "*") == 0 && assign_LR_flag){
                fprintf(fp, "//assign_LR_flag = %d\n", assign_LR_flag);
                fprintf(fp, "//DEREFERENCE POINTER R:%s%s\n", $1, $2);
                fprintf(fp, "  ld t2, %d(fp)\n", symbol_table[idx].offset*8*(-1)-104-(cur_scope-1)*1000);
                fprintf(fp, "  ld t1, 0(t2)\n");
                fprintf(fp, "  addi sp, sp, -8\n");
                fprintf(fp, "  sd t1, 0(sp)\n");
            }
        }
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

        // int num_of_arg = 0;
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
                // else {
                    // symbol_table[idx].value = atoi(arg_name);
                // }
            }
            arg_name = strtok(NULL, ",");
        }
        int idx = look_up_symbols($1);
        int func_total_args = (cur_counter - 1) - idx;
        symbol_table[idx].total_args = func_total_args;
        // printf("%s.total_args = %d\n", $1, symbol_table[idx].total_args);

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

        //TO DEFINE THE ARGUMENT ASS END
        fprintf(fp, "//ARGUMENT\n");
    }
primary_expression: IDENT {
        $$ = (char*)malloc((strlen($1) + 20) * sizeof(char));
        sprintf($$, "%s", $1);
        // printf("IDENT: %s\n", $1);
    }
    | IDENT '[' expression ']' {
        $$ = (char*)malloc((strlen($1) + strlen($3) + 20) * sizeof(char));
        sprintf($$, "%s[%s]", $1, $3);
    }
    | INTEGER {
        $$ = (char*)malloc((20) * sizeof(char) + sizeof(int));
        sprintf($$, "%d", $1);
        
        fprintf(fp, "//INTEGER\n");
        fprintf(fp, "  li t0, %d\n", $1);
        fprintf(fp, "  addi sp, sp, -8\n");
        fprintf(fp, "  sd t0, 0(sp)\n");
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
unary_op_list: unary_op_list unary_op{
        $$ = (char*)malloc((strlen($1)+strlen($2)+5)*sizeof(char));
        sprintf($$, "%s%s", $1, $2);
    }
    | unary_op {
        $$ = (char*)malloc((strlen($1)+5)*sizeof(char));
        sprintf($$, "%s", $1);
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
    printf("symbol_table \tname\tscope\ttype\tVariant\targ_num\toffset\n");
    for(int i = 0; i < cur_counter; i++){
        printf("symbol table[%d]: %s\t%d\t%d\t%d\t%d\t%d\n", i, symbol_table[i].name,
        symbol_table[i].scope, symbol_table[i].type, symbol_table[i].variant, 
        symbol_table[i].total_args, symbol_table[i].offset);
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
    }
}
void set_local_vars(char *var){
    int i, j, idx;
    /* f_idx = look_up_symbols(functor); */
    idx = look_up_symbols(var);
    if(idx < 0){
        perror("Error when setting local vars\n");
    }
    else {
        if(symbol_table[idx].scope == (cur_scope - 1)){
            symbol_table[idx].offset = idx - i;
        }
    }
}
char *install_symbol_FUNC(int scope, char *name){
    if(cur_counter >= MAX_TABLE_SIZE){
        perror("Symbol Table Full\n");
        return 0;
    }
    else {
        /* printf("install FUNC symbol:%s\n", name); */
        symbol_table[cur_counter].scope = scope;
        symbol_table[cur_counter].name = copy(name, 3);
        symbol_table[cur_counter].variant = FUNCTION;
        symbol_table[cur_counter].type = T_FUNC;
        /* symbol_table[cur_counter].total_locals = 0; */
        cur_counter++;
    }
    /* printf("FUNC install complete!\n"); */
    return name;
}
char *install_symbol_ARRAYVAR(int scope, char *name, int arr_len){
    if(cur_counter >= MAX_TABLE_SIZE){
        perror("Symbol Table Full\n");
        return 0;
    }
    else {
        /* printf("install FUNC symbol:%s\n", name); */
        if(symbol_table[cur_counter-1].scope == scope){
            int base = symbol_table[cur_counter-1].offset;
            for(int i = 0; i < arr_len; i++){
                symbol_table[cur_counter].scope = scope;
                symbol_table[cur_counter].name = copy(name, 3);
                symbol_table[cur_counter].variant = ARRAY;
                symbol_table[cur_counter].type = T_INT;
                symbol_table[cur_counter].offset = i + 1 + base;
                /* printf("array.offset = %d\n", i); */
                cur_counter++;
            }
        }
        else {
            for(int i = 0; i < arr_len; i++){
                symbol_table[cur_counter].scope = scope;
                symbol_table[cur_counter].name = copy(name, 3);
                symbol_table[cur_counter].variant = ARRAY;
                symbol_table[cur_counter].type = T_INT;
                symbol_table[cur_counter].offset = i + 1;
                /* printf("array.offset = %d\n", i); */
                cur_counter++;
            }
        }
        
    }
}
char *install_symbol_INTVAR(int scope, char *name){
    if(cur_counter >= MAX_TABLE_SIZE){
        perror("Symbol Table Full\n");
        return 0;
    }
    else {
        /* printf("install INT_VAR symbol:%s\n", name); */
        symbol_table[cur_counter].scope = scope;
        symbol_table[cur_counter].name = copy(name, 3);
        symbol_table[cur_counter].variant = VARIABLE;
        symbol_table[cur_counter].type = T_INT;
        /* symbol_table[cur_counter].value = var_value; */
        cur_counter++;
    }
    /* printf("INT_VAR install complete!\n"); */
    return name;
}
char *install_symbol_POINTER_INTVAR(int scope, char *name){
    if(cur_counter >= MAX_TABLE_SIZE){
        perror("Symbol Table Full\n");
        return 0;
    }
    else {
        printf("install POINTER_INT_VAR symbol:%s\n", name);
        symbol_table[cur_counter].scope = scope;
        symbol_table[cur_counter].name = copy(name, 3);
        symbol_table[cur_counter].variant = VARIABLE;
        symbol_table[cur_counter].type = T_PINT;
        /* symbol_table[cur_counter].value = var_value; */
        cur_counter++;
    }
    printf("POINTER_INT_VAR install complete!\n");
    return name;
}
char *install_symbol_INTARG(int scope, char *name){
    if(cur_counter >= MAX_TABLE_SIZE){
        perror("Symbol Table Full\n");
        return 0;
    }
    else {
        /* printf("install INT_ARG symbol:%s\n", name); */
        symbol_table[cur_counter].scope = scope;
        symbol_table[cur_counter].name = copy(name, 3);
        symbol_table[cur_counter].variant = ARGUMENT;
        symbol_table[cur_counter].type = T_INT;
        /* symbol_table[cur_counter].value = arg_value; */
        cur_counter++;
    }
    /* printf("INT_ARG install complete!\n"); */
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
    fprintf(fp, "//FUNC START\n");
    fprintf(fp, "  addi sp, sp, -104\n");
    fprintf(fp, "  sd sp, 96(sp)\n");
    fprintf(fp, "  sd s0, 88(sp)\n");
    fprintf(fp, "  sd s1, 80(sp)\n");
    fprintf(fp, "  sd s2, 72(sp)\n");
    fprintf(fp, "  sd s3, 64(sp)\n");
    fprintf(fp, "  sd s4, 56(sp)\n");
    fprintf(fp, "  sd s5, 48(sp)\n");
    fprintf(fp, "  sd s6, 40(sp)\n");
    fprintf(fp, "  sd s7, 32(sp)\n");
    fprintf(fp, "  sd s8, 24(sp)\n");
    fprintf(fp, "  sd s9, 16(sp)\n");
    fprintf(fp, "  sd s10, 8(sp)\n");
    fprintf(fp, "  sd s11, 0(sp)\n");
    fprintf(fp, "  addi s0, sp, 104\n\n");
}
//B part: exit function body
void code_gen_at_end_of_function_body(char *functor){
    fprintf(fp, "//FUNC END\n");
    fprintf(fp, "  addi sp, s0, -104\n");
    fprintf(fp, "  ld sp, 96(sp)\n");
    fprintf(fp, "  ld s0, 88(sp)\n");
    fprintf(fp, "  ld s1, 80(sp)\n");
    fprintf(fp, "  ld s2, 72(sp)\n");
    fprintf(fp, "  ld s3, 64(sp)\n");
    fprintf(fp, "  ld s4, 56(sp)\n");
    fprintf(fp, "  ld s5, 48(sp)\n");
    fprintf(fp, "  ld s6, 40(sp)\n");
    fprintf(fp, "  ld s7, 32(sp)\n");
    fprintf(fp, "  ld s8, 24(sp)\n");
    fprintf(fp, "  ld s9, 16(sp)\n");
    fprintf(fp, "  ld s10, 8(sp)\n");
    fprintf(fp, "  ld s11, 0(sp)\n");
    fprintf(fp, "  addi sp, sp, 104\n");
    fprintf(fp, "  jalr zero, 0(ra)\n\n");
}
//C part: function invocation
void func_invocation(char *callee){
    int idx = look_up_symbols(callee);
    fprintf(fp, "\n//FUNCTION INVOCATION\n");
    
    int total_args = symbol_table[idx].total_args;
    for(int i = 0; i < total_args; i++){
        /* fprintf(fp, "  li a%d, %d\n", i, 
        symbol_table[idx + (i + 1)].value); */
        fprintf(fp, "  ld a%d, %d(sp)\n", i, (total_args - 1 - i)*(8));
    }
    fprintf(fp, "  addi sp, sp, -8\n");
    fprintf(fp, "  sd ra, 0(sp)\n");
    fprintf(fp, "  jal ra, %s\n", callee);
}
//D part: return to caller
void func_return(){
    /* fprintf(fp, "  sd a0, -40(s0)\n"); */
    fprintf(fp, "  ld ra, 0(sp)\n");
    fprintf(fp, "  addi sp, sp, 8\n");
    fprintf(fp, "//RETURN TO CALLER\n\n");
}

void code_gen_stmt_header(){
    /* fprintf(fp, "%s:\n", functor);
    fprintf(fp, "//FUNC START\n"); */
    /* fprintf(fp, "  addi sp, sp, %d\n", -104-(cur_scope-1)*1000); */
    /* fprintf(fp, "  sd sp, %d(sp)\n", 96+(cur_scope-1)*1000); */
    /* fprintf(fp, "  sd s0, %d(sp)\n", 88+(cur_scope-1)*1000);
    fprintf(fp, "  sd s1, %d(sp)\n", 80+(cur_scope-1)*1000);
    fprintf(fp, "  sd s2, %d(sp)\n", 72+(cur_scope-1)*1000);
    fprintf(fp, "  sd s3, %d(sp)\n", 64+(cur_scope-1)*1000);
    fprintf(fp, "  sd s4, %d(sp)\n", 56+(cur_scope-1)*1000);
    fprintf(fp, "  sd s5, %d(sp)\n", 48+(cur_scope-1)*1000);
    fprintf(fp, "  sd s6, %d(sp)\n", 40+(cur_scope-1)*1000);
    fprintf(fp, "  sd s7, %d(sp)\n", 32+(cur_scope-1)*1000);
    fprintf(fp, "  sd s8, %d(sp)\n", 24+(cur_scope-1)*1000);
    fprintf(fp, "  sd s9, %d(sp)\n", 16+(cur_scope-1)*1000);
    fprintf(fp, "  sd s10, %d(sp)\n", 8+(cur_scope-1)*1000);
    fprintf(fp, "  sd s11, %d(sp)\n", 0+(cur_scope-1)*1000); */
    /* fprintf(fp, "  addi s0, sp, %d\n\n", 104+(cur_scope-1)*1000); */
}
void code_gen_at_end_of_stmt_body(){
    /* fprintf(fp, "  addi sp, s0, %d\n", -104-(cur_scope-1)*1000);
    fprintf(fp, "  ld sp, %d(sp)\n", 96+(cur_scope-1)*1000);
    fprintf(fp, "  ld s0, %d(sp)\n", 88+(cur_scope-1)*1000);
    fprintf(fp, "  ld s1, %d(sp)\n", 80+(cur_scope-1)*1000);
    fprintf(fp, "  ld s2, %d(sp)\n", 72+(cur_scope-1)*1000);
    fprintf(fp, "  ld s3, %d(sp)\n", 64+(cur_scope-1)*1000);
    fprintf(fp, "  ld s4, %d(sp)\n", 56+(cur_scope-1)*1000);
    fprintf(fp, "  ld s5, %d(sp)\n", 48+(cur_scope-1)*1000);
    fprintf(fp, "  ld s6, %d(sp)\n", 40+(cur_scope-1)*1000);
    fprintf(fp, "  ld s7, %d(sp)\n", 32+(cur_scope-1)*1000);
    fprintf(fp, "  ld s8, %d(sp)\n", 24+(cur_scope-1)*1000);
    fprintf(fp, "  ld s9, %d(sp)\n", 16+(cur_scope-1)*1000);
    fprintf(fp, "  ld s10, %d(sp)\n", 8+(cur_scope-1)*1000);
    fprintf(fp, "  ld s11, %d(sp)\n", 0+(cur_scope-1)*1000); */
    /* fprintf(fp, "  addi sp, sp, %d\n", 104+(cur_scope-1)*1000); */
}