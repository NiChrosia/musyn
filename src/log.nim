import state
import std/[terminal]

proc writePrefix(letter: char, color: ForegroundColor) =
    stdout.styledWrite color, "[", $letter, "] "

proc info*(message: string) =
    writePrefix('I', fgBlue)
    stdout.writeLine message

proc debug*(message: string) =
    if logLevel != llDebug:
        return

    writePrefix('D', fgGreen)
    stdout.writeLine message

proc error*(message: string) =
    writePrefix('E', fgRed)
    stdout.writeLine message
