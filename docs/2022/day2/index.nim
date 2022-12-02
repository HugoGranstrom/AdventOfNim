import nimib, p5

nbInit
nbUseP5

nbText: "# Advent of Code 2022 - Day 2 - Rock Paper Scissors"

let input = readFile("input.txt")

nbJsFromCode(input):
  import std / [tables, strutils, strscans, math]

  type
    Hand = enum
      Rock, Paper, Scissor

    Match = object
      left, right: Hand
      start_t: float

  let loseTable = {Rock: Paper, Scissor: Rock, Paper: Scissor}.toTable
  let winTable = {Rock: Scissor, Scissor: Paper, Paper: Rock}.toTable
  let leftTab = {'A': Rock, 'B': Paper, 'C': Scissor}.toTable
  let rightTab = {'X': Rock, 'Y': Paper, 'Z': Scissor}.toTable

  proc readInput(input: string, leftMap, rightMap: tables.Table[char, Hand]): tuple[left: seq[Hand], right: seq[Hand]] =
    for line in input.splitLines:
      let (success, l, r) = scanTuple(line, "$c $c")
      assert success
      result.left.add leftMap[l]
      result.right.add rightMap[r]

  template rotate(angle: float, body: untyped) =
    push()
    rotate(angle)
    body
    pop()

  template translate(x, y: PNumber, body: untyped) =
    push()
    translate(x, y)
    body
    pop()

  let hands = readInput(input, leftTab, rightTab)
  var matches: seq[Match]
  for i in 0 .. hands.left.high:
    matches.add Match(left: hands.left[i], right: hands.right[i], start_t: if i < 200: i*0.015 else: i*0.01)
  
  let n_matches = matches.len # 2500 -> 50x50
  let match_grid = 50
  var t = 0.0
  let dt = 1 / 60
  let period = 0.5
  let w = 2*math.PI/period
  let matchLength = 2*period
  let width = 900
  let height = 300
  let eachHeight = height div match_grid
  let eachWidth = width div (match_grid)

  let emojiTable = {Rock: "✊", Paper: "🤚", Scissor: "✌️"}.toTable
  let leftHandEmoji = "🤜"
  let rightHandEmoji = "🤛"
  let winEmoji = "✅"
  let loseEmoji = "❌"
  let drawEmoji = "➖"

  proc drawMatch(m: Match) =
    ## Draws a single match
    push()
    let x1 = 0
    let y1 = 0
    let x2 = x1 + eachHeight
    let y2 = y1

    let localTime = t - m.start_t

    if localTime < 0:
      # Before match has started
      text(leftHandEmoji, x1, y1)
      text(rightHandEmoji, x2, y2)
    elif localTime < matchLength:
      # Match has started, shake hands
      rotate(0.5*(sin(w*localTime) - 0.3)):
        text(leftHandEmoji, x1, y1)
      translate(eachHeight, 0):
        rotate(-0.5*(sin(w*localTime) - 0.3)):
          text(rightHandEmoji, x1, y1)
    elif localTime in matchLength .. matchLength + 2.0:
      # Match has ended, show result
      text(emojiTable[m.left], x1, y1)
      text(emojiTable[m.right], x2, y2)
    else:
      if winTable[m.right] == m.left:
        text(winEmoji, x1, y1)
      elif loseTable[m.right] == m.left:
        text(loseEmoji, x1, y1)
      else:
        text(drawEmoji, x1, y1)

    pop()

  setup:
    createCanvas(width, height)
    background(200)
    textSize(eachHeight - 1)

  var scaleFactor = 20.PNumber
  let scaleTime = 20.0
  draw:
    background(200)
    scale(scaleFactor)
    # First scale fast and then slower
    if t < scaleTime / 3:
      scaleFactor = lerp(20, 3, t/(scaleTime/3))
    elif t in scaleTime / 3 .. scaleTime:
      scaleFactor = lerp(3, 1, (t - scaleTime/3) / (2/3*scaleTime))
    else:
      scaleFactor = 1
    # Draw every match
    for i in 0 ..< min(int(match_grid / scaleFactor) + 1, matchGrid):
      translate(0, (i+1)*eachHeight):
          for j in 0 ..< min(int(match_grid / scaleFactor) + 1, matchGrid): 
            translate(j*eachWidth, 0):
              let index = j + i*match_grid
              let m = matches[index]
              #m.start_t = index * 0.1
              m.drawMatch()

    t += dt
  
  keyPressed:
    if key == "s":
      saveGif("day2", 30)

nbText: hlMd"""
The input for today contained 2500 games of Rock paper scissor. The above animation shows all of those games visualized
using [p5nim](https://github.com/pietroppeter/p5nim), a wrapper of P5.js for Nim. It starts off with both players getting
ready to play (hands are still), then they start shaking their hands and reveal their choice. The left one is the elfs choice
and the right one is your choice. After the game an emoji will show the result of the game, a green checkbox means you won that
match, a dash means it was a draw and a red cross means you lost.  
"""

nbSave