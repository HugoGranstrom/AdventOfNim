import strutils, strscans, tables, sets

proc parseLine(line: string): (string, seq[(string, int)]) =
  var main1, main2, children: string
  if scanf(line, "$w $w bags contain $+.", main1, main2, children):
    result[0] = main1 & " " & main2
    if children != "no other bags":
      for c in children.split(", "):
        var n: int
        var color1, color2: string
        if scanf(c, "$i $w $w bag", n, color1, color2):
          result[1].add (color1 & " " & color2, n)
        else:
          echo c, " # ", line

proc calcAlternatives(t: TableRef[string, seq[string]], key: string, hSet: var HashSet[string]) =
  if key notin t: return
  for c in t[key]:
    hSet.incl c
    t.calcAlternatives(c, hSet)

proc part1() =
  let data = readFile("day7.txt")
  var parentColors = newTable[string, seq[string]]()
  for line in data.splitLines:
    let (mainColor, childColors) = parseLine(line)
    for (c, i) in childColors:
      if c notin parentColors:
        parentColors[c] = @[mainColor]
      else:
        parentColors[c].add mainColor
  var alternatives: HashSet[string]
  parentColors.calcAlternatives("shiny gold", alternatives)
  echo "Alternatives part1: ", alternatives.len

proc calcChildren(t: TableRef[string, seq[(string, int)]], color: string): int =
  if color notin t: return 0
  for (c, i) in t[color]:
    let nChildren = calcChildren(t, c)
    if nChildren == 0: result += i
    else: result += i * (nChildren + 1)

proc part2() =
  let data = readFile("day7.txt")
  var children = newTable[string, seq[(string, int)]]()
  for line in data.splitLines:
    let (mainColor, childColors) = parseLine(line)
    for (c, i) in childColors:
      if mainColor notin children:
        children[mainColor] = @[(c, i)]
      else:
        children[mainColor].add (c, i)
  echo children["shiny gold"]
  echo "Total number of bags: ", calcChildren(children, "shiny gold")
  

when isMainModule:
  part1()
  part2()