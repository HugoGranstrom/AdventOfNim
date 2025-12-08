import batteries
import std / [strscans, algorithm, math]
import graphs

type
  Vector = tuple[x, y, z: int]
  Circuit = ref object
    values: HashSet[GraphNode[GridValue[bool]]]

proc `$`(c: Circuit): string =
   $c[]

proc circuitCmp(c1, c2: Circuit): int =
  cmp(c1.values.len, c2.values.len)

proc distance(v1, v2: Vector): float =
  ((v1.x - v2.x)^2 + (v1.y - v2.y)^2 + (v1.z - v2.z)^2).float.sqrt

proc parseInput(input: string): seq[Vector] =
  for line in input.strip.splitLines:
    let (success, x, y, z) = scanTuple(line, "$i,$i,$i")
    assert success
    result.add (x, y, z)

proc pairDistances(vectors: seq[Vector]): seq[tuple[dist: float, v1, v2: Vector]] =
  for i, v1 in vectors:
    for v2 in vectors[i+1..^1]:
      let dist = distance(v1, v2)
      result.add (dist, v1, v2)
  result.sort

# add previousCircuits as an optimization. Then we wouldn't have to restart from the beginning every time
proc calculateCircuits(nodes: seq[GraphNode[GridValue[bool]]]): seq[Circuit] =
  var graph = initGraph[GridValue[bool]]()
  var cache: Table[(GraphNode[GridValue[bool]], GraphNode[GridValue[bool]]), bool]
  var circuitMap: Table[GraphNode[GridValue[bool]], Circuit] = collect:
    for node in nodes:
      {node: Circuit(values: [node].toHashSet)}
  for i, node in nodes:
    for otherNode in nodes[i+1..^1]:
      if circuitMap[node] != circuitMap[otherNode] and graph.isConnectedCached(node, otherNode, cache):
        #echo "connected"
        # do we need to merge them?
        let keepCircuit = circuitMap[node]
        let mergeCircuit = circuitMap[otherNode]
        if keepCircuit != mergeCircuit:
          # merge mergeCircuit into keepCircuit
          keepCircuit.values.incl mergeCircuit.values
          # move all nodes in circuitMap
          for n in circuitMap.keys:
            if circuitMap[n] == mergeCircuit:
              circuitMap[n] = keepCircuit
  
  circuitMap.values.toSeq.deduplicate

proc part1(input: string): int =
  let vectors = parseInput(input)
  let pairDistances = vectors.pairDistances
  var graph = initGraph[GridValue[bool]]()
  let nodeMap: Table[Vector, GraphNode[GridValue[bool]]] = collect:
    for v in vectors:
      let node = GraphNode[GridValue[bool]](value: GridValue[bool](coord: (v.x, v.y)))
      graph.add node
      {v: node}

  for (_, v1, v2) in pairDistances[0..<1000]:
    let node1 = nodeMap[v1]
    let node2 = nodeMap[v2]
    if not graph.isConnected(node1, node2):
      node1.links.incl node2
      node2.links.incl node1
  
  var circuits = nodeMap.values.toSeq.calculateCircuits
  circuits.sort(circuitCmp, Descending)
  result = 1
  for x in circuits[0..<3].mapIt(it.values.len):
    result *= x

proc part2(input: string): int =
  let vectors = parseInput(input)
  let pairDistances = vectors.pairDistances
  var graph = initGraph[GridValue[bool]]()
  let nodeMap: Table[Vector, GraphNode[GridValue[bool]]] = collect:
    for v in vectors:
      let node = GraphNode[GridValue[bool]](value: GridValue[bool](coord: (v.x, v.y)))
      graph.add node
      {v: node}
  
  let nPairs = 1000
  for (_, v1, v2) in pairDistances[0..<nPairs]:
    let node1 = nodeMap[v1]
    let node2 = nodeMap[v2]
    if not graph.isConnected(node1, node2):
      node1.links.incl node2
      node2.links.incl node1
  var currentPair = nPairs
  while true:
    let (_, v1, v2) = pairDistances[currentPair]
    let node1 = nodeMap[v1]
    let node2 = nodeMap[v2]
    # should be possible to optimze this by using circuits
    if not graph.isConnected(node1, node2):
      node1.links.incl node2
      node2.links.incl node1
      let circuits = nodeMap.values.toSeq.calculateCircuits
      echo circuits.len
      if circuits.len == 1:
        # we have connected everything!
        return v1.x * v2.x
    currentPair += 1

let testInput = """
162,817,812
57,618,57
906,360,560
592,479,940
352,342,300
466,668,158
542,29,236
431,825,988
739,650,466
52,470,668
216,146,977
819,987,18
117,168,530
805,96,715
346,949,466
970,615,88
941,993,340
862,61,35
984,92,344
425,690,689
"""

when isMainModule:
  let realInput = readFile("input.txt")
  let input = realInput
  #let answer1 = part1(input)
  #echo "Part 1: ", answer1
  let answer2 = part2(input)
  echo "Part 2: ", answer2