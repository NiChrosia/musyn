import std/[sugar, tables, strformat]

type
    Command* = (parts: seq[string], options: seq[string]) -> void

var rootCommands*: Table[string, Command]
var rootDefaultCommand*: Command

proc process*(parts: seq[string], commands: Table[string, Command]) =
    if parts.len == 0:
        rootDefaultCommand(@[], @[])
        return

    let command = parts[0]

    var subParts = if parts.len == 1: @[] else: parts[1 .. parts.high]

    let commandProc = try:
        commands[command]
    except KeyError:
        echo fmt"no such command '{command}'!"
        return

    var filteredSubParts, options: seq[string]

    for part in subParts:
        if part[0] == '-' or part[0 .. 1] == "--":
            options.add(part)
        else:
            filteredSubParts.add(part)

    commandProc(filteredSubParts, options)
