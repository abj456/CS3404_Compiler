#define IDENT 257
#define INTEGER 258
#define FLOATING 259
#define CHARACTER 260
#define STRING 261
#define LEFT_SHIFT 262
#define RIGHT_SHIFT 263
#define LESS_OR_EQUAL 264
#define GREATER_OR_EQUAL 265
#define EQUALS 266
#define NOT_EQUALS 267
#define INC 268
#define DEC 269
#define AND 270
#define OR 271
#define CONST 272
#define SIGNED 273
#define UNSIGNED 274
#define SHORT 275
#define LONG 276
#define VOID 277
#define INT 278
#define CHAR 279
#define FLOAT 280
#define DOUBLE 281
#define IF 282
#define ELSE 283
#define SWITCH 284
#define CASE 285
#define DEFAULT 286
#define DO 287
#define WHILE 288
#define FOR 289
#define RETURN 290
#define BREAK 291
#define CONTINUE 292
#ifdef YYSTYPE
#undef  YYSTYPE_IS_DECLARED
#define YYSTYPE_IS_DECLARED 1
#endif
#ifndef YYSTYPE_IS_DECLARED
#define YYSTYPE_IS_DECLARED 1
typedef union {
    char *program;
    /* char statement[10000];*/
    char *statement;
    /* char declar[5000];*/
    char *declar;
    /* char expr[500];*/
    char *expr;
    /* char ident[100];*/
    char *ident;
    /* char additional[300];*/
    char *additional;

    char *type_list;

    int intVal; 
    char character[5];
    char str[300];
    double floatVal;
    double doubleVal;
    char type[50];
    char stmt[50];
    char op[5];
    char punc[5];
    char macros[20];
} YYSTYPE;
#endif /* !YYSTYPE_IS_DECLARED */
extern YYSTYPE yylval;
