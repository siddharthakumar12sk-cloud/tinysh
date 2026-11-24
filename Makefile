CC      ?= gcc
CFLAGS  ?= -std=c11 -Wall -Wextra -Wpedantic -O2 -g
SRC     := src/main.c src/lexer.c src/parser.c src/exec.c

tinysh: $(SRC) src/shell.h
	$(CC) $(CFLAGS) -o $@ $(SRC)

test: tinysh
	@bash tests/run_tests.sh

clean:
	rm -f tinysh

.PHONY: test clean
