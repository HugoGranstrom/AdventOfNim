import strscans, strutils

proc part1() =
  let f = open("day2.txt")
  var counter = 0
  var lower, upper: int
  var letter, password: string
  for line in f.lines:
    if scanf(line, "$i-$i $w: $w", lower, upper, letter, password):
      let count = password.count(letter)
      if lower <= count and count <= upper:
        counter += 1
  f.close()
  echo counter, " valid passwords"

proc part2() =
  let f = open("day2.txt")
  defer: f.close()
  var counter = 0
  var lower, upper: int
  var letter, password: string
  for line in f.lines:
    if scanf(line, "$i-$i $w: $w", lower, upper, letter, password):
      if $password[lower - 1] == letter xor $password[upper - 1] == letter:
        counter += 1
  echo counter, " valid passwords"

when isMainModule:
  part1()

  part2()
      

