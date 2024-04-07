# The best language of all time

## To run

- `zig build run`
- can just build and then run the executable

- has 1 flag, `--file=filename`/`-f=filename`, to run a file, otherwise run the repl

## Syntax

+ `push`, to put a value on the stack.
+ `pop`, to pop a value from the stack.
+ `add`, `sub`, `mul`, `div` to apply the operations to the 2 top values, consuming both values and replacing with the result of the operation. `push 12 push 3 div` will push 12, then 3, then take 12 and 3 off the stack, divide 12 by 3, and put the result (4) on the stack.
+ `exit` to exit the repl.
+ literal numbers.

```zav
push 34 push 22.22 add print pop
```