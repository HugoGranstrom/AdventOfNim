import strutils, strscans, std/enumerate

proc isValidPart1(passport: string): bool =
  const required = ["byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid"]
  for r in required:
    if r notin passport:
      return false
  return true

proc part1(): int =
  let data = readFile("day4.txt")
  for passport in data.split("\n\n"):
    if passport.isValidPart1:
      result += 1

proc isValidPart2(passport: string): bool =
  if not passport.isValidPart1: return false
  # All required fields are there in below code
  for i, field in enumerate(passport.splitWhitespace):
    var year: int
    var height: int
    var unit: string
    var color: string
    var id: string
    if scanf(field, "byr:$i", year):
      if year < 1920 or 2002 < year: return false
    elif scanf(field, "iyr:$i", year):
      if year < 2010 or 2020 < year: return false
    elif scanf(field, "eyr:$i", year):
      if year < 2020 or 2030 < year: return false
    elif scanf(field, "hgt:$i$w", height, unit):
      if unit == "cm":
        if height < 150 or 193 < height: return false
      elif unit == "in":
        if height < 59 or 76 < height: return false
      else:
        return false
    elif scanf(field, "hcl:#$+$.", color):
      if color.len != 6: return false
      for c in color:
        if c notin '0'..'9' and c notin 'a'..'f':
          return false
    elif scanf(field, "ecl:$w", color):
      const allowed = ["amb", "blu", "brn", "gry", "grn", "hzl", "oth"]
      if color notin allowed: return false
    elif scanf(field, "pid:$+$.", id):
      if id.len != 9: return false
      try:
        let idInt = parseInt(id)
      except ValueError:
        return false
    elif scanf(field, "cid:$i", year):
      continue
    else:
      return false
  return true
    


proc part2(): int =
  let data = readFile("day4.txt")
  for passport in data.split("\n\n"):
    if passport.isValidPart2:
      result += 1

when isMainModule:
  echo part1(), " valid passports"
  echo part2(), " valid passports"