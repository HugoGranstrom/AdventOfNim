include prelude
import std / [strscans, algorithm]

let input = """
3   4
4   3
2   5
1   3
3   9
3   3"""

proc parseInput(s: string): (seq[int], seq[int]) =
    for line in s.splitLines:
        let (succ, left, right) = scanTuple(line, "$i$s$i")
        assert succ
        result[0].add left
        result[1].add right

proc solution1(input: string): int =
    let (left, right) = parseInput(input)
    let leftSorted = left.sorted
    let rightSorted = right.sorted
    var totalDistance: int
    for (l, r) in zip(leftSorted, rightSorted):
        let distance = abs(l - r)
        totalDistance += distance
    result = totalDistance

proc solution2(input: string): int =
    let (left, right) = parseInput(input)
    var counts = initCountTable[int]()
    for i in right:
        counts.inc i
    
    for i in left:
        result += i * counts[i]

proc main() =
    let input = readFile("input.txt")
    echo "solution1: ", solution1(input)
    echo "solution2: ", solution2(input)

when isMainModule:
    main()
    