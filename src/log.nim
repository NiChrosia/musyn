import std/[terminal]

const INFO_COLOR = fgBlue
const DEBUG_COLOR = fgGreen
const ERROR_COLOR = fgRed

proc writeValues(values: openArray[string]) =
    for value in values:
        stdout.write(value)

    stdout.write("\n")

proc info*(values: varargs[string, `$`]) =
    stdout.styledWrite(INFO_COLOR, "[I]")
    writeValues(values)

proc debug*(values: varargs[string, `$`]) =
    stdout.styledWrite(DEBUG_COLOR, "[D]")
    writeValues(values)

proc error*(values: varargs[string, `$`]) =
    stdout.styledWrite(ERROR_COLOR, "[E]")
    writeValues(values)

