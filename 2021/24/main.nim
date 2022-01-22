# nim r  -d:danger  -d:lto --passC:-march=native --threads:on --hints:off --tlsEmulation:off .\main.nim
import std/[strutils, strformat, math, macros, times, monotimes, locks, cpuinfo]
import benchy, weave, taskpools

type
  OpCode = enum
    inp,
    add,
    mul,
    intdiv = "div",
    intmod = "mod",
    eql

  Register = enum
    x, y, z, w

  Rhs = enum
    reg,
    lit

  Instruction = object
    op: OpCode
    lhsReg: Register 
    case rhs: Rhs
      of reg:
        rhsReg: Register
      of lit:
        rhsLit: int

  VmState = object
    registers*: array[Register, int]
    stack*: seq[int]

proc parseInstructions*(lines: seq[string]): seq[Instruction] =
  for line in lines:
    let splitted = line.splitWhitespace()
    assert splitted.len in {2, 3}
    var newInstr: Instruction
    newInstr.op = parseEnum[OpCode](splitted[0])
    newInstr.lhsReg = parseEnum[Register](splitted[1])
    if splitted.len == 3:
      try:
        let rhs = parseEnum[Register](splitted[2])
        newInstr.rhs = reg
        newInstr.rhsReg = rhs
      except ValueError:
        let rhs = parseInt(splitted[2])
        newInstr.rhs = lit
        newInstr.rhsLit = rhs
    result.add newInstr

template getRhs*(vm: VmState, instr: Instruction): int =
  case instruction.rhs:
    of reg:
      vm.registers[instruction.rhsReg]
    of lit:
      instruction.rhsLit

proc stepVm*(vm: var VmState, instruction: Instruction) {.inline.} =
  case instruction.op:
  of inp:
    vm.registers[instruction.lhsReg] = vm.stack.pop()
  of add:
    vm.registers[instruction.lhsReg] += getRhs(vm, instruction)
  of mul:
    vm.registers[instruction.lhsReg] *= getRhs(vm, instruction)
  of intdiv:
    vm.registers[instruction.lhsReg] = vm.registers[instruction.lhsReg] div getRhs(vm, instruction)
  of intmod:
    vm.registers[instruction.lhsReg] = vm.registers[instruction.lhsReg] mod getRhs(vm, instruction)
  of eql:
    vm.registers[instruction.lhsReg] = int(vm.registers[instruction.lhsReg] == getRhs(vm, instruction))


proc runVm*(instructions: seq[Instruction], modelNumber: seq[int]): int =
  ## modelNumber must be given in reverse order
  assert modelNumber.len == 14
  var vm = VmState(stack: modelNumber)
  for instr in instructions:
    vm.stepVm(instr)
  result = vm.registers[z]

proc getRhsNimNode(instr: Instruction): NimNode =
  case instr.rhs
  of reg:
    result = ident($instr.rhsReg)
  of lit:
    result = newLit(instr.rhsLit)

template nthDigit*(i, n: int): int =
  (i div 10^(n-1)) mod 10

macro genCodeFromInstructions*(filename: static string): untyped =
  let lines = staticRead("input.txt").splitLines
  let instructions = parseInstructions(lines)

  var body = nnkStmtList.newTree()

  # define variables x, y, z, w
  body.add nnkVarSection.newTree( 
    nnkIdentDefs.newTree(
      newIdentNode("x"),
      newIdentNode("y"),
      newIdentNode("z"),
      newIdentNode("w"),
      newIdentNode("currentModelIndex"),
      newIdentNode("int"),
      newEmptyNode()
    )
  )

  body.add quote do:
    assert modelNr.len == 14

  for instr in instructions:
    case instr.op:
    of inp:
      let lhs = ident($instr.lhsReg)
      body.add quote do:
        `lhs` = modelNr[13-currentModelIndex]
        currentModelIndex += 1
    of add:
      let lhs = ident($instr.lhsReg)
      let rhs = getRhsNimNode(instr)
      body.add quote do:
        `lhs` += `rhs`
    of mul:
      let lhs = ident($instr.lhsReg)
      let rhs = getRhsNimNode(instr)
      body.add quote do:
        `lhs` *= `rhs`
    of intdiv:
      let lhs = ident($instr.lhsReg)
      let rhs = getRhsNimNode(instr)
      body.add quote do:
        `lhs` = `lhs` div `rhs`
    of intmod:
      let lhs = ident($instr.lhsReg)
      let rhs = getRhsNimNode(instr)
      body.add quote do:
        `lhs` = `lhs` mod `rhs`
    of eql:
      let lhs = ident($instr.lhsReg)
      let rhs = getRhsNimNode(instr)
      body.add quote do:
        `lhs` = int(`lhs` == `rhs`)
  let z = ident("z")
  body.add quote do:
    result = `z`
  result = newTree(nnkStmtList)
  result.add newProc(
    ident"runNative",
    @[ident"int", newIdentDefs(ident"modelNr", nnkBracketExpr.newTree(ident"array", newLit(14), ident"int"))],
    body
  )
  #echo result.repr

genCodeFromInstructions("input.txt")

proc getRhsString*(instr: Instruction): string =
  case instr.rhs:
  of reg:
    $instr.rhsReg
  of lit:
    $instr.rhsLit


proc `$`*(instr: Instruction): string =
  case instr.op:
  of inp:
    $instr.lhsReg & " = new_value"
  of add:
    $instr.lhsReg & " += " & getRhsString(instr)
  of mul:
    $instr.lhsReg & " *= " & getRhsString(instr)
  of intdiv:
    $instr.lhsReg & " /= " & getRhsString(instr)
  of intmod:
    $instr.lhsReg & " %= " & getRhsString(instr)
  of eql:
    $instr.lhsReg & " == " & getRhsString(instr)

proc `$`(s: seq[Instruction]): string =
  for instr in s:
    result &= $instr & "\n"

proc `<`*(a1, a2: array[14, int]): bool {.inline.} =
  for i in countdown(13, 1):
    if a1[i] < a2[i]:
      return true
    elif a1[i] > a2[i]:
      return false

proc run(): array[14, int] = 
  let startT = epochTime()
  var resPointer = result.addr
  var resLock: Lock
  resLock.initLock()
  let lockAddr = resLock.addr
  init(Weave)
  parallelFor a1 in 1 .. 9:
    captures: {resPointer, lockAddr}
    parallelFor a2 in 1 .. 9:
      captures: {a1, resPointer, lockAddr}
      parallelFor a3 in 1 .. 9:
        captures: {a1, a2, resPointer, lockAddr}
        parallelFor a4 in 1 .. 9:
          captures: {a1, a2, a3, resPointer, lockAddr}
          parallelFor a5 in 1 .. 9:
            captures: {a1, a2, a3, a4, resPointer, lockAddr}
            parallelFor a6 in 1 .. 9:
              captures: {a1, a2, a3, a4, a5, resPointer, lockAddr}
              parallelFor a7 in 1 .. 9:
                captures: {a1, a2, a3, a4, a5, a6, resPointer, lockAddr}
                parallelFor a8 in 1 .. 9:
                  captures: {a1, a2, a3, a4, a5, a6, a7, resPointer, lockAddr}
                  for a9 in countdown(9, 1):
                    for a10 in countdown(9, 1):
                      for a11 in countdown(9, 1):
                        for a12 in countdown(9, 1):
                          for a13 in countdown(9, 1):
                            for a14 in countdown(9, 1):
                              let modelNr = [a14, a13, a12, a11, a10, a9, a8, a7, a6, a5, a4, a3, a2, a1]
                              let res = runNative(modelNr)
                              if unlikely(res == 0):
                                withLock(lockAddr[]):
                                  if resPointer[] < modelNr:
                                    resPointer[] = modelNr
                                    echo "New champ: ", resPointer[]
                                    #add to file so all are recorded.
  syncRoot(Weave)
  exit(Weave)
  resLock.deinitLock()
  let n = 9 ^ 14
  let duration = epochTime() - startT
  echo &"Total duration: {duration} sec \nPer iteration: {duration / n.float} sec (over {n} iterations)\nRequired time: {duration / n.float * float(9^14) / 3600.float / 24.float} days"

proc runSerial(): array[14, int] = 
  let startT = epochTime()
  var resPointer = result.addr
  var resLock: Lock
  resLock.initLock()
  let lockAddr = resLock.addr
  for a1 in 1 .. 9:
    for a2 in 1 .. 9:
      for a3 in 1 .. 9:
        for a4 in 1 .. 9:
          for a5 in 1 .. 9:
            for a6 in 1 .. 9:
              for a7 in 1 .. 9:
                for a8 in 1 .. 9:
                  for a9 in countdown(9, 1):
                    for a10 in countdown(9, 1):
                      for a11 in countdown(9, 1):
                          let modelNr = [9, 9, 9, a11, a10, a9, a8, a7, a6, a5, a4, a3, a2, a1]
                          let res = runNative(modelNr)
                          if unlikely(res == 0):
                            withLock(lockAddr[]):
                              if resPointer[] < modelNr:
                                resPointer[] = modelNr
                                echo "New champ: ", resPointer[]
  resLock.deinitLock()
  let n = 9 ^ 11
  let duration = epochTime() - startT
  echo &"Total duration: {duration} sec \nPer iteration: {duration / n.float} sec (over {n} iterations)\nRequired time: {duration / n.float * float(9^14) / 3600.float / 24.float} days"

