import batteries

let duration = {"noop": 1, "addx": 2}.toTable

proc parseInput(input: string): seq[tuple[cmd: string, val: int]] =
  for line in input.splitLines:
    let s = line.split(" ")
    let cmd = s[0]
    let val = if cmd == "noop": 0 else: parseInt(s[1])
    result.add (cmd: s[0], val: val)

iterator runCommands(commands: seq[tuple[cmd: string, val: int]]): tuple[reg, pos: int] =
  var register = 1
  var currentCycle = 1
  for (cmd, value) in commands:
    for i in 0 ..< duration[cmd]:
      yield (reg: register, pos: currentCycle - 1)
      currentCycle += 1
    if cmd == "addx":
      register += value
  
proc part1(input: string) =
  let commands = parseInput(input)
  var result = 0
  for (reg, pos) in runCommands(commands):
    let currentCycle = pos + 1
    if (currentCycle - 20) mod 40 == 0:
      result += currentCycle * reg

  echo "Part 1: ", result

proc printCRT(crt: seq[string]) =
  for row in crt:
    echo row

proc part2(input: string) =
  let width = 40
  let height = 6
  var result = newSeq[string](height)
  let commands = parseInput(input)
  for (reg, pos) in runCommands(commands):
    let rowPos = pos div width
    let colPos = pos mod width
    if abs(reg - colPos) < 2:
      result[rowPos] &= '#'
    else:
      result[rowPos] &= ' '
  
  echo "Part 2: "
  result.printCrt

when isMainModule:
  let input = readFile "input.txt"
  part1(input)
  part2(input)

