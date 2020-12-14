import npeg, strutils, bitops, math, tables, sequtils

type
  Opcodes = enum
    setMask
    store
  Instruction = object
    case op: Opcodes
    of setMask:
      mask: string
    of store:
      adress: int
      value: int

const parser = peg("instructions", output: seq[Instruction]):
  instructions <- +((store | setMask) * ('\n' | !1))
  store <- "mem[" * >+Digit * "] = " * >+Digit:
    output.add Instruction(op: store, adress: parseInt($1), value: parseInt($2))
  setMask <- "mask = " * >+Alnum:
    output.add Instruction(op: setMask, mask: $1)

proc loadInstructions(s: string): seq[Instruction] =
  assert parser.match(s, result).ok

template runInstructionsPart1(instructions: seq[Instruction], memory: seq[int]) =
  var oneMask, zeroMask: int
  # zeroMask: and
  # oneMask: or
  for instr in instructions:
    case instr.op
    of setMask:
      for i, c in instr.mask:
        if c == '1':
          zeroMask.clearBit(35 - i) # ignored by zeroMask
          oneMask.setBit(35 - i) # set to 1
        elif c == '0':
          zeroMask.setBit(35 - i) # set to 0
          oneMask.clearBit(35 - i) # ignore oneMask
        else:
          oneMask.clearBit(35 - i) # both ignores
          zeroMask.clearBit(35 - i)
    of store:
      var val = instr.value
      val.setMask(oneMask)
      val.clearMask(zeroMask)
      memory[instr.adress] = val

proc testPart1() =
  let instructions = loadInstructions("""mask = XXXXXXXXXXXXXXXXXXXXXXXXXXXXX1XXXX0X
mem[8] = 11
mem[7] = 101
mem[8] = 0""")
  var maxAdress: int
  for instr in instructions:
    if instr.op == store and instr.adress > maxAdress:
      maxAdress = instr.adress
  var memory = newSeq[int](maxAdress + 1)
  runInstructionsPart1(instructions, memory)
  assert sum(memory) == 165

proc part1() =
  let instructions = loadInstructions(readFile("day14.txt"))
  var maxAdress: int
  for instr in instructions:
    if instr.op == store and instr.adress > maxAdress:
      maxAdress = instr.adress
  var memory = newSeq[int](maxAdress + 1)
  runInstructionsPart1(instructions, memory)
  
iterator allFloatings(val: int, floatings: openArray[int]): int =
  # Floatings should contain the 1-index bit indices
  for i in 0 .. 2 ^ floatings.len - 1:
    var result = val
    for j in 0 .. floatings.high:
      if i.bitsliced(j..j) == 1:
        result.setBit(floatings[j] - 1)
      else:
        result.clearBit(floatings[j] - 1)
    yield result


template runInstructionsPart2(instructions: seq[Instruction], memory: Table[int, int]) =
  var oneMask: int
  var floatings: seq[int] # contains the bit indices of the floatings
  for instr in instructions:
    case instr.op
    of setMask:
      floatings.setLen(0)
      for i, c in instr.mask:
        if c == '1':
          oneMask.setBit(35 - i) # set to 1
        elif c == '0':
          oneMask.clearBit(35 - i) # ignore oneMask
        else:
          oneMask.clearBit(35 - i) # ignore oneMask
          floatings.add 36 - i
    of store:
      var adress = instr.adress
      adress.setMask(oneMask)
      for adr in allFloatings(adress, floatings):
        memory[adr] = instr.value

proc testPart2() =
  let instructions = loadInstructions("""mask = 000000000000000000000000000000X1001X
mem[42] = 100
mask = 00000000000000000000000000000000X0XX
mem[26] = 1""")
  var maxAdress: int
  for instr in instructions:
    if instr.op == store and instr.adress > maxAdress:
      maxAdress = instr.adress
  var memory = initTable[int, int]()
  runInstructionsPart2(instructions, memory)
  assert sum(toSeq(memory.values)) == 208
      
proc part2() =
  let instructions = loadInstructions(readFile("day14.txt"))
  var maxAdress: int
  for instr in instructions:
    if instr.op == store and instr.adress > maxAdress:
      maxAdress = instr.adress
  var memory = initTable[int, int]()
  runInstructionsPart2(instructions, memory)


when isMainModule:
  testPart1()
  part1()
  testPart2()
  part2()