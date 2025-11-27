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
    nodes*: seq[GraphNode[T]]

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
  graph.nodes.add node
  if bidirectional:
    for neighbour in node.links:
      neighbour.links.incl node

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

# some way of iterating through all nodes
# djikstraPath(startPos, endPos): seq[GraphNode]
# depthPath
# breadthPath

proc exampleIsConnected*(grid: Grid[char], center: GridCoordinate, neighbour: GridCoordinate): bool =
  grid[center] != '#' and grid[neighbour] != '#'

proc exampleValueFunc*(grid: Grid[char], coord: GridCoordinate): GridValue[char] =
  GridValue[char](value: grid[coord], coord: coord)

if isMainModule:
  # y is only linked to (3, 2), but not (4, 1)
  let grid = parseCharGrid[char]("""
#### ##
#x#y   
#   #a#
#######
""".strip, (c: char) => c)
  
  var graph = fromGrid(grid, Cross, exampleIsConnected, exampleValueFunc)
  echo $graph
