import batteries, std / [enumerate]

type
  Graph = ref object
    neighbors: seq[Graph]
    score: int
    coord: (int, int)
    elevation: int

proc `$`(g: Graph): string =
  &"Graph(pos: ({g.coord[0]}, {g.coord[1]}), score: {g.score})"

proc cmp(g1, g2: Graph): int =
  cmp(g1.score, g2.score)

proc hash(g: Graph): Hash =
  hash(g.coord)

proc charToElevation(c: char): int =
  assert c in 'a' .. 'z'
  result = ord(c) - ord('a')

iterator neighbors(row, col: int, maxRow, maxCol: int): (int, int) =
  for dim in 0 .. 1:
    for i in [-1, 1]:
      if dim == 0:
        if row + i in 0 .. maxRow:
          yield (row + i, col)
      else:
        if col + i in 0 .. maxCol:
          yield (row, col + i)

proc parseInput(input: string): tuple[starts: seq[Graph], finish: Graph, allNodes: HashSet[Graph]] =
  var elevations: seq[seq[int]]
  var graphs: seq[seq[Graph]]
  var startIndex, endIndex: (int, int)
  for row, line in enumerate(input.splitLines):
    graphs.add @[]
    elevations.add @[]
    for col, c in line:
      let el = charToElevation(
        if c == 'S':
          startIndex = (row, col)
          'a'
        elif c == 'E':
          endIndex = (row, col)
          'z'
        else:
          c
      )
      elevations[^1].add el
      let g = Graph(score: -1, coord: (row, col), elevation: el)
      graphs[^1].add g
      result.allNodes.incl g
      if c == 'S': result.starts = @[g]
      elif c == 'E': result.finish = g

  for row in 0 .. elevations.high:
    for col in 0 .. elevations[0].high:
      let currentElev = elevations[row][col]
      let currentNode = graphs[row][col]
      if currentElev == 0:
        result.starts.add currentNode
      for (neighRow, neighCol) in neighbors(row, col, elevations.high, elevations[0].high):
        let neighElev = elevations[neighRow][neighCol]
        let neighNode = graphs[neighRow][neighCol]
        if neighElev <= currentElev + 1:
          currentNode.neighbors.add neighNode

proc resetGraph(h: HashSet[Graph], start: Graph) =
  for x in h:
    if x == start:
      x.score = 0
    else:
      x.score = -1

proc firstPop[T](l: var seq[T]): T =
  assert l.len > 0
  result = l[0]
  l.delete(0)

proc dijkstra(start, goal: Graph): int =
  var queue: seq[Graph] = @[start]
  while queue.len > 0:
    let current = queue.firstPop()
    for n in current.neighbors:
      if n.score == -1 or n.score > current.score + 1:
        n.score = current.score + 1
        queue.insert(n, upperBound(queue, n))
  result = goal.score


proc part1(input: string) =
  let (starts, goal, allNodes) = parseInput(input)
  allNodes.resetGraph(starts[0])
  let answer = dijkstra(starts[0], goal)
  echo "Part 1: ", answer
  
proc part2(input: string) =
  let (starts, goal, allNodes) = parseInput(input)
  var answer = 10000
  for start in starts:
    allNodes.resetGraph(start)
    let length = dijkstra(start, goal)
    if length > 0:
      answer = min(answer, length)
  echo "Part 2: ", answer

let testInput = """
Sabqponm
abcryxxl
accszExk
acctuvwj
abdefghi"""

when isMainModule:
  let input = readFile("input.txt")
  part1(input)
  part2(input)