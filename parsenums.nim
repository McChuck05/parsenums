# parsenums.nim
# copied from Nim's std/parseutils and std/strutils
# modified by Charles Fout
# October 2026

const
  Digits* = {'0'..'9'}
  HexDigits* = {'0'..'9', 'A'..'F', 'a'..'f'}
  BinaryDigits* = {'0', '1'}
  Signs* = {'+', '-'}
  HexMarks* = {'x', 'X', '#'}
  BinMarks* = {'b', 'B', '%'}
  BinHexShortMarks* = {'%', '#'}
  Dot* = {'.'}

type
  IntOrFloat* = object
    case
    of Invalid: discard
    of IntRep: intval*: int
    of FloatRep: floatval*: float


proc myParseHex*(s: string, number: var int, start: int = 0, maxDigits: int = 0): int {.noSideEffect.} =
  ## Parses a hexadecimal number and stores its value in ``number``.
  ## Hex numbers begin with "0x", "0X", "0#", or "#".
  ## Returns the number of the parsed characters or 0 in case of an error.
  ## If error, the value of ``number`` is 0.
  ##
  ## If ``maxDigits == 0``, the parsing continues until the first non-hex character
  ## or to the end of the string. Otherwise, no more than ``maxDigits`` digits
  ## are parsed, starting after any initial markers.
  ## "_" does not count as a digit.
  runnableExamples:
    var num: int
    doAssert parseHex("4E_69_ED", num) == 8
    doAssert num == 5138925
    doAssert parseHex("X", num) == 0
    doAssert parseHex("#AB4C", num) == 5
    doAssert parseHex("0x_4E_69_ED", num) == 11
    doAssert num == 0xED
    doAssert parseHex("0#_4E_69_ED", num, 3, 2) == 2
    doAssert num == 0x4E
    doAssert parseHex("0#_4E_69_ED", num) == 11
    doAssert num == 237
    doAssert parseHex("4E69ED4E69ED", num) == 12
    doAssert num == 86216859871725

  result = 0
  number = 0
  if s.len <= start or s.len == 0:
    return
  var i = start
  var output = 0
  var foundDigit = false
  var last = start + maxDigits
  last = min(s.len, if maxDigits == 0: s.len else: start + maxDigits)
  last = min(last, 16)  # 16 hex digits in 8 byte int
  if i + 1 < last and s[i] == '0' and (s[i+1] in HexMarks):
    inc(i, 2)
    last = min(last + 2, s.len)
  elif i < last and s[i] == '#':
    inc(i)
    last = min(last + 1, s.len)
  while i < last:
    case s[i]
    of '_':
      last = min(last + 1, s.len)
    of '0'..'9':
      output = output shl 4 or (ord(s[i]) - ord('0'))
      foundDigit = true
    of 'a'..'f':
      output = output shl 4 or (ord(s[i]) - ord('a') + 10)
      foundDigit = true
    of 'A'..'F':
      output = output shl 4 or (ord(s[i]) - ord('A') + 10)
      foundDigit = true
    else: break
    inc(i)
  if foundDigit:
    number = output
    result = i - start


proc myParseBin*(s: string, number: var int, start: int = 0, maxDigits: int = 0): int {.noSideEffect.} =
  ## Parses a binary number and stores its value in ``number``.
  ## Binary numbers begin with "0b", "0B", "0%", or "%", which do not count as digits.
  ## Returns the number of the parsed characters or 0 in case of an error.
  ## If error, the value of ``number`` is 0.
  ##
  ## If ``maxDigits == 0``, the parsing continues until the first non-bin character
  ## or to the end of the string. Otherwise, no more than ``maxDigits`` digits
  ## are parsed starting from after any initial markers.
  ## "_" does not count as a digit.
  runnableExamples:
    var num: int
    doAssert parseBin("0100_1110_0110_1001_1110_1101", num) == 29
    doAssert num == 5138925
    doAssert parseBin("3", num) == 0
    doAssert parseBin("0b_0100_1110_0110_1001_1110_1101", num) == 32
    doAssert num == 0b1110_1101
    doAssert parseBin("0b_0100_1110_0110_1001_1110_1101", num, 3, 9) == 9
    doAssert num == 0b0100_1110
    doAssert parseBin("0%_0100_1110_0110_1001_1110_1101", num) == 32
    doAssert num == 237
    doAssert parseBin("0100111001101001111011010100111001101001", num) == 40
    doAssert num == 336784608873
    doAssert parsebin("%1111", num) == 5
    doAssert num == 15

  result = 0
  number = 0
  if s.len <= start or s.len == 0:
    return
  var i = start
  var output = 0
  var foundDigit = false
  var last = start + maxDigits
  last = min(s.len, if maxDigits == 0: s.len else: start + maxDigits)
  last = min(last, 64)  # 64 binary digits in 8 byte int
  if i + 1 < last and s[i] == '0' and (s[i+1] in BinMarks):
    inc(i, 2)
    last = min(last + 2, s.len)
  elif i < last and s[i] == '%':
    inc(i)
    last = min(last + 1, s.len)
  while i < last:
    case s[i]
    of '_':
      last = min(last + 1, s.len)
    of '0'..'1':
      output = output shl 1 or (ord(s[i]) - ord('0'))
      foundDigit = true
    else: break
    inc(i)
  if foundDigit:
    number = output
    result = i - start


