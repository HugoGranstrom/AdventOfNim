include prelude
import std / [strscans, algorithm]

let input = """
7 6 4 2 1
1 2 7 8 9
9 7 6 2 1
1 3 2 4 5
8 6 4 4 1
1 3 6 7 9"""

proc sign(x: int): int =
  (x > 0).int - (x < 0).int

proc removeIndex[T](s: seq[T], index: int): seq[T] =
  result = s[0..<index] & s[index+1..^1]

proc parseInput(input: string): seq[seq[int]] =
    for line in input.splitLines:
        var report: seq[int]
        for num in line.splitWhitespace:
            report.add num.parseInt
        result.add report

proc isValid1(report: seq[int]): bool =
    let direction = sign(report[1] - report[0])
    for i in 0 .. report.high - 1:
        let diff = report[i+1] - report[i]
        if not(sign(diff) == direction and abs(diff) in 1..3):
            return false
    return true

proc solution1(input: string): int =
    let reports = parseInput(input)
    for report in reports:
        if report.isValid1:
            result += 1

proc isValid2(report: seq[int], nested: bool): bool =
    let direction = sign(report[1] - report[0])
    for i in 0 .. report.high - 1:
        let diff = report[i+1] - report[i]

        if sign(diff) != direction or abs(diff) notin 1..3:
            if nested: return false
            for errorIndex in 0 .. report.high:
                let fixedReport = report.removeIndex(errorIndex)
                if fixedReport.isValid2(nested=true):
                    return true
            # if no fix was found, return false
            return false
            
            
    return true

proc solution2(input: string): int =
    let reports = parseInput(input)
    for report in reports:
        if report.isValid2(nested=false):
            result += 1

proc main() =
    let input = readFile("input.txt")
    echo "solution1: ", solution1(input)
    echo "solution2: ", solution2(input)

when isMainModule:
    main()