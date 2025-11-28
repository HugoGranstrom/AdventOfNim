import std / [tables, sequtils, sets, sugar, strutils, hashes, strformat]

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

  Path*[T] = ref object
    steps*: seq[GraphNode[T]]
    # cost?

proc `$`*[T](path: Path[T]): string =
  $path[]

proc `$`*[T](node: GraphNode[T]): string =
  let connections = collect(newSeq):
    for n in node.links:
      $n.value

  let links = connections.join(" | ")
  fmt"{node.value} -> [{links}]"

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

proc internalDepthSearch*[T]() =
  discard

proc defaultStepCostFunction*[T](src: GraphNode[T], dest: GraphNode[T]): float =
  1

proc depthPath*[T](graph: Graph[T], startNode, endNode: GraphNode[T], stepCostFunction: proc(src: GraphNode[T], dest: GraphNode[T]): float {.nimcall.} = defaultStepCostFunction[T]): Path[T] =

  echo stepCostFunction(startNode, endNode)
  Path[T]()

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
    echo startNode, " ", endNode

    let path = depthPath(graph, startNode, endNode)
    echo path

  if false:
    let graph = fromTable({
      1: @[2],
      2: @[3],
      3: @[2, 4],
    }.toTable, true)

    echo graph
