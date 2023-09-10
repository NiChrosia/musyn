import std/[sugar, tables]

type
    NoCommandException* = object of ValueError

    Command* = (seq[string]) -> void

var rootCommands*: Table[string, Command]

proc process*(parts: seq[string], commands: Table[string, Command]) =
    if parts.len == 0:
        raise newException(NoCommandException, "No command given!")

    let command = parts[0]

    let subParts = if parts.len == 1: @[] else: parts[1 .. parts.high]
    commands[command](subParts)
