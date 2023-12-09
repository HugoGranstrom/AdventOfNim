include std / prelude
import std / [strscans, algorithm, math]

type
  Instruction = enum
    Left = "L",
    Right = "R"

  Node = array[Instruction, string]
  Tree = Table[string, Node]

proc parseInput(input: string): tuple[tree: Tree, instructions: seq[Instruction]] =
  let splitted = input.strip.split("\n\n")
  for c in splitted[0].strip:
    result.instructions.add parseEnum[Instruction]($c)

  for line in splitted[1].splitlines:
    let (succ, key, left, right) = scanTuple(line, "$w = ($w, $w)")
    assert succ
    var node: Node
    node[Left] = left
    node[Right] = right
    result.tree[key] = node


proc traverseUntil(tree: Tree, instructions: seq[Instruction], start: string, stop: string): int =
  var currentNode = start
  var i = 0
  while currentNode != stop:
    let node = tree[currentNode]
    let instr = instructions[i mod instructions.len]
    currentNode = node[instr]
    i += 1
  return i

proc part1(input: string): int =
  let (tree, instructions) = parseInput(input)
  result = traverseUntil(tree, instructions, "AAA", "ZZZ")

proc part2(input: string): int =
  let (tree, instructions) = parseInput(input)
  var nodes = tree.keys.toSeq.filterIt(it[^1] == 'A')
  var answers: seq[int]
  for node in nodes:
    var currentNode = node
    var i = 0
    while not currentNode.endsWith("Z"):
      let node = tree[currentNode]
      let instr = instructions[i mod instructions.len]
      currentNode = node[instr]
      i += 1
    answers.add i
  
  result = answers.foldl(lcm(a, b))

let testInput = """
RL

AAA = (BBB, CCC)
BBB = (DDD, EEE)
CCC = (ZZZ, GGG)
DDD = (DDD, DDD)
EEE = (EEE, EEE)
GGG = (GGG, GGG)
ZZZ = (ZZZ, ZZZ)
"""

let testInput2 = """
LLR

AAA = (BBB, BBB)
BBB = (AAA, ZZZ)
ZZZ = (ZZZ, ZZZ)
"""

let testInput3 = """
LR

A1A = (B11, XXX)
B11 = (XXX, Z1Z)
Z1Z = (B11, XXX)
A2A = (B22, XXX)
B22 = (C22, C22)
C22 = (Z2Z, Z2Z)
Z2Z = (B22, B22)
XXX = (XXX, XXX)
"""

when isMainModule:
  let realInput = readFile("input.txt")
  let input = realInput
  let answer1 = part1(input)
  echo "Part 1: ", answer1
  let answer2 = part2(input)
  echo "Part 2: ", answer2