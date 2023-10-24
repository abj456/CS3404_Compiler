FLEX = flex
.L = scanner.l

YACC = byacc
.Y = parser.y

CC = gcc
lex_FILE = lex.yy.c
yacc_FILE = y.tab.c
CFLAGS = -lfl
yacc_output_flag = -v
yacc_debug_flag = -t
OUT_EXE = parser

all: build
flex_build: 
	$(FLEX) $(.L)
yacc_build:
	$(YACC)  -v -d $(.Y)
build: flex_build yacc_build
	$(CC) -o $(OUT_EXE) $(lex_FILE) $(yacc_FILE) $(CFLAGS) 
clean:
	rm -f *.yy.c y.* parser
