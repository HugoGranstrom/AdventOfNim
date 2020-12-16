import strutils, npeg, sequtils, tables, sets

let p = peg("all", output: (Table[string, set[0..65535]], seq[array[20, int]], array[20, int])):
  # rules, otherTickets, yourTicket
  all <- ruleBlock * yourTicket * otherTickets
  yourTicket <- "your ticket:\n" * >ticket * "\n":
    let ticketSeq = ($1).strip.split(",").mapIt(it.parseInt)
    for i, number in ticketSeq:
      output[2][i] = number
  ruleBlock <- +(rule * '\n') * '\n'
  rule <- >fieldName * ": " * >numRange * " or " * >numRange:
    let s1 = ($2).strip.split("-").mapIt(it.parseInt)
    let s2 = ($3).strip.split("-").mapIt(it.parseInt)
    output[0][$1] = {s1[0] .. s1[1], s2[0] .. s2[1]}
  fieldName <- (+Alpha * Space * +Alpha | +Alpha)
  numRange <- +Digit * '-' * +Digit
  otherTickets <- "nearby tickets:\n" * +otherTicket
  otherTicket <- >ticket:
    let s = ($1).strip.split(",").mapIt(it.parseInt)
    var a: array[20, int]
    for i in 0 .. 19:
      a[i] = s[i]
    output[1].add a
  ticket <- (+Digit * (',' | '\n'))[20]

proc loadRules(s: string): (Table[string, set[0..65535]], seq[array[20, int]], array[20, int]) =
  assert p.match(s, result).ok

proc part1(rules: Table[string, set[0..65535]], otherTickets: seq[array[20, int]]): int =
  var allRules: set[0..65535]
  for s in rules.values:
    allRules.incl s
  for ticket in otherTickets:
    for number in ticket:
      if number notin allRules: result += number

proc part2(rules: Table[string, set[0..65535]], otherTickets: seq[array[20, int]], yourTicket: array[20, int]): int =
  # discard invalid tickets
  var allRules: set[0..65535]
  for s in rules.values:
    allRules.incl s
  var legalTickets = newSeqOfCap[array[20, int]](otherTickets.len)
  for ticket in otherTickets:
    block ticketBlock:
      for number in ticket:
        if number notin allRules: break ticketBlock
      legalTickets.add ticket
  assert part1(rules, legalTickets) == 0
  var matches: seq[HashSet[string]] = newSeq[HashSet[string]](20)
  for column in 0 .. 19:
    for key, rule in rules.pairs:
      var counter: int
      for i in 0 .. legalTickets.high:
        if legalTickets[i][column] in rule:
          counter += 1
      if legalTickets.len - counter == 0:
        matches[column].incl key
  var cmpSeq = newSeq[HashSet[string]](20)
  var final: seq[string] = newSeq[string](20)
  while matches != cmpSeq:
    for i in 0 .. matches.high:
      if matches[i].len != 0:
        if matches[i].len == 1:
          let key = matches[i].pop
          final[i] = key
          for j in 0 .. matches.high:
            matches[j].excl key
  var indices: seq[int]
  for i, key in final:
    if "departure" in key:
      indices.add i
  result = 1
  for i in indices:
    result *= yourTicket[i]

          



when isMainModule:
  let (rules, otherTickets, yourTicket) = loadRules(readFile("day16.txt"))
  let p1 = part1(rules, otherTickets)
  echo "Part 1: ", p1
  let p2 = part2(rules, otherTickets, yourTicket)
  echo "Part 2: ", p2
