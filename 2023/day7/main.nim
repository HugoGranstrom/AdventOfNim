include std / prelude
import std / [strscans, algorithm, math]

type
  HandType = enum
    HighCard,
    OnePair,
    TwoPair,
    ThreeOfAKind,
    FullHouse,
    FourOfAKind,
    FiveOfAKind
  Hand = tuple[kind: HandType, c1, c2, c3, c4, c5: int]

let convertCard = {
  'A': 14,
  'K': 13,
  'Q': 12,
  'J': 11,
  'T': 10,
  '9': 9,
  '8': 8,
  '7': 7,
  '6': 6,
  '5': 5,
  '4': 4,
  '3': 3,
  '2': 2
}.toTable

proc getHandType(hand: Hand): HandType =
  var cTable: CountTable[int]
  cTable.inc(hand.c1)
  cTable.inc(hand.c2)
  cTable.inc(hand.c3)
  cTable.inc(hand.c4)
  cTable.inc(hand.c5)

  cTable.sort()
  let numbers = cTable.values.toSeq()


  if cTable.len == 1:
    return FiveOfAKind
  elif cTable.len == 2:
    if numbers[0] == 4:
      return FourOfAKind
    elif numbers[0] == 3 and numbers[1] == 2:
      return FullHouse
  elif cTable.len == 3:
    if numbers[0] == 2 and numbers[1] == 2:
      return TwoPair
    elif numbers[0] == 3:
      return ThreeOfAKind
  else:
    if numbers[0] == 2:
      return OnePair
    else:
      return HighCard

proc parseInput(input: string, convertCardTable: Table[char, int]): seq[tuple[hand: Hand, bid: int]] =
  for line in input.strip.splitLines:
    var obj: tuple[hand: Hand, bid: int]
    let bid = line.splitWhitespace()[1].parseInt
    obj.bid = bid

    let handString = line.splitWhitespace()[0]
    obj.hand[1] = convertCardTable[handString[0]]
    obj.hand[2] = convertCardTable[handString[1]]
    obj.hand[3] = convertCardTable[handString[2]]
    obj.hand[4] = convertCardTable[handString[3]]
    obj.hand[5] = convertCardTable[handString[4]]

    obj.hand.kind = getHandType(obj.hand)

    result.add obj


proc part1(input: string): int =
  # Sort tuple according to first handtype and then card values in order
  let hands = parseInput(input, convertCard).sorted()
  for i, (hand, bid) in hands:
    result += (i+1)*bid


let convertCard2 = {
  'A': 14,
  'K': 13,
  'Q': 12,
  'J': 1,
  'T': 10,
  '9': 9,
  '8': 8,
  '7': 7,
  '6': 6,
  '5': 5,
  '4': 4,
  '3': 3,
  '2': 2
}.toTable

proc allHands*(cards: seq[int]): seq[seq[int]] =
  if cards.len == 0:
    return @[@[]]
  
  let restCards = allHands(cards[1..^1])

  if cards[0] == 1:
    for c in 2 .. 14:
      for s in restCards:
        result.add @[c] & s
  else:
    result = restCards.mapIt(@[cards[0]] & it)


proc getHandType2(hand: Hand): Hand =
  let allPossibleHands = allHands(@[hand.c1, hand.c2, hand.c3, hand.c4, hand.c5])
  let types = allPossibleHands.mapIt(getHandType((HighCard, it[0], it[1], it[2], it[3], it[4])))
  result = hand
  result.kind = types.max


proc part2(input: string): int =
  var hands = parseInput(input, convertCard2)
  for (hand, bid) in hands.mitems:
    hand = getHandType2(hand)
  hands.sort()
  for i, (hand, bid) in hands:
    result += (i+1)*bid


let testInput = """
32T3K 765
T55J5 684
KK677 28
KTJJT 220
QQQJA 483
"""

when isMainModule:
  let realInput = readFile("input.txt")
  let input = realInput
  let answer1 = part1(input)
  echo "Part 1: ", answer1
  let answer2 = part2(input)
  echo "Part 2: ", answer2