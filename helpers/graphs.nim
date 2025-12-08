import std / [tables, sequtils, sets, sugar, strutils, hashes, strformat, deques, heapqueue]

import ./grids

type
  GraphNode*[T] = ref object
    links*: HashSet[GraphNode[T]]
    value*: T

  GridValue*[T] = object
    value*: T
    coord*: GridCoordinate

  Graph*[T] = ref object
    nodes*: HashSet[GraphNode[T]]

  GraphCostFunction*[T] = proc(src: GraphNode[T], dest: GraphNode[T]): float {.nimcall.}

  Path*[T] = ref object
    steps*: seq[GraphNode[T]]
    cost*: float

  AStarWrapper*[T] = ref object
    hCost*: float
    gCost*: float
    node*: GraphNode[T]
    stale*: bool = false

proc `<`*(a1, a2: AStarWrapper): bool =
  a1.hCost + a1.gCost < a2.hCost + a2.gCost

proc hash*[T](a: AStarWrapper[T]): Hash =
  hash(a.node)

proc `$`*[T](path: Path[T]): string =
  if path.isNil: "nil" else: $path[]

#proc cmp*[T](p1, p2: Path[T]): int =
#  cmp(p1.score, p2.score)

proc `<`*[T](p1, p2: Path[T]): bool =
  (p1.cost, p2.steps.len) < (p2.cost, p2.steps.len)

proc `$`*[T](node: GraphNode[T]): string =
  if node.isNil: return "nil"
  let connections = collect(newSeq):
    for n in node.links:
      $n.value

  let links = connections.join(" | ")
  fmt"{node.value}"

#proc `$`*[T](node: GraphNode[GridValue[T]]): string =
#  $node.value.value

proc `$`*[T](graph: Graph[T]): string =
  let nodes = collect(newSeq):
    for n in graph.nodes:
      $n
  nodes.join("\n")

proc initGraph*[T](): Graph[T] =
  Graph[T]()

proc add*[T](graph: var Graph[T], node: GraphNode[T], bidirectional: bool = false) =
  graph.nodes.incl node
  if bidirectional:
    for neighbour in node.links:
      neighbour.links.incl node

proc reverse*[T](graph: Graph[T]): Graph[T] =
  result = initGraph[T]()
  let newNodesMap: Table[GraphNode[T], GraphNode[T]] = collect:
    for oldNode in graph.nodes:
      {oldNode: GraphNode[T](value: oldNode.value)}
  for oldNode in graph.nodes:
    for neigh in oldNode.links:
      newNodesMap[neigh].links.incl newNodesMap[oldNode]

  result.nodes = newNodesMap.values.toSeq.toHashSet

proc fromTable*[T](t: Table[T, seq[T]], bidirectional=false): Graph[T] =
  result = initGraph[T]()
  var allKeys = t.keys.toSeq.toHashSet
  for (key, values) in t.pairs:
    for v in values:
      allKeys.incl v
  var nodes = collect(initTable()):
    for key in allKeys:
      {key: GraphNode[T](value: key)}
  
  for key in allKeys:
    var node = nodes[key]
    if key in t:
      for neigh in t[key]:
        node.links.incl nodes[neigh]
    result.add(node, bidirectional)

proc fromGrid*[T, Y](grid: Grid[T], mode: NeighboursMode, isConnectedFunc: (grid: Grid[T], center: GridCoordinate, neighbour: GridCoordinate) -> bool, valueFunc: (grid: Grid[T], coord: GridCoordinate) -> Y): Graph[Y] =
  result = initGraph[Y]()
  var nodes = collect(initTable()):
    for coord in grid:
      {coord: GraphNode[Y]()}

  for coord in grid:
    var node = nodes[coord]
    for (neigh, neighValue) in grid.neighbours(coord, mode):
      if isConnectedFunc(grid, coord, neigh):
        node.links.incl nodes[neigh]
    if node.links.len > 0:
      node.value = valueFunc(grid, coord)
      result.add(node)

template findNodeWith*[T](graph: Graph[T], op: untyped): GraphNode[T] =
  var result: GraphNode[T]
  for node in graph.nodes:
    let it {.inject.} = node
    if op:
      result = node
      break
  result

template findNodesWith*[T](graph: Graph[T], op: untyped): seq[GraphNode[T]] =
  var result: seq[GraphNode[T]]
  for node in graph.nodes:
    let it {.inject.} = node
    if op:
      result.add node
  result

