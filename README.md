# tinysh

A small Unix shell written in C11 from scratch. It uses raw POSIX system calls (`fork`, `execvp`, `pipe`, `dup2`, `waitpid`) with no external libraries, and is built to show how a real shell works under the hood.

## Features
- Pipelines of up to 16 commands: `cat file | sort | uniq -c | head`
- Redirection: `<`, `>`, `>>`
- Background jobs with `&`, reaped automatically
- Command sequencing with `;`
- Quoting: `'single'`, `"double"`, and `\` escapes
- Variable expansion: `$VAR`, `"$VAR"`, and `$?` (last exit status)
- Builtins: `cd`, `pwd`, `export`, `unset`, `exit`
- `#` comments, proper exit codes (127 not found, 126 not executable, 128+N for signals)
- Ctrl+C kills the foreground job but not the shell

## Build and run
```bash
make          # builds ./tinysh
./tinysh
make test     # runs the 22-case test suite
```

```
tinysh:/home/sid $ export NAME=world
tinysh:/home/sid $ echo "hello $NAME" | tr a-z A-Z > out.txt; cat out.txt
HELLO WORLD
tinysh:/home/sid $ sleep 5 &
[bg] started pid 4121
```

## How it works

```
 input line
     │
     ▼
 lexer.c    one statement at a time -> tokens (quotes, $VAR expansion, operators)
     │
     ▼
 parser.c   tokens -> Pipeline { Command[], redirects, background flag }
     │
     ▼
 exec.c     fork one child per command, wire them together with pipe()+dup2(),
            apply redirections, execvp(), then waitpid() unless backgrounded
```

Design notes worth knowing:
- **Builtins run in the shell process.** `cd` in a child would change nothing, so a lone builtin executes in the parent. Inside a pipeline it runs in a child like any other command.
- **Statements are lexed one at a time.** That way `export X=1; echo $X` expands `$X` *after* the export has run, matching real shell behavior.
- **File descriptors are closed carefully** in the parent after each fork so downstream commands see EOF when upstream ones exit.
- **Signals:** the shell ignores SIGINT; children reset it to default before `exec`.

## Project layout
```
src/shell.h    shared types and function declarations
src/lexer.c    tokenizer and variable expansion
src/parser.c   token stream -> pipeline structure
src/exec.c     process creation, pipes, redirects, builtins
src/main.c     read-eval loop
tests/run_tests.sh
```

## Known limitations / ideas to extend
Job control (`fg`, `bg`, Ctrl+Z), command history and line editing (readline), globbing (`*.c`), `&&` / `||`, command substitution `$(...)`, `if`/`while` scripting.

## License
MIT
