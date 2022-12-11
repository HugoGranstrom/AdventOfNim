import batteries

type
  Monkey[T] = object
    items: seq[T] # Last item is the first one to inspect
    op: proc (old: T): T
    test: int
    actions: array[2, int]
    count: int

  ModNumber = object
    mods: seq[int]

proc initModNumber(n: int, maxMod: int): ModNumber =
  result.mods = newSeq[int](maxMod + 1)
  for i in 1 .. maxMod:
    result.mods[i] = n mod i

proc `+`(m: ModNumber, x: int): ModNumber =
  result = m # copy
  for i in 1 .. m.mods.high:
    result.mods[i] = result.mods[i] + x mod i #?

proc `*`(m: ModNumber, x: int): ModNumber =
  result = m # copy
  for i in 1 .. m.mods.high:
    result.mods[i] = result.mods[i] * x mod i #?


proc `$`(m: Monkey): string =
  &"Count: {m.count}, Items: {m.items.reversed}"

proc createOp(op: proc (a, b: int): int, aaaaa: string): proc (old: int): int =
  result = proc (old: int): int =
    let value =
      if aaaaa.strip() == "old":
        old
      else:
        parseInt(aaaaa.strip())
    return op(old, value)

proc parseInput[T](input: string): seq[Monkey[T]] =
  for monkeyBlock in input.split("\n\n"):
    var monkey: Monkey[T]
    for line in monkeyBlock.splitLines:
      if line.strip().startsWith("Starting items:"):
        for i in line.split(":")[1].split(","):
          monkey.items.insert(parseInt(i.strip), 0)
      elif line.strip().startsWith("Operation:"):
        let operation = line.split("=")[^1]
        if '*' in operation:
          let spl = operation.split("*")
          let f = (x, y: int) => x*y
          monkey.op = createOp(f, spl[1])
        elif "+" in operation:
          let spl = operation.split("+")[1]
          let f = (x, y: int) => x+y
          monkey.op = createOp(f, spl)
        else:
          assert false, "Invalid op found: " & line
      elif line.strip().startsWith("Test:"):
        let i = line.split("by")[^1].strip
        monkey.test = parseInt(i)
      elif line.strip().startsWith("If true"):
        monkey.actions[1] = parseInt(line.split("monkey")[^1].strip())
      elif line.strip().startsWith("If false"):
        monkey.actions[0] = parseInt(line.split("monkey")[^1].strip())
    result.add monkey

proc runPart1[T](monkeys: var seq[Monkey[T]]) =
  for i in 0 .. monkeys.high:
    for j in 0 .. monkeys[i].items.high:
      let initialWorry = monkeys[i].items.pop()
      let opWorry = monkeys[i].op(initialWorry)
      let reliefWorry = opWorry div 3
      let cond = reliefWorry mod monkeys[i].test == 0
      let throwIndex = monkeys[i].actions[cond.int]
      monkeys[throwIndex].items.insert(reliefWorry, 0)
      monkeys[i].count += 1
      #echo &"{i} throwing {reliefWorry} to {throwIndex} {initialWorry} {opWorry}"
    #echo "---------------------"

proc part1(input: string) =
  var monkeys = parseInput[int](input)
  #echo monkeys
  for i in 0 ..< 20:
    monkeys.runPart1()
  #echo monkeys
  var counts = monkeys.mapIt(it.count)
  counts.sort(Descending)
  echo "Part 1: ", counts[0] * counts[1]

proc runPart2(monkeys: var seq[Monkey]) =
  for i in 0 .. monkeys.high:
    for j in 0 .. monkeys[i].items.high:
      let initialWorry = monkeys[i].items.pop()
      let opWorry = monkeys[i].op(initialWorry)
      #let reliefWorry = opWorry div 3
      let cond = opWorry mod monkeys[i].test == 0
      let throwIndex = monkeys[i].actions[cond.int]
      monkeys[throwIndex].items.insert(opWorry, 0)
      monkeys[i].count += 1
      echo &"{i} throwing {opWorry} to {throwIndex}"

#[ proc part2(input: string) =
  var monkeys = parseInput(input)
  #echo monkeys
  for i in 0 ..< 20:
    monkeys.runPart2()
  #echo monkeys
  var counts = monkeys.mapIt(it.count)
  counts.sort(Descending)
  echo "Part 2: ", counts[0] * counts[1] ]#

when isMainModule:
  let input = readFile "testinput.txt"
  part1(input)
  #part2(input)
  