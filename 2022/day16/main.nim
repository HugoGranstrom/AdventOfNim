import batteries, regex, std / [random]

type
  ValveState = enum
    Closed, Open
  Valve = ref object
    state: ValveState
    flowRate: int
    neighs: seq[Valve]
    name: string
    actionValues: Table[(int, ValveState), seq[float]] # same indexing as neighs, last index is self

proc `$`(v: Valve): string =
  let neighNames = v.neighs.mapIt(it.name)
  result = &"Valve(name: {v.name}, state: {v.state}, flowRate: {v.flowRate}, neighs: {neighNames})"

proc parseInput(input: string): Table[string, Valve] =
  var neighsTab: Table[string, seq[string]]
  for line in input.splitLines:
    let flowRate = line.findAll(re"-?\d+").mapIt(line[it.boundaries].parseInt)[0]
    let valves = line.findAll(re"[A-Z][A-Z]").mapIt(line[it.boundaries])
    let thisValve = valves[0]
    let neighbours = valves[1 .. ^1]
    neighsTab[thisValve] = neighbours
    result[thisValve] = Valve(state: Closed, flowRate: flowRate, name: thisValve)
  for (valve, neighs) in neighsTab.pairs:
    for neigh in neighs:
      result[valve].neighs.add result[neigh]

proc initActionValues(valves: Table[string, Valve], finish: int) =
  for v in valves.values:
    for state in ValveState:
      for i in 0 .. finish:
        v.actionValues[(i, state)] = newSeq[float](v.neighs.len + 1)

proc resetValves(valves: Table[string, Valve]) =
  for v in valves.values:
    v.state = Closed

proc getValveStates(valves: Table[string, Valve]): Table[string, ValveState] =
  result = initTable[string, ValveState](valves.len)
  for (key, valve) in valves.pairs:
    result[key] = valve.state

proc applyValveState(valves: Table[string, Valve], states: Table[string, ValveState]) =
  for key in valves.keys:
    valves[key].state = states[key] 

proc calcPressure(valves: seq[Valve]): int =
  for valve in valves:
    if valve.state == Open:
      result += valve.flowRate

proc `max=`(this: var int, other: int) =
  this = max(this, other)

#[ proc epsilonGreedy(actionValues: ActionValues, epsilon: float, iter: int, valve: string, state: ValveState): string =
  if rand(1.0) > epsilon:
    var maxVal = -Inf
    for (v, val) in actionValues.tab[(iter, valve, state)].pairs:
      if val > maxVal:
        result = v
        maxVal = val
  else:
    let i = rand(0 .. )
  

proc tdTrain(valves: Table[string, Valve], actionValues: ActionValues, current: string, iter, finish: int) =
  # if iter finish
  let currentValve = valves[current]
  let next = actionValues.epsilonGreedy(0.2, iter, current, currentValve.state) ]#

#[ proc dfSearch(valves: Table[string, Valve], current: Valve, iter, finish: int): int =
  if iter > finish:
    return 0
  result = valves.calcPressure()
  let states = valves.getValveStates()
  for neigh in current.neighs:
    valves.applyValveState(states) # reset states
    if valves[neigh].state == Open:
      continue
    if current.state == Closed:
      result.max= dfSearch(valves, valves[neigh], iter + 1, finish)
      valves.applyValveState(states) # reset states
    current.state = Open
    # do open here, always
    result.max= dfSearch(valves, valves[neigh], iter + 1, finish) ]#

proc epsilonGreedy(valve: Valve, iter: int, epsilon = 0.2): (Valve, int) =
  if rand(1.0) < epsilon: # random
    let maxI = if valve.state == Closed: valve.actionValues[(iter, valve.state)].high else: valve.actionValues[(iter, valve.state)].high - 1
    let i = rand(0 .. maxI)
    if i == valve.actionValues[(iter, valve.state)].high:
      return (valve, i)
    else:
      return (valve.neighs[i], i)
  else: # greedy
    result[0] = valve
    result[1] = valve.actionValues[(iter, valve.state)].high
    var maxVal = if valve.state == Closed: valve.actionValues[(iter, valve.state)][^1] else: -Inf
    for i in 0 .. valve.neighs.high:
      let val = valve.actionValues[(iter, valve.state)][i]
      if val > maxVal:
        result = (valve.neighs[i], i)
        maxVal = val

proc tdTrain(valves: seq[Valve], current: Valve, iter, finish: int, epsilon=0.3, gamma=0.9, alpha=0.1) =
  if iter < finish:
    let (next, index) = current.epsilonGreedy(iter, epsilon)
    assert not next.isNil
    let reward = valves.calcPressure().float / 10 # calculate this before changing current state?
    let nextQ = max(next.actionValues[(iter + 1, if current == next: Open else: next.state)])
    let currentQ = current.actionValues[(iter, current.state)][index]
    current.actionValues[(iter, current.state)][index] += alpha * (reward + gamma * nextQ - currentQ)

    #if current.name == "AA" and iter == 1 and current.state == 

    if next == current:
      current.state = Open

    tdTrain(valves, next, iter + 1, finish, epsilon, gamma, alpha)



  

proc part1(input: string) =
  let valves = parseInput(input)
  let valvesList = toSeq(valves.values)
  let finish = 20
  valves.initActionValues(finish)
  #echo valves
  #echo valves["AA"].actionValues
  let N = 1000000
  for i in 0 .. N:
    valves.resetValves()
    let epsilon = exp(-i.float * 2 / N.float)
    tdTrain(valvesList, valves["AA"], 1, finish, epsilon=0.2)
  echo valves["AA"].actionValues[(1, Closed)]#.values.toSeq().filterIt(sum(it) > 0)
  echo valves["AA"].neighs.mapIt(it.name)
  echo valves["DD"].actionValues[(2, Closed)]#.values.toSeq().filterIt(sum(it) > 0)
  echo valves["DD"].neighs.mapIt(it.name)
  echo valves["DD"].actionValues[(3, Open)]
  echo valves["CC"].actionValues[(4, Closed)]#.values.toSeq().filterIt(sum(it) > 0)
  echo valves["CC"].neighs.mapIt(it.name)
  var totCount = 0
  var count = 0
  for v in valvesList:
    for k in v.actionValues.values:
      for x in k:
        if x == 0: count += 1
        totCount += 1
  echo "Zeros: ", count, " out of ", totCount
  #let answer = dfSearch(valves, valves["AA"], 1, 14)
  #echo "Part 1: ", answer




when isMainModule:
  let input = readFile("testinput.txt")
  part1(input)