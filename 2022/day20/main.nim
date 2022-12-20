import batteries

type
  ListItem = ref int

proc `$`(l: ListItem): string =
  $l[]

proc parseInput(input: string): seq[ListItem] =
  for line in input.splitLines:
    let i = line.parseInt
    let l = new int
    l[] = i
    result.add l

proc modIndex(list: seq[ListItem], index: int): int =
  result = floorMod(index, list.high)
  if result == 0:
    result = list.high
  elif result == list.high:
    result = 0

proc zeroIndex(list: seq[ListItem]): int =
  result = -1
  for i in 0 .. list.high:
    if list[i][] == 0:
      return i

proc mix(original: seq[ListItem], list: var seq[ListItem]) =
  for o in original:
    let index = list.find(o)
    assert index > -1
    let moves = o[]
    let newIndex = list.modIndex(index + moves)
    #echo &"{o}: {index} -> {newIndex}"

    if newIndex != index:
      list.delete(index)
      list.insert(o, newIndex)

proc part1And2(input: string, nMixes, key: int) =
  let original = parseInput(input)
  var list = original # copy
  for x in list:
    x[] *= key
  #echo list
  for i in 0 ..< nMixes:
    mix(original, list)

  var answer = 0
  let indexZero = list.zeroIndex()
  #echo indexZero
  for x in [1000, 2000, 3000]:
    let i = (indexZero + x) mod list.len #list.modIndex(indexZero + x + 1)
    #echo list[i]
    answer += list[i][]
  
  echo "Part 1: ", answer


when isMainModule:
  let input = readFile"input.txt"
  part1And2(input, 1, 1)
  part1And2(input, 10, 811589153)