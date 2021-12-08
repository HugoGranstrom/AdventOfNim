import std/[strutils, sequtils, math, strscans, tables, algorithm, sets]

proc part1(input: seq[(seq[string], seq[string])]): int =
  for (left, right) in input:
    for digit in right:
      if digit.len in [2, 4, 3, 7]:
        result += 1

proc part2(input: seq[(seq[string], seq[string])]): int =
  # 0
  #1 2
  # 3
  #4 5
  # 6
  let tableKnowns = {2: @[2, 5], 4: @[1, 2, 3, 5], 3: @[0, 2, 5], 7: @[0, 1, 2, 3, 4, 5, 6]}.toTable # len -> indices
  # knowns: 1, 4, 7, 8
  let expectedLens = {0: 6, 1: 2, 2: 5, 3: 5, 4: 4, 5: 5, 6: 6, 7: 3, 8: 7, 9: 6}

  # digit -> indices
  let digitToIndices = {1: @[2, 5].toHashSet, 2: @[0, 2, 3, 4, 6].toHashSet, 3: @[0, 2, 3, 5, 6].toHashSet, 
                      4: @[1, 2, 3, 5].toHashSet, 5: @[0, 1, 3, 5, 6].toHashSet, 6: @[0, 1, 3, 4, 5, 6].toHashSet,
                      7: @[0, 2, 5].toHashSet, 8: @[0,1,2,3,4,5,6].toHashSet, 9: @[0,1,2,3,5,6].toHashSet}.toTable

  for (left, right) in input:
    # Use this table to store all candiadate letters for each position
    var table: array[7, HashSet[char]]
    # initialize table
    for i in 0 .. table.high:
      table[i] = ['a', 'b', 'c', 'd', 'e', 'f', 'g'].toHashSet
    # loop through the known-length values and adjust the table
    for num in left.concat(right):
      if num.len in tableKnowns:
        # if we know the length
        for i in tableKnowns[num.len]:
          table[i] = table[i].intersection(num.toHashSet)
    
    let group1 = table[0] - (table[2] + table[5]) # The top
    doAssert group1.len == 1 #
    let group2 = table[2] + table[5] # the right
    doAssert group2.len == 2
    let group3 = (table[1] + table[3]) - group2 # the middle-left
    doAssert group3.len == 2
    let group4 = (table[4] + table[6]) - (group1 + group2 + group3) # the bottom left
    doAssert group4.len == 2
    var resultStr: string
    for number in right:
      if number.len == 2:
        resultStr.add '1'
      elif number.len == 3:
        resultStr.add '7'
      elif number.len == 4:
        resultStr.add '4'
      elif number.len == 7:
        resultStr.add '8'
      elif number.len == 6:
        # either 0 or 6 or 9
        let numberSet = number.toHashSet
        if group2 < numberSet and group4 < numberSet:
          resultStr.add '0'
        elif group4 < numberSet: # if both, it must be 6
          resultStr.add '6'
        elif group2 < numberSet:
          resultStr.add '9'
      elif number.len == 5:
        # Either 2, 5 or 3
        let numberSet = number.toHashSet
        if group3 < numberSet: # only 5 has both
          resultStr.add '5'
        elif group2 < numberSet: # only 3 has both right segments
          resultStr.add '3'
        elif group4 < numberSet: # only 2 has both
          resultStr.add '2'
        else:
          doAssert false
      else:
        doAssert false
    result += parseInt(resultStr)


var input: seq[(seq[string], seq[string])]
for line in "input.txt".lines:
  let splitted = line.split("|")
  let left = splitted[0].splitWhitespace()
  let right = splitted[1].splitWhitespace()
  input.add (left, right)

var testInput: seq[(seq[string], seq[string])]
let testText = """be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb | fdgacbe cefdb cefbgd gcbe
edbfga begcd cbg gc gcadebf fbgde acbgfd abcde gfcbed gfec | fcgedb cgb dgebacf gc
fgaebd cg bdaec gdafb agbcfd gdcbef bgcad gfac gcb cdgabef | cg cg fdcagb cbg
fbegcd cbd adcefb dageb afcb bc aefdc ecdab fgdeca fcdbega | efabcd cedba gadfec cb
aecbfdg fbg gf bafeg dbefa fcge gcbea fcaegb dgceab fcbdga | gecf egdcabf bgf bfgea
fgeab ca afcebg bdacfeg cfaedg gcfdb baec bfadeg bafgc acf | gebdcfa ecba ca fadegcb
dbcfg fgd bdegcaf fgec aegbdf ecdfab fbedc dacgb gdcebf gf | cefg dcbef fcge gbcadfe
bdfegc cbegaf gecbf dfcage bdacg ed bedf ced adcbefg gebcd | ed bcgafe cdgba cbgef
egadfb cdbfeg cegd fecab cgb gbdefca cg fgcdab egfdb bfceg | gbdfcae bgc cg cgb
gcafb gcf dcaebfg ecagb gf abcdeg gaef cafbge fdbac fegbdc | fgae cfgab fg bagce"""

let testTextbug = "bafegdc becgdf cdebfa ecg bfedc gc fcbge eafgdc cdbg aefgb | fbecd acfedb gbcd cfagde"
for line in testText.splitLines:
  let splitted = line.split("|")
  let left = splitted[0].splitWhitespace()
  let right = splitted[1].splitWhitespace()
  testInput.add (left, right)

echo "Part 1 (test): ", part1(testInput)
echo "Part 1: ", part1(input)
echo "Part 2 (test): ", part2(testInput)
echo "Part 2: ", part2(input)