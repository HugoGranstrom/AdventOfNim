include prelude, strscans, algorithm

proc crateNumber(indent: int): int =
  indent div 4

proc readInput*(input: string): tuple[stack: seq[seq[char]], instructions: seq[tuple[start, to, amount: int]]] =
  result.stack = newSeq[seq[char]](9)
  for line in input.splitLines:
    if '[' in line:
      # crate
      for i, c in line:
        if c == '[':
          let crate = crateNumber(i)
          result.stack[crate].add line[i+1]
    elif line.startsWith("move"):
      # move
      var instr: tuple[start, to, amount: int]
      assert scanf(line, "move $i from $i to $i", instr.amount, instr.start, instr.to)
      # zero-index adjust
      instr.start -= 1
      instr.to -= 1
      result.instructions.add instr
      
  # reverse stacks
  for i in 0 .. result.stack.high:
    result.stack[i].reverse()
      
proc part1(input: string) =
  var (stack, instructions) = readInput(input)
  for (start, to, amount) in instructions:
    for i in 0 ..< amount:
      stack[to].add stack[start].pop()

  var answer: seq[char]
  for s in stack:
    answer.add s[^1]

  echo "Part 1: ", answer.join("")

let testInput = """
    [D]    
[N] [C]    
[Z] [M] [P]
 1   2   3 

move 1 from 2 to 1
move 3 from 1 to 3
move 2 from 2 to 1
move 1 from 1 to 2"""

when isMainModule:
  let input = readFile("input.txt")
  part1(input)