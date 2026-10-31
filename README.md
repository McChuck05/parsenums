parsenums.nim

A Nim parser for string -> Number.  Requires Nim 2.4.0 or higher.  Will convert hexadecimal and binary values to int.

Modified from the Nim standard library modules parseutils and strutils.  Has no dependencies.

```
type
  Number* = object
    case
    of Invalid: discard
    of IntRep: intval*: int
    of FloatRep: floatval*: float

proc parseNumber*(s: string, value: var IntOrFloat, start: int = 0, maxDigits: int = 0): int =
  ## Parses a decimal, binary, or hex int, or a float.
  ## Hex and Bin numbers to parse can be processed with
  ## a maximum length of digits (not including leading marks).
  ##
  ## Returns the number of characters processed, or 0 if an error.

proc myParseFloat*(s: string, number: var float, start = 0): int {.noSideEffect.} =
  ## Parses a float starting at `start` and stores the value into `number`.
  ## Result is the number of processed chars or 0 if there occurred a parsing
  ## error.

proc myParseInt*(s: string, number: var int, start: int = 0): int {.raises: [].} =
  ## Parses an int into ``number``. This cannot raise an overflow
  ## error. ``high(int)`` is returned for an overflow.
  ## The number of processed character is returned.
  ## Cannot process low(int)

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
```

