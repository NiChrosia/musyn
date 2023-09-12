import std/[terminal, times, strformat]

type
    Logger* = object
        file: File

const
    INFO_COLOR = fgBlue
    DEBUG_COLOR = fgGreen
    ERROR_COLOR = fgRed

# utility
proc writeValues(values: openArray[string], file: File) =
    let hours = now().hour()
    let minutes = now().minute()
    let seconds = now().second()

    file.write(fmt"[{hours}:{minutes}:{seconds}]")

    for value in values:
        file.write(value)

    file.write("\n")

# api
proc info*(log: Logger, values: varargs[string, `$`]) =
    stdout.styledWrite(INFO_COLOR, "[I]")

    writeValues(values, stdout)
    writeValues(values, log.file)

proc debug*(log: Logger, values: varargs[string, `$`]) =
    stdout.styledWrite(DEBUG_COLOR, "[D]")

    writeValues(values, stdout)
    writeValues(values, log.file)

proc error*(log: Logger, values: varargs[string, `$`]) =
    stdout.styledWrite(ERROR_COLOR, "[E]")

    writeValues(values, stdout)
    writeValues(values, log.file)

# state
proc init*(_: typedesc[Logger], fileName: string): Logger =
    result.file = open(fileName)

proc terminate*(log: Logger) =
    log.file.close()
