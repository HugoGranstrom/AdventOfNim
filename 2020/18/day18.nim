import strutils, npeg, tables

type
  TokenKind = enum
    number
    operator
  OpKind = enum
    lParen = "("
    rParen = ")"
    mul = "*"
    add = "+"
  Token = object
    case kind: TokenKind
    of number:
      val: int
    of operator:
      op: OpKind
      c: char

proc `$`(t: Token): string =
  case t.kind
  of number:
    result = $t.val
  of operator:
    result = $t.c

proc `+`(t1, t2: Token): Token =
  assert t1.kind == t2.kind
  result = Token(kind: number, val: t1.val + t2.val)

proc `*`(t1, t2: Token): Token =
  assert t1.kind == t2.kind
  result = Token(kind: number, val: t1.val * t2.val)

proc isNumber(c: char): bool =
  c in '0' .. '9'


proc calcExpr(s: string, presedence: Table[char, int]): int =
  let operators = {'+', '*'}
  var output: seq[Token]
  var opStack: seq[Token]
  var s = s.replace(" ", "")
  for c in s:
    if c.isNumber:
      output.add Token(kind: number, val: parseInt($c))
    elif c in operators:
      while opStack.len > 0 and opStack[^1].c != '(' and presedence[c] <= presedence[opStack[^1].c]:
        output.add opStack.pop
      opStack.add Token(kind: operator, c: c, op: parseEnum[OpKind]($c))
    elif c == '(':
      opStack.add Token(kind: operator, c: c, op: parseEnum[OpKind]($c))
    elif c == ')':
      while opStack[^1].c != '(':
        output.add opStack.pop
      if opStack[^1].c == '(':
        discard opStack.pop
  while opStack.len > 0:
    output.add opStack.pop
  var stack: seq[int]
  for token in output:
    if token.kind == number:
      stack.add token.val
    else:
      let b = stack.pop
      let a = stack.pop
      if token.op == add:
        stack.add a + b
      elif token.op == mul:
        stack.add a * b
  assert stack.len == 1, ("Expr: " & s)
  result = stack.pop
        

proc part1(): int =
  let input = readFile("day18.txt").strip
  let presedencePart1 = {'+': 1, '*': 1}.toTable
  for line in input.splitLines:
    result += calcExpr(line, presedencePart1)

proc part2(): int =
  let input = readFile("day18.txt").strip
  let presedencePart2 = {'+': 2, '*': 1}.toTable
  for line in input.splitLines:
    result += calcExpr(line, presedencePart2)

when isMainModule:
  let p1 = part1()
  echo "Part 1: ", p1
  let p2 = part2()
  echo "Part 2: ", p2