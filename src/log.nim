import std/[terminal, times, strformat]

const
    INFO_COLOR = fgBlue
    DEBUG_COLOR = fgGreen
    ERROR_COLOR = fgRed

    LOG_FILE_NAME = "musyn.log"

var logFile: File

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
proc info*(values: varargs[string, `$`]) =
    stdout.styledWrite(INFO_COLOR, "[I]")

    writeValues(values, stdout)
    writeValues(values, logFile)

proc debug*(values: varargs[string, `$`]) =
    stdout.styledWrite(DEBUG_COLOR, "[D]")

    writeValues(values, stdout)
    writeValues(values, logFile)

proc error*(values: varargs[string, `$`]) =
    stdout.styledWrite(ERROR_COLOR, "[E]")

    writeValues(values, stdout)
    writeValues(values, logFile)

# state
proc init*() =
    logFile = open(LOG_FILE_NAME)

proc terminate*() =
    logFile.close()
