include prelude, std / [strscans, strutils, tables, algorithm]

type
  FileKind = enum
    file, dir
  FileObj = ref object
    size: int
    name: string
    parent: FileObj
    case kind: FileKind
    of file:
      discard
    of dir:
      children: Table[string, FileObj]

proc `$`(f: FileObj, indent=0): string =
  case f.kind:
  of dir:
    let dirName = if f.name == "/": "/ " else: f.name & "/ "
    result = "    ".repeat(indent) & dirName & $f.size
    for (key, file) in f.children.pairs:
      result &= "\n" & `$`(file, indent+1)
  of file:
    result = "    ".repeat(indent) & f.name & " " & $f.size

proc cmp(a, b: FileObj): int =
  cmp(a.size, b.size)

proc addFile(f: FileObj, dirName: string, size: int = 0, kind: FileKind = dir): FileObj =
  assert dirName notin f.children
  result = FileObj(size: size, name: dirName, kind: kind, parent: f)
  f.children[dirName] = result

proc parseFileTree(input: string): FileObj =
  result = FileObj(size: 0, name: "/", kind: dir, parent: nil)
  var currentFile = result
  for command in input.split("$"):
    if command.isEmptyOrWhitespace:
      continue
    let lines = command.strip().splitLines
    if lines[0].startsWith("cd"):
      let dest = lines[0].split(" ")[^1]
      if dest == "..":
        currentFile = currentFile.parent
      elif dest == "/":
        currentFile = result
      elif dest in currentFile.children:
        currentFile = currentFile.children[dest]
      else:
        let newDir = currentFile.addFile(dest)
        currentFile = newDir
    elif lines[0].startsWith("ls"):
      for line in lines[1 .. ^1]:
        if line.startsWith("dir"):
          let dirName = line.split(" ")[^1]
          if dirName notin currentFile.children:
            let _ = currentFile.addFile(dirName)
        else:
          let spli = line.split(" ")
          let size = parseInt(spli[0])
          let fName = spli[1]
          if fName notin currentFile.children:
            let newFile = currentFile.addFile(fName, size=size, kind=file)

proc calcDirSizes(root: FileObj): int =
  case root.kind:
  of dir:
    for child in root.children.values:
      root.size += child.calcDirSizes()
    root.size
  of file:
    root.size

iterator walkTree(f: FileObj): FileObj {.closure.} =
  yield f
  case f.kind
  of file:
    discard
  of dir:
    for child in f.children.values:
      let a = walkTree
      for x in a(child):
        yield x

proc part1(input: string) =
  let fileTree = parseFileTree(input)
  let totSize = fileTree.calcDirSizes()
  var result = 0
  for x in fileTree.walkTree:
    if x.kind == dir and x.size <= 100000:
      result += x.size

  echo "Part 1: ", result

proc part2(input: string) =
  let fileTree = parseFileTree(input)
  let totSize = fileTree.calcDirSizes()
  let diskSpace = 70000000
  let availableSpace = diskSpace - totSize
  let neededSpace = 30000000
  let deleteSize = neededSpace - availableSpace

  var candidates: seq[FileObj]
  for x in fileTree.walkTree:
    if x.kind == dir and x.size >= deleteSize:
      candidates.add x

  candidates.sort(cmp, Ascending)

  echo "Part 2: ", candidates[0].size

let testInput = """
$ cd /
$ ls
dir a
14848514 b.txt
8504156 c.dat
dir d
$ cd a
$ ls
dir e
29116 f
2557 g
62596 h.lst
$ cd e
$ ls
584 i
$ cd ..
$ cd ..
$ cd d
$ ls
4060174 j
8033020 d.log
5626152 d.ext
7214296 k"""

when isMainModule:
  let input = readFile("input.txt")
  part1(input)
  part2(input)