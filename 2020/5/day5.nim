import strutils, sets

proc chooseUp(lower, upper: int): (int, int) =
  result = (((lower + upper + 1) / 2).toInt, upper)

proc chooseDown(lower, upper: int): (int, int) =
  result = (lower, ((lower + upper - 1) / 2).toInt)

proc parseSeat(seat: string): (int, int) =
  var upperRow = 127
  var lowerRow = 0
  var upperCol = 7
  var lowerCol = 0
  for i, c in seat:
    if i < 7:
      if c == 'F': (lowerRow, upperRow) = chooseDown(lowerRow, upperRow)
      elif c == 'B': (lowerRow, upperRow) = chooseUp(lowerRow, upperRow)
      else: echo "Something went wrong"
      if i == 6:
        result[0] = lowerRow
    else:
      if c == 'L': (lowerCol, upperCol) = chooseDown(lowerCol, upperCol)
      elif c == 'R': (lowerCol, upperCol) = chooseUp(lowerCol, upperCol)
      else: echo "Something went wrong"
      if i == 9:
        result[1] = lowerCol

proc calcSeatID(row, col: int): int = 8 * row + col

proc part1Test() =
  let data = """
BFFFBBFRRR
FFFBBBFRRR
BBFFBBFRLL"""
  var seats: seq[(int, int)]
  for line in data.splitLines:
    seats.add parseSeat(line)
  assert seats == @[(70, 7), (14, 7), (102, 4)]
  var seatIDs: seq[int]
  for (row, col) in seats:
    seatIDs.add calcSeatID(row, col)
  assert seatIDs == @[567, 119, 820]
  echo "Test part 1 successful!"

proc part1(): seq[(int, int)] =
  let data = readFile("day5.txt")
  var seats: seq[(int, int)]
  for line in data.splitLines:
    if line.len != 10: continue
    seats.add parseSeat(line)
  var seatIDs: seq[int]
  for (row, col) in seats:
    seatIDs.add calcSeatID(row, col)
  echo "Highest seat ID: ", max(seatIDs)
  result = seats

proc part2() =
  var available: HashSet[(int, int)]
  for row in 3..123:
    for col in 0..7:
      available.incl((row, col))
  let seats = part1()
  for seat in seats:
    available.excl(seat)
  echo "Available seats: ", available


when isMainModule:
  part1Test()
  discard part1()
  part2()