proc taskProc(firstDigit: int): array[14, int] =
  var maximum: array[14, int]
  for a2 in 1 .. 9:
    for a3 in 1 .. 9:
      for a4 in 1 .. 9:
        for a5 in 1 .. 9:
          for a6 in 1 .. 9:
            for a7 in 1 .. 9:
              for a8 in 1 .. 9:
                for a9 in countdown(9, 1):
                  for a10 in countdown(9, 1):
                    for a11 in countdown(9, 1):
                      let modelNr = [9, 9, 9, a11, a10, a9, a8, a7, a6, a5, a4, a3, a2, firstDigit]
                      let res = runNative(modelNr)
                      if unlikely(res == 0):
                        if maximum < modelNr:
                          maximum = modelNr
                          echo "New champ: ", maximum

proc runTask(): array[14, int] = 
  let startT = epochTime()
  var nthreads = countProcessors()
  echo &"Using {nthreads} threads!"
  var tp = Taskpool.new(num_threads = nthreads)
  var pendingThreads: array[9, taskpools.FlowVar[array[14, int]]] 
  for i in 1 .. 9:
    pendingThreads[i-1] = tp.spawn taskProc(i)
  var maximum: array[14, int]
  for i in 0 .. 8:
    let localMax = sync(pendingThreads[i])
    if maximum < localMax:
      maximum = localMax
      echo "New global champ: ", maximum
  tp.syncAll()
  tp.shutdown()
  let n = 9 ^ 11
  let duration = epochTime() - startT
  echo &"Total duration: {duration} sec \nPer iteration: {duration / n.float} sec (over {n} iterations)\nRequired time: {duration / n.float * float(9^14) / 3600.float / 24.float} days"

proc runMin(): array[14, int] = 
  let startT = epochTime()
  result = [9, 8, 3, 9, 3, 6, 5, 9, 9, 9, 2, 9, 1, 1]
  var resPointer = result.addr
  var resLock: Lock
  resLock.initLock()
  let lockAddr = resLock.addr
  init(Weave)
  parallelFor a1 in 1 .. 1:
    captures: {resPointer, lockAddr}
    parallelFor a2 in 1 .. 1:
      captures: {a1, resPointer, lockAddr}
      parallelFor a3 in 1 .. 9:
        captures: {a1, a2, resPointer, lockAddr}
        parallelFor a4 in 1 .. 2:
          captures: {a1, a2, a3, resPointer, lockAddr}
          parallelFor a5 in 1 .. 9:
            captures: {a1, a2, a3, a4, resPointer, lockAddr}
            parallelFor a6 in 1 .. 9:
              captures: {a1, a2, a3, a4, a5, resPointer, lockAddr}
              parallelFor a7 in 1 .. 9:
                captures: {a1, a2, a3, a4, a5, a6, resPointer, lockAddr}
                parallelFor a8 in 1 .. 5:
                  captures: {a1, a2, a3, a4, a5, a6, a7, resPointer, lockAddr}
                  for a9 in 1 .. 6:
                    for a10 in 1 .. 3:
                      for a11 in 1 .. 9:
                        for a12 in 1 .. 3:
                          for a13 in 1 .. 8:
                            for a14 in 1 .. 9:
                              let modelNr = [a14, a13, a12, a11, a10, a9, a8, a7, a6, a5, a4, a3, a2, a1]
                              let res = runNative(modelNr)
                              if unlikely(res == 0):
                                withLock(lockAddr[]):
                                  if modelNr < resPointer[]:
                                    resPointer[] = modelNr
                                    echo "New champ: ", resPointer[]
                                    #add to file so all are recorded.
  syncRoot(Weave)
  exit(Weave)
  resLock.deinitLock()
  let n = 9 ^ 14
  let duration = epochTime() - startT
  echo &"Total duration: {duration} sec \nPer iteration: {duration / n.float} sec (over {n} iterations)\nRequired time: {duration / n.float * float(9^14) / 3600.float / 24.float} days"


let lines = readFile("input.txt").splitLines
let instructions = parseInstructions(lines)
let modelNr = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
let modelNr2 = @[9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9]

#echo runVm(instructions, modelNr)

#echo instructions

# echo runNative(modelNr)
# echo runNative(modelNr) == runVm(instructions, modelNr)
# echo runNative(modelNr2) == runVm(instructions, modelNr2)

#echo run()
#echo run2()
#echo run3() # 4 first loops parallel
# finished around 15:45

#discard runSerial()
#echo run() # 87s before, 41s with tlsEmulation:off, 72s with it on
#discard runTask()
echo runMin()

#let n = int(7e8)
#[ timeIt "VM": # 4.5 months
  for i in 0 .. n:
    keep runVm(instructions, modelNr)
    keep runVm(instructions, modelNr2) ]#

#[ timeit "Native":
  for i in 0 .. n:
    keep runNative(modelNr)
    keep runNative(modelNr2) ]#





echo 9^14 / 7e8.int / 3600 / 24

# max: [9, 8, 3, 9, 9, 9, 5, 9, 9, 9, 2, 9, 4, 7]
    
  