import tables, benchy

proc calcDay15(limit: int): int =
  var turn = 1
  var counter = newSeq[(int, int)](limit) # int -> (last, 2nd last)
  let starting = [0,3,1,6,7,5]
  var last: int
  for i in starting:
    counter[i] = (turn, 0)
    last = i
    turn += 1
  while turn <= limit:
    if counter[last][1] == 0:
      let lastTurn = counter[0][0]
      counter[0] = (turn, lastTurn)
      last = 0
    else:
      let diff = counter[last][0] - counter[last][1]
      let lastTurn = counter[diff][0]
      counter[diff] = (turn, lastTurn)
      last = diff
    turn += 1
  result = last

when isMainModule:
  echo "Part 1: ", calcDay15(2020)
  echo "Part 2: ", calcDay15(30000000)
  timeit "Part 1":
    keep calcDay15(2020)
  timeit "Part 2":
    keep calcDay15(30000000)
  