### Path Finding

proc defaultStepCost*[T](src: GraphNode[T], dest: GraphNode[T]): float =
  1

proc defaultCostEstimationFunction*[T](src: GraphNode[T], dest: GraphNode[T]): float =
  when T is GridValue:
    manhattan(src.value.coord - dest.value.coord).float
  else:
    1
  

# proc firstPop[T](l: var seq[T]): T =
#   assert l.len > 0
#   result = l[0]
#   l.delete(0)

# # will need a new datatype for search where we can keep the score. Or another datastructure
# proc dijkstra(start, goal: Graph): int =
#   var queue: seq[Graph] = @[start]
#   while queue.len > 0:
#     let current = queue.firstPop()
#     for n in current.neighbors:
#       if n.score == -1 or n.score > current.score + 1:
#         n.score = current.score + 1
#         queue.insert(n, upperBound(queue, n))
#   result = goal.score


# How do we specify the cost function? Take two (neighbouring) nodes as input and output a value?
# In the simplest case it always returns 1 to keep 
# How to efficiently return new list? It will be maaaany seq allocation. Linked lists?


proc internalDepthSearch*[T](graph: Graph[T], startNode, endNode: GraphNode[T], visits: var seq[GraphNode[T]], currentDepth: int, maxDepth: int, stepCost: GraphCostFunction[T]): Path[T] =
  if currentDepth > maxDepth:
    return nil
  if startNode == endNode:
    return Path[T](steps: @[endNode], cost: 0)

  visits.add startNode
  var bestPath: Path[T] = nil
  for neigh in startNode.links:
    if neigh in visits: continue
    var subpath = internalDepthSearch(graph, neigh, endNode, visits, currentDepth+1, maxDepth, stepCost)
    if not subpath.isNil:
      let nextNode = subpath.steps[^1]
      let cost = stepCost(startNode, nextNode)
      subpath.cost += cost
      if bestPath.isNil or subpath < bestPath:
        subpath.steps.add startNode
        bestPath = subpath

  discard visits.pop()

  bestPath

proc depthSearchExhaustive*[T](graph: Graph[T], startNode, endNode: GraphNode[T], stepCost: GraphCostFunction[T] = defaultStepCost[T]): Path[T] =
  var visits = newSeq[GraphNode[T]]()
  internalDepthSearch(graph, startNode, endNode, visits, 0, graph.nodes.len, stepCost)

proc iterativeDeepingSearch*[T](graph: Graph[T], startNode, endNode: GraphNode[T], maxDepth: int = -1, deepeningStep: int = 1, stepCost: GraphCostFunction[T] = defaultStepCost[T]): Path[T] =
  let maxDepth = if maxDepth < 0: graph.nodes.len else: maxDepth
  echo "Max depth: ", maxDepth
  var visits = newSeq[GraphNode[T]]()
  for depth in countUp(1, maxDepth, deepeningStep):
    echo &"Trying max depth: {depth}"
    let path = internalDepthSearch(graph, startNode, endNode, visits, 0, depth, stepCost)
    if not path.isNil:
      return path

proc iterativeDeepeningAStar*[T](graph: Graph[T], startNode, endNode: GraphNode[T], stepCost: GraphCostFunction[T] = defaultStepCost[T], costEstimationFunction: GraphCostFunction[T] = defaultCostEstimationFunction[T]): Path[T] =
  discard

proc reconstructPath*[T](parentMap: Table[GraphNode[T], GraphNode[T]], startNode: GraphNode[T], endNode: GraphNode[T], stepCost: GraphCostFunction[T]): Path[T] =
  var parent = parentMap[endNode]
  result = Path[T](steps: @[endNode], cost: stepCost(parent, endNode))
  while parent != startNode:
    let child = parent
    parent = parentMap[child]
    result.cost += stepCost(parent, child)
    result.steps.add parent

proc breadthSearch*[T](graph: Graph[T], startNode, endNode: GraphNode[T], stepCost: GraphCostFunction[T] = defaultStepCost[T]): Path[T] =
  var queue = initDeque[GraphNode[T]]()
  var visited = initHashset[GraphNode[T]]()
  var parentMap: Table[GraphNode[T], GraphNode[T]]
  visited.incl startNode
  queue.addLast(startNode)
  var nIterations = 0
  while queue.len > 0:
    nIterations += 1
    let node = queue.popFirst()
    if node == endNode:
      echo &"breadthSearch took {nIterations} iterations"
      return reconstructPath(parentMap, startNode, endNode, stepCost)
    for neigh in node.links:
      if neigh in visited: continue
      visited.incl neigh
      parentMap[neigh] = node
      queue.addLast(neigh)

