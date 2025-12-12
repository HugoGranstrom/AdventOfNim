import batteries
import std / [strscans, algorithm, math]
import graphs

proc parseInput(input: string): Graph[string] =
  var t: Table[string, seq[string]]
  for line in input.strip.splitLines:
    let current = line.split(": ")[0]
    let others = line.split(": ")[1].split
    t[current] = others
  fromTable(t)

proc part1(input: string): int =
  let graph = parseInput(input)
  let startNode = graph.findNodeWith(it.value == "you")
  let endNode = graph.findNodeWith(it.value == "out")
  var visited: seq[GraphNode[string]]
  var cache: Table[GraphNode[string], seq[Path[string]]]
  let paths = graph.allPaths(startNode, endNode, visited, cache)
  paths.len

proc part2(input: string): int =
  let graph = parseInput(input)
  let svr = graph.findNodeWith(it.value == "svr")
  let dac = graph.findNodeWith(it.value == "dac")
  let fft = graph.findNodeWith(it.value == "fft")
  let endNode = graph.findNodeWith(it.value == "out")
  var visited: seq[GraphNode[string]]
  var cache: Table[GraphNode[string], seq[Path[string]]]
  let svr2fft = graph.allPaths(svr, fft, visited, cache).len
  echo "svr2fft: ", svr2fft
  cache.reset()
  let dac2out = graph.allPaths(dac, endNode, visited, cache).len
  echo "dac2out: ", dac2out
  cache.reset()
  let fft2dac = graph.allPaths(fft, dac, visited, cache).len
  echo "fft2dac: ", fft2dac
  svr2fft * fft2dac * dac2out


let testInput = """
aaa: you hhh
you: bbb ccc
bbb: ddd eee
ccc: ddd eee fff
ddd: ggg
eee: out
fff: out
ggg: out
hhh: ccc fff iii
iii: out
"""

let testInput2 = """
svr: aaa bbb
aaa: fft
fft: ccc
bbb: tty
tty: ccc
ccc: ddd eee
ddd: hub
hub: fff
eee: dac
dac: fff
fff: ggg hhh
ggg: out
hhh: out
"""

when isMainModule:
  let realInput = readFile("input.txt")
  let input = realInput
  #let answer1 = part1(input)
  #echo "Part 1: ", answer1
  let answer2 = part2(input)
  echo "Part 2: ", answer2