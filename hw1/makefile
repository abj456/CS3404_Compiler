FLEX = flex
.L = scanner.l

CC = gcc
FILE = lex.yy.c
CFLAGS = -lfl
OUT_EXE = scanner

all: build

flex_build: 
	$(FLEX) $(.L)
build: flex_build
	$(CC) $(FILE) $(CFLAGS) -o $(OUT_EXE)
clean:
	rm -f *.yy.c scanner
