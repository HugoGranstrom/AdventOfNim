include prelude, strformat

proc part(input: string, windowSize: int, part: int) =
  for i in 0 .. input.high - windowSize - 1:
    block innerLoop:
      var cs: seq[char]
      for j in i ..< i + windowSize:
        let c = input[j]
        if c in cs:
          break innerLoop
        cs.add c
      echo &"Part {part}: {i + windowSize}"
      return

let testInput1 = "bvwbjplbgvbhsrlpgdmjqwftvncz"
let testInput2 = "nppdvjthqldpwncqszvftbrmjlhg"
let testInput3 = "nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg"
let testInput4 = "zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw"
let testInput5 = "mjqjpqmgbljsphdztnvjfqwrcgsmlb"

when isMainModule:
  let input = readFile "input.txt"
  part(input, 4, 1)
  part(input, 14, 2)