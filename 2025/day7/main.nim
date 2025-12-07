import batteries
import std / [strscans, algorithm, math]
import grids, graphs

type
  Splitter* = object
    value: char
    coord: GridCoordinate
    acc: int

proc isBelow*(askee: GridCoordinate, question: GridCoordinate): bool =
  askee.x == question.x and askee.y - 1 == question.y

proc isBeside*(askee: GridCoordinate, question: GridCoordinate): bool =
  askee.y == question.y and abs(askee.x - question.x) == 1

proc isConnected(grid: Grid[char], center: GridCoordinate, neighbour: GridCoordinate): bool =
  if grid[center] == '.' and neighbour.isBelow center:
    true
  elif grid[center] == '^' and center.isBeside neighbour:
    true
  elif grid[center] == 'S' and neighbour.isBelow center:
    true
  else:
    false

proc valueFunc(grid: Grid[char], coord: GridCoordinate): Splitter =
  Splitter(value: grid[coord], coord: coord)

proc parseInput(input: string): Graph[Splitter] =
  let grid = parseCharGrid[char](input.strip)
  grid.fromGrid(mode=Cross, isConnectedFunc=isConnected, valueFunc=valueFunc)

proc trimOrphans*(graph: Graph[Splitter]): Graph[Splitter] =
  let startNode = graph.findNodeWith(it.value.value == 'S')
  var nodesToRemove: seq[GraphNode[Splitter]]
  for endNode in graph.nodes:
    if endNode != startNode:
      if aStarSearch(graph, startNode, endNode).isNil:
        nodesToRemove.add endNode
  for nodeToRemove in nodesToRemove:
    for node in graph.nodes:
      if nodeToRemove in node.links:
        node.links.excl nodeToRemove
    graph.nodes.excl nodeToRemove
  graph

proc findNextCarret(node: GraphNode[Splitter]): GraphNode[Splitter] =
  for neigh in node.links:
    if neigh.value.value == '^':
      return neigh
  for neigh in node.links:
    let next = findNextCarret(neigh)
    if not next.isNil:
      return next

proc simplifyGraph*(graph: Graph[Splitter]): Graph[Splitter] =
  # remove all . and connect all the ^ instead
  for node in graph.findNodesWith(it.value.value in ['^', 'S']):
    var replaceNodes: seq[(GraphNode[Splitter], GraphNode[Splitter])]
    for neigh in node.links:
      if neigh.value.value == '.':
        let nextCarretNode = neigh.findNextCarret
        replaceNodes.add (neigh, nextCarretNode)
    for (oldNode, newNode) in replaceNodes:
      node.links.excl oldNode
      if not newNode.isNil:
        node.links.incl newNode
  graph.trimOrphans

# proc addFinalAccumulators*(graph: Graph[Splitter]): Graph[Splitter] =
#   for node in graph.nodes:
#     if node.links.len == 0:
#       let newNode = GraphNode[Splitter](value: Splitter(value: 'a'))
#       node.links.incl newNode
#       graph.nodes.incl newNode
#   graph

proc part1(input: string): int =
  let graph = parseInput(input).trimOrphans.simplifyGraph
  graph.nodes.len - 1

# function that given a node returns the number of possible ways down!
proc calcNumPaths(node: GraphNode[Splitter], visited: var HashSet[GraphNode[Splitter]]): int =
  let neighbours = collect(newSeq):
    for neigh in node.links:
      if neigh notin visited:
        neigh
  if neighbours.len == 0:
    return 1
  for neigh in neighbours:
    result += calcNumPaths(neigh, visited)

proc part2(input: string): int =
  let graph = parseInput(input).trimOrphans.simplifyGraph
  #echo reversedGraph
  var nodesPerLevel: seq[seq[GraphNode[Splitter]]]
  for y in 0 .. input.countLines:
    var thisLevel: seq[GraphNode[Splitter]]
    for node in graph.nodes:
      if node.value.coord.y == y:
        thisLevel.add node
    if thisLevel.len > 0:
      nodesPerLevel.add thisLevel
  
  let startNode = graph.findNodeWith(it.value.value == 'S')
  startNode.value.acc = 1
  for level, nodes in nodesPerLevel:
    if level == 0: continue
    let previousNodes = nodesPerLevel[level-1]
    for prevNode in previousNodes:
      for neigh in prevNode.links:
        neigh.value.acc += prevNode.value.acc
  
  for line in nodesPerLevel:
    echo line.mapIt(it.value.acc)

  sum(nodesPerLevel[^1].mapIt(it.value.acc))

let testInput = """
.......S.......
...............
.......^.......
...............
......^.^......
...............
.....^.^.^.....
...............
....^.^...^....
...............
...^.^...^.^...
...............
..^...^.....^..
...............
.^.^.^.^.^...^.
...............
"""

when isMainModule:
  let realInput = readFile("input.txt")
  let input = testInput
  let answer1 = part1(input)
  echo "Part 1: ", answer1
  let answer2 = part2(input)
  echo "Part 2: ", answer2