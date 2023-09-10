import cli
import std/[tables]

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

cli.rootCommands["init"] = init
cli.rootCommands["src"] = src
cli.rootCommands["status"] = status
cli.rootCommands["sync"] = sync

srcCommands["new"] = srcNew
srcCommands["mod"] = srcModify
srcCommands["del"] = srcDelete
