import cli, help, serialization
import std/[tables, strformat]

type
    InvalidArgumentCountException* = object of ValueError
    NoSuchHelpEntryException* = object of ValueError

proc assertArgumentCount(c: int, parts: seq[string]) =
    if parts.len != c:
        raise newException(InvalidArgumentCountException, fmt"Invalid number of arguments! Expected {c}, but found {parts.len}!")

proc tryReadState(): bool =
    try:
        serialization.read()

        return true
    except IOError:
        echo "state-dependent functions can only be run in a musyn repository! to make this one, run \"musyn init\"."

        return false

proc helpCommand(parts: seq[string]) =
    if parts.len > 0:
        let key = parts[0]

        if key notin help.help:
            raise newException(NoSuchHelpEntryException, fmt"No help entry for key {key}!")

        echo help.help[key]
    else:
        echo help.help[""]

proc init(parts: seq[string]) =
    discard

proc srcNew(parts: seq[string]) =
    if not tryReadState():
        return

proc srcModify(parts: seq[string]) =
    if not tryReadState():
        return

proc srcDelete(parts: seq[string]) =
    if not tryReadState():
        return

proc status(parts: seq[string]) =
    if not tryReadState():
        return

proc sync(parts: seq[string]) =
    if not tryReadState():
        return

proc init*() =
    cli.rootDefaultCommand = helpCommand

    cli.rootCommands["init"]    = init
    cli.rootCommands["src-new"] = srcNew
    cli.rootCommands["src-mod"] = srcModify
    cli.rootCommands["src-del"] = srcDelete
    cli.rootCommands["status"]  = status
    cli.rootCommands["sync"]    = sync
    cli.rootCommands["help"]    = helpCommand
