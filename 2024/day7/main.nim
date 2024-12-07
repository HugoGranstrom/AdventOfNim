include prelude
import std / [strscans, algorithm]
import itertools

let input = """
190: 10 19
3267: 81 40 27
83: 17 5
156: 15 6
7290: 6 8 6 15
161011: 16 10 13
192: 17 8 14
21037: 9 7 18 13
292: 11 6 16 20"""
 
proc parseInput(input: string): seq[tuple[res: int, numbers: seq[int]]] =
    for line in input.splitLines:
        let splitLine = line.split(':')
        let res = splitLine[0].strip.parseInt
        let numbers = splitLine[1].strip.splitWhitespace.mapIt(it.parseInt)
        result.add (res, numbers)

func addInts(a, b: int): int = a + b
func mulInts(a, b: int): int = a * b
func concatInts(a, b: int): int =
    parseInt($a & $b)

proc isPossible(line: tuple[res: int, numbers: seq[int]], ops: seq[proc(a, b: int): int {.nimcall.}]): bool =
    let nOps = line.numbers.len - 1
    for opsList in ops.product(repeat=nOps):
        var current: int = line.numbers[0]
        for (op, n) in zip(opsList, line.numbers[1..^1]):
            current = op(current, n)
        if current == line.res:
            return true
    return false


proc solution1(input: string): int =
    let ops: seq[proc(a, b: int): int {.nimcall.}] = @[addInts, mulInts]
    let lines = input.parseInput()
    for line in lines:
        if line.isPossible(ops):
            result += line.res

proc solution2(input: string): int =
    let ops: seq[proc(a, b: int): int {.nimcall.}] = @[addInts, mulInts, concatInts]
    let lines = input.parseInput()
    for line in lines:
        if line.isPossible(ops):
            result += line.res

    

proc main() =
    let input = readFile("input.txt")
    echo "solution1: ", solution1(input)
    echo "solution2: ", solution2(input)

when isMainModule:
    main()
