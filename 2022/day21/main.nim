import batteries

type
  YellKind = enum
    Value, Op
  YellNode = object
    case kind: YellKind
    of Value:
      value: int
    of Op:
      memory: int
      left, right: string
      op: proc (x, y: int): int

  YellTree = Table[string, YellNode]

let opFuncs = {
  '+': (x, y: int) => x + y,
  '-': (x, y: int) => x - y,
  '*': (x, y: int) => x * y,
  '/': (x, y: int) => x div y,
  '=': (x, y: int) => int(x == y)
}.toTable

proc parseInput(input: string, part = 1): YellTree =
  for line in input.splitLines:
    var key, right, left: string
    var opChar: char
    var value: int
    if scanf(line, "$w: $i", key, value):
      result[key] = YellNode(kind: Value, value: value)
    elif scanf(line, "$w: $w $c $w", key, left, opChar, right):
      if key == "root" and part == 2:
        result[key] = YellNode(kind: Op, op: opFuncs['-'], left: left, right: right)
      else:
        result[key] = YellNode(kind: Op, op: opFuncs[opChar], left: left, right: right)
    else:
      assert false

proc eval(tree: var YellTree, key: string): int =
  let v = tree[key]
  case v.kind
  of Value:
    return v.value
  of Op:
    if v.memory == 0:
      let left = tree.eval(v.left)
      let right = tree.eval(v.right)
      let value = v.op(left, right)
      tree[key].memory = value
      return value
    else:
      return v.memory

proc part1(input: string) =
  var tree = parseInput(input)
  let answer = tree.eval("root")
  echo "Part 1: ", answer

proc resetMemory(tree: var YellTree) =
  for key in tree.keys:
    if tree[key].kind == Op:
      tree[key].memory = 0

proc part2(input: string) =
  var tree = parseInput(input, part=2)
  # Secant method
  proc f(x: int): int =
    tree.resetMemory()
    tree["humn"].value = x
    result = tree.eval("root")
  
  var x, xPrev: int
  var y, yPrev: int
  x = int(5e12)
  xPrev = int(1e11)

  y = f(x)
  yPrev = f(xPrev)

  var i = 0
  while y != 0:
    i += 1
    if i mod 1 == 0 or true:
      echo y#, " ", x, " |", tree.eval(tree["root"].left), " == ", tree.eval(tree["root"].right)
    let xNew = x - int(y.float * ((x - xPrev) / (y - yPrev)))
    xPrev = x
    yPrev = y
    x = xNew
    y = f(x)
    
  echo f(x - 1)

  echo "Part 2: ", x - 1 # there are multiple solutions?

when isMainModule:
  let input = readFile("input.txt")
  part1(input)
  part2(input)