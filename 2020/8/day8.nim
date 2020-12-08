import npeg, strutils, sets

type
  Opcode = enum acc, jmp, nop
  VMState = ref object
    counter: int
    acc: int

proc newState(): VMState =
  VMState(counter: 0, acc: 0)

let p = peg("instructions", output: seq[(Opcode, int)]):
  instructions <- +(instr * ("\n" | !1))
  instr <- >op * Space * >arg:
    let num = parseInt($2)
    let op = parseEnum[Opcode]($1)
    output.add (op, num)
  op <- ("acc" | "jmp" | "nop")
  arg <- ('+' | '-') * +Digit

proc parseInstr(data: string): seq[(Opcode, int)] =
  assert p.match(data, result).ok

proc step(instr: (Opcode, int), state: VMState) =
  let op = instr[0]
  let arg = instr[1]
  case op
  of acc:
    state.acc += arg
    state.counter += 1
  of jmp:
    state.counter += arg
  of nop:
    state.counter += 1

proc run1(instructions: seq[(Opcode, int)]): int =
  var state = newState()
  var visited: HashSet[int]
  while state.counter <= instructions.high:
    if state.counter in visited:
      return state.acc
    visited.incl state.counter
    step(instructions[state.counter], state)

proc testPart1() =
  let data = """nop +0
acc +1
jmp +4
acc +3
jmp -3
acc -99
acc +1
jmp -4
acc +6"""
  let instructions = parseInstr(data)
  let ans = run1(instructions)
  doAssert ans == 5

proc part1() =
  let data = readFile("day8.txt")
  let instructions = parseInstr(data)
  let ans = run1(instructions)
  echo "Part 1: ", ans

proc replace(s: seq[(Opcode, int)], i: int): seq[(Opcode, int)] =
  for i, val in s: discard

proc run2(instructions: seq[(Opcode, int)]): bool =
  var state = newState()
  var visited: HashSet[int]
  while state.counter <= instructions.high:
    if state.counter in visited:
      return false
    visited.incl state.counter
    step(instructions[state.counter], state)
    if state.counter == instructions.high + 1:
      echo "Part 2: ", state.acc
      return true

proc part2() =
  let data = readFile("day8.txt")
  var instructions = parseInstr(data)
  for i in 0 .. instructions.high:
    let instr = instructions[i]
    case instr[0]:
    of jmp:
      instructions[i] = (nop, instr[1])
    of nop:
      instructions[i] = (jmp, instr[1])
    of acc: discard
    if run2(instructions): break
    instructions[i] = instr


when isMainModule:
  testPart1()
  part1()
  part2()

