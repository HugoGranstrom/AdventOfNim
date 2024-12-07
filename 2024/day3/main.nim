include prelude
import std / [strscans, algorithm]
import regex

#let input = """xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))"""
let input = "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))"

proc parseInput(input: string): seq[seq[int]] =
    for line in input.splitLines:
        var report: seq[int]
        for num in line.splitWhitespace:
            report.add num.parseInt
        result.add report

proc solution1(input: string): int =
    let pattern = re2"mul\([0-9]+,[0-9]+\)"
    let matches = input.findAll(pattern)
    for match in matches:
        let (succ, fact1, fact2) = scanTuple(input[match.boundaries], "mul($i,$i)")
        assert succ
        result += fact1 * fact2

proc solution2(input: string): int =
    let mulPattern = re2"mul\([0-9]+,[0-9]+\)"
    let doPattern = re2"do\(\)"
    let dontPattern = re2"don't\(\)"

    var dosAndDonts: seq[tuple[index: int, enabled: bool]]
    for match in input.findAll(doPattern):
        dosAndDonts.add (match.boundaries.a, true)
    for match in input.findAll(dontPattern):
        dosAndDonts.add (match.boundaries.a, false)
    dosAndDonts.sort(Ascending)

    var disallowedIndices: set[0..65535]
    echo dosAndDonts
    var currentAllow = true
    var currentStart = 0
    for (index, allow) in dosAndDonts:
        if not currentAllow:
            disallowedIndices.incl {currentStart .. index}
            echo currentStart .. index
        currentStart = index
        currentAllow = allow
    if not currentAllow:
        echo last
        disallowedIndices.incl {currentStart .. input.len}
    #echo disallowedIndices
    for match in input.findAll(mulPattern):
        if match.boundaries.a notin disallowedIndices:
            let (succ, fact1, fact2) = scanTuple(input[match.boundaries], "mul($i,$i)")
            assert succ
            result += fact1 * fact2

    

proc main() =
    let input = readFile("input.txt")
    echo "solution1: ", solution1(input)
    echo "solution2: ", solution2(input)

when isMainModule:
    main()

# mul\([0-9]+,[0-9]+\)