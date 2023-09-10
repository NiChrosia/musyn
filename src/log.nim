import state
import std/[terminal]

proc info*(message: string) =
    stdout.styledWrite fgBlue, "[I]"
    stdout.writeLine message

proc debug*(message: string) =
    if logLevel != llDebug:
        return

    stdout.styledWrite fgGreen, "[D]"
    stdout.writeLine message

proc error*(message: string) =
    stdout.styledWrite fgRed, "[E]"
    stdout.writeLine message
