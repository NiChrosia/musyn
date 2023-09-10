import std/[sugar, tables]

type
    Command* = (seq[string]) -> void

var rootCommands*: Table[string, Command]
var rootDefaultCommand*: Command

proc process*(parts: seq[string], commands: Table[string, Command]) =
    if parts.len == 0:
        rootDefaultCommand(@[])
        return

    let command = parts[0]

    let subParts = if parts.len == 1: @[] else: parts[1 .. parts.high]
    commands[command](subParts)
