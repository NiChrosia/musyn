import cli, help
import std/[tables, strformat]

type
    InvalidArgumentCountException* = object of ValueError
    NoSuchHelpEntryException* = object of ValueError

proc assertArgumentCount(c: int, parts: seq[string]) =
    if parts.len != c:
        raise newException(InvalidArgumentCountException, fmt"Invalid number of arguments! Expected {c}, but found {parts.len}!")

var srcCommands: Table[string, Command]

proc init(parts: seq[string]) =
    discard

proc srcNew(parts: seq[string]) =
    discard

proc srcModify(parts: seq[string]) =
    discard

proc srcDelete(parts: seq[string]) =
    discard

proc src(parts: seq[string]) =
    discard

proc status(parts: seq[string]) =
    discard

proc sync(parts: seq[string]) =
    discard

proc helpCommand(parts: seq[string]) =
    if parts.len > 0:
        let key = parts[0]

        if key notin help.help:
            raise newException(NoSuchHelpEntryException, fmt"No help entry for key {key}!")

        echo help.help[key]
    else:
        echo help.help[""]

proc init*() =
    cli.defaultCommand = helpCommand

    cli.rootCommands["init"]   = init
    cli.rootCommands["src"]    = src
    cli.rootCommands["status"] = status
    cli.rootCommands["sync"]   = sync
    cli.rootCommands["help"]   = helpCommand

    srcCommands["new"] = srcNew
    srcCommands["mod"] = srcModify
    srcCommands["del"] = srcDelete
