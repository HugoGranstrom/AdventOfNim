import batteries
import grids, graphs

let testInput = """
Sabqponm
abcryxxl
accszExk
acctuvwj
abdefghi"""

func charToVal(c: char): int =
  if c == 'S':
    ord('a')
  elif c == 'E':
    ord('z')
  else:
    ord(c)

func isConnected(grid: Grid[char], center, neigh: GridCoordinate): bool =
  let c = grid[center]
  let n = grid[neigh]
  n.charToVal <= c.charToVal + 1

proc valueFunc*(grid: Grid[char], coord: GridCoordinate): GridValue[char] =
  GridValue[char](value: grid[coord], coord: coord)

proc parseGraph(s: string): Graph[GridValue[char]] =
  let grid = parseCharGrid[char](s.strip)
  let graph = fromGrid(grid, Cross, isConnected, valueFunc)
  graph

proc part1(graph: Graph[GridValue[char]]): int =
  let startNode = graph.findNodeWith(it.value.value == 'S')
  let endNode = graph.findNodeWith(it.value.value == 'E')
  discard breadthSearch(graph, startNode, endNode)
  let path = aStarSearch(graph, startNode, endNode)
  echo path
  path.cost.round.int

let graphTest = parseGraph(testInput)
let graph = readFile("input.txt").parseGraph
echo part1(graph)