proc aStarSearch*[T](graph: Graph[T], startNode, endNode: GraphNode[T], stepCost: GraphCostFunction[T] = defaultStepCost[T], costEstimate: GraphCostFunction[T] = defaultCostEstimationFunction[T]): Path[T] =
  var queue: HeapQueue[AStarWrapper[T]]
  var parentMap: Table[GraphNode[T], GraphNode[T]]
  var wrapperMap: Table[GraphNode[T], AStarWrapper[T]]
  let startNodeWrapper = AStarWrapper[T](node: startNode, gCost: 0, hCost: costEstimate(startNode, endNode))
  queue.push(startNodeWrapper)
  var nIterations = 0
  while queue.len > 0:
    nIterations += 1
    let current = queue.pop()
    if current.stale:
      # If it is marked as stale, it means it has been updated replaced with a new one, so skip it
      continue
    if current.node == endNode:
      #echo &"aStarSearch took {nIterations} iterations"
      return reconstructPath(parentMap, startNode, endNode, stepCost)
    for neighNode in current.node.links:
      let neighGCost = current.gCost + stepCost(current.node, neighNode)
      if neighNode notin wrapperMap:
        let neigh = AStarWrapper[T](node: neighNode, gCost: neighGCost, hCost: costEstimate(neighNode, endNode))
        wrapperMap[neighNode] = neigh
        parentMap[neighNode] = current.node
        queue.push(neigh)
      else:
        let neigh = wrapperMap[neighNode]
        if neighGCost < neigh.gCost:
          # mark as stale and insert a new copy
          neigh.stale = true
          let newNeigh = AStarWrapper[T](node: neighNode, gCost: neighGCost, hCost: neigh.hCost)
          parentMap[neighNode] = current.node
          wrapperMap[neighNode] = newNeigh
          queue.push(newNeigh)

proc isConnected*[T](graph: Graph[T], node1, node2: GraphNode[T]): bool =
  not graph.aStarSearch(node1, node2).isNil

proc isConnectedCached*[T](graph: Graph[T], node1, node2: GraphNode[T], cache: var Table[(GraphNode[T], GraphNode[T]), bool]): bool =
  for origin in @[node1] & node1.links.toSeq:
    for destination in @[node2] & node2.links.toSeq:
      for key in [(origin, destination), (destination, origin)]:
        if key in cache:
          #echo "cache hit"
          let val = cache[key]
          cache[(node1, node2)] = val
          return val
  #echo "cache miss"
  let val = graph.isConnected(node1, node2)
  cache[(node1, node2)] = val
  return val

# add an option whether to do an exhaustive search or return when we find the first path
# add iterative deepening by adding a maxdepth parameter to internalDepthSearch
# add costEstimation (A*)
# add the current cost

# some way of iterating through all nodes
# djikstraPath(startPos: GraphNode, endPos: GraphNode): seq[GraphNode]
# depthPath
# breadthPath

proc exampleIsConnected*(grid: Grid[char], center: GridCoordinate, neighbour: GridCoordinate): bool =
  grid[center] != '#' and grid[neighbour] != '#'

proc exampleValueFunc*(grid: Grid[char], coord: GridCoordinate): GridValue[char] =
  GridValue[char](value: grid[coord], coord: coord)

if isMainModule:
  # y (3, 1) is only linked to (3, 2), but not (4, 1)
  if true:
    let grid = parseCharGrid[char]("""
#### ##
#x#y   
#   #a#
#######
""".strip, (c: char) => c)
    
    var graph = fromGrid(grid, Cross, exampleIsConnected, exampleValueFunc)
    echo $graph
    echo "----------------"
    let startNode = graph.findNodeWith(it.value.value == 'x')
    let endNode = graph.findNodeWith(it.value.value == 'a')
    #echo startNode, " ", endNode


    discard breadthSearch(graph, startNode, endNode)
    let path = aStarSearch(graph, startNode, endNode)
    echo path

  if false:
    let graph = fromTable({
      1: @[2],
      2: @[3],
      3: @[2, 4],
    }.toTable, true)

    echo graph
