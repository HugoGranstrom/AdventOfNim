import strutils, sugar
import itertools

proc main() =
  let f = open("input.txt")
  let data = collect(newSeq):
    for line in f.lines:
      parseInt(line)
  f.close()
  # part 1
  for pair in combinations(data, 2):
    let a = pair[0]
    let b = pair[1]
    if a + b == 2020:
      echo a*b
  # part 2
  for tripplet in combinations(data, 3):
    let a = tripplet[0]
    let b = tripplet[1]
    let c = tripplet[2]
    if a + b + c == 2020:
      echo a * b * c

when isMainModule:
  main()