proc myParseInt*(s: string, number: var int, start: int = 0): int {.raises: [].} =
  ## Parses an int into ``number``. This cannot raise an overflow
  ## error. ``high(int)`` is returned for an overflow.
  ## The number of processed character is returned.
  ## Cannot process low(int)
  runnableExamples:
    var res = 0
    discard parseInt("848", res)
    doAssert res == 848

  number = 0
  if unlikely(start >= s.len or start < 0): return
  var minus = false
  var here = start
  if s[start] == '+':
    inc(here)
  elif s[start] == '-':
    inc(here)
    minus = true
  var inbounds = true
  while here < s.len and s[here] in {'0'..'9'}:
    var digit = ord(s[here]) - ord('0')
    if inbounds and number <= (high(int) - digit) div 10:
      number = number * 10 + digit
    else:
      number = high(int)
      inbounds = false
    inc(here)
    while here < s.len and s[here] == '_':  # underscores are ignored
      inc(here)
  if minus:
    number = -number
  if here - start == 1 and s[here] in Signs:
    here = start
  result = here - start

proc parseBiggestFloat(s: openArray[char], number: var BiggestFloat): int {.
  magic: "ParseBiggestFloat", importc: "nimParseBiggestFloat", noSideEffect.}
  ## Parses a float and stores the value into `number`.
  ## Result is the number of processed chars or 0 if a parsing error
  ## occurred.
  # Copied directly from the source without modification.

proc myParseFloat*(s: string, number: var float, start = 0): int {.noSideEffect.} =
  ## Parses a float starting at `start` and stores the value into `number`.
  ## Result is the number of processed chars or 0 if there occurred a parsing
  ## error.
  runnableExamples:
    var res: float
    doAssert parseFloat("32", res, 0) == 2
    doAssert res == 32.0
    doAssert parseFloat("32.57", res, 0) == 5
    doAssert res == 32.57
    doAssert parseFloat("32.57", res, 3) == 2
    doAssert res == 57.00

  number = 0.0
  if unlikely(start < 0 or start >= s.len): return
  result = parseBiggestFloat(s.toOpenArray(start, s.high), number)
  if result == 0:
    number = 0.0


proc parseNumber*(s: string, value: var IntOrFloat, start: int = 0, maxDigits: int = 0): int =
  ## Parses a decimal, binary, or hex int, or a float.
  ## Hex and Bin numbers to parse can be processed with
  ## a maximum length of digits (not including leading marks).
  ##
  ## Returns the number of characters processed, or 0 if an error.

  var maybeInt = 0
  var maybeFloat = 0.0
  value = Invalid()
  if s.len == 0 or start < 0 or start >= s.len or s[start] notin (Signs + Digits + Dot + BinHexShortMarks):
    return
  if s.len > 1 and s[start] == '#' or (s[start] == '0' and s[start + 1] in HexMarks):
    result = myParseHex(s, maybeInt, start, maxDigits)
  elif s.len > 1 and s[start] == '%' or (s[start] == '0' and s[start + 1] in BinMarks):
    result = myParseBin(s, maybeInt, start, maxDigits)
  if result > 0:
    value = IntRep(intval: maybeInt)
  else:
    result = myParseInt(s, maybeInt, start)  # maxDigits does not apply to decimal ints
    if result > 0:
      value = IntRep(intval: maybeInt)
    if result + start >= s.len:
      return
    if s[result + start] == '.':
      result = myParseFloat(s, maybeFloat, start)  # maxDigits does not apply to floats
      value = FloatRep(floatval: maybeFloat)
