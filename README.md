![](https://s3-us-west-2.amazonaws.com/mjb-personal/logo.jpg)

# Taiga Lang

Taiga is an experimental programming language that enforces code to be thought of as simply as possible.

Taiga is functional in nature, with an iterative style syntax. In every expression, the variable `_` will contain the previously computed value, creating streams of values through lines.

Each line can only contain one command followed by its arguments.

```taiga
rout fib n
  eq n 1
  if _ return 1

  eq n 0
  if _ return 0

  sub n 1
  fib _
  let past1 _

  sub n 2
  fib _
  let past2 _

  add past1 past2
  endrout

fib 10
print _
# Prints 55
