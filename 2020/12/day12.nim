import strutils

type
  InstructionSet = enum
    north
    south
    east
    west
    left
    right
    forward
  Instruction = object
    kind: InstructionSet
    value: int
  Ship = object
    pos: tuple[x: int, y: int]
    bearing: tuple[x: int, y: int]

proc loadInstructions(): seq[Instruction] =
  let data = readFile("day12.txt").strip
  for line in data.splitLines:
    let c = line[0]
    let value = parseInt(line[1..^1])
    case c
    of 'N': result.add Instruction(kind: north, value: value)
    of 'S': result.add Instruction(kind: south, value: value)
    of 'E': result.add Instruction(kind: east, value: value)
    of 'W': result.add Instruction(kind: west, value: value)
    of 'L': result.add Instruction(kind: left, value: value)
    of 'R': result.add Instruction(kind: right, value: value)
    of 'F': result.add Instruction(kind: forward, value: value)
    else: echo "Inknown instruction char in parsing: ", c

proc stepShipPart1(ship: var Ship, instr: Instruction) =
  case instr.kind
  of north:
    ship.pos.y += instr.value
  of south:
    ship.pos.y -= instr.value
  of east:
    ship.pos.x += instr.value
  of west:
    ship.pos.x -= instr.value
  of left:
    if instr.value == 90:
      ship.bearing = (x: -ship.bearing.y, y: ship.bearing.x)
    elif instr.value == 180:
      ship.bearing.x = -ship.bearing.x
      ship.bearing.y = -ship.bearing.y
    elif instr.value == 270:
      ship.bearing = (x: ship.bearing.y, y: -ship.bearing.x)
  of right:
    if instr.value == 270:
      ship.bearing = (x: -ship.bearing.y, y: ship.bearing.x)
    elif instr.value == 180:
      ship.bearing.x = -ship.bearing.x
      ship.bearing.y = -ship.bearing.y
    elif instr.value == 90:
      ship.bearing = (x: ship.bearing.y, y: -ship.bearing.x)
  of forward:
    ship.pos.x += ship.bearing.x * instr.value
    ship.pos.y += ship.bearing.y * instr.value

proc manhattan(a, b: tuple[x: int, y:int]): int =
  abs(a.x - b.x) + abs(a.y - b.y)

proc part1(instructions: seq[Instruction]) =
  var ship = Ship(pos: (x:0, y:0), bearing: (x:1, y:0))
  for instr in instructions:
    ship.stepShipPart1(instr)
  echo "Part 1: ", manhattan(ship.pos, (x:0, y:0))

proc stepShipPart2(ship: var Ship, instr: Instruction) =
  case instr.kind
  of north:
    ship.bearing.y += instr.value
  of south:
    ship.bearing.y -= instr.value
  of east:
    ship.bearing.x += instr.value
  of west:
    ship.bearing.x -= instr.value
  of left:
    if instr.value == 90:
      ship.bearing = (x: -ship.bearing.y, y: ship.bearing.x)
    elif instr.value == 180:
      ship.bearing.x = -ship.bearing.x
      ship.bearing.y = -ship.bearing.y
    elif instr.value == 270:
      ship.bearing = (x: ship.bearing.y, y: -ship.bearing.x)
  of right:
    if instr.value == 270:
      ship.bearing = (x: -ship.bearing.y, y: ship.bearing.x)
    elif instr.value == 180:
      ship.bearing.x = -ship.bearing.x
      ship.bearing.y = -ship.bearing.y
    elif instr.value == 90:
      ship.bearing = (x: ship.bearing.y, y: -ship.bearing.x)
  of forward:
    ship.pos.x += ship.bearing.x * instr.value
    ship.pos.y += ship.bearing.y * instr.value

proc part2(instructions: seq[Instruction]) =
  # bearing is used as the waypoint here
  var ship = Ship(pos: (x:0, y:0), bearing: (x:10, y:1))
  for instr in instructions:
    ship.stepShipPart2(instr)
  echo "Part 2: ", manhattan(ship.pos, (x:0, y:0))

when isMainModule:
  let instructions = loadInstructions()
  part1(instructions)
  part2(instructions)
