import std/[strutils, sequtils, strscans]

proc part1(instructions: seq[string]): int =
  var depth, horiz: int
  for instr in instructions:
    let (success, dir, step) = scanTuple(instr, "$w $i")
    doAssert success
    if   dir == "forward": horiz += step
    elif dir == "down": depth += step
    elif dir == "up": depth -= step
    else: doAssert false, "Invalid directions: " & dir
  result = depth * horiz

proc part2(instructions: seq[string]): int =
  var depth, horiz, aim: int
  for instr in instructions:
    let (success, dir, step) = scanTuple(instr, "$w $i")
    doAssert success
    if dir == "forward":
      horiz += step
      depth += aim * step
    elif dir == "down": aim += step
    elif dir == "up": aim -= step
    else: doAssert false, "Invalid directions: " & dir
  result = depth * horiz


let inputs = "input.txt".lines.toSeq

echo "Part 1: ", part1(inputs)
echo "Part 2: ", part2(inputs)
