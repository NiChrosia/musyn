import cli, help, serialization, sources, state
import std/[tables, strformat, sets, terminal, os, sequtils]

proc assertArgumentCount(c: int, parts: seq[string]): bool =
    if parts.len != c:
        echo fmt"invalid number of arguments! expected {c}, but found {parts.len}!"
        return false

    return true

proc tryReadState(): bool =
    if not serialization.read():
        echo "state-dependent functions can only be run in a musyn repository! to make this one, run \"musyn init\"."
        return false

    return true

proc helpCommand(parts: seq[string]) =
    if parts.len > 0:
        let key = parts[0]

        if key notin help.help:
            echo fmt"no help entry exists for key {key}!"
            return

        echo help.help[key]
    else:
        echo help.help[""]

proc init(parts: seq[string]) =
    serialization.write()
    echo "repository initialized!"

proc srcNew(parts: seq[string]) =
    if not tryReadState() or not assertArgumentCount(2, parts):
        return

    let name = parts[0]
    let kind = parts[1]

    case kind
    of "yt", "youtube":
        stateSources[name] = ytSource()
    else:
        echo fmt"unrecognized source type {kind}!"
        return

    serialization.write()

proc srcModify(parts: seq[string]) =
    if not tryReadState() or not assertArgumentCount(3, parts):
        return

    let name = parts[0]
    let key = parts[1]
    let value = parts[2]

    try:
        stateSources[name].settings[key] = value
    except KeyError:
        echo fmt"unknown source {name}!"
        return

    serialization.write()

proc srcDelete(parts: seq[string]) =
    if not tryReadState() or not assertArgumentCount(1, parts):
        return

    let name = parts[0]

    stateSources.del(name)

    serialization.write()

proc status(parts: seq[string]) =
    if not tryReadState():
        return

    for name in stateSources.keys:
        let source = stateSources[name]

        echo fmt"[{name}]"

        let diff = source.diff(source)

        for song in diff.additions:
            stdout.styledWrite fgGreen, "+"
            stdout.writeLine " " & song.title

        for song in diff.deletions:
            stdout.styledWrite fgRed, "-"
            stdout.writeLine " " & song.title

proc sync(parts: seq[string]) =
    if not tryReadState() or execShellCmd("yt-dlp --help") != 0:
        return

    for name in stateSources.keys:
        let source = stateSources[name]

        if ["id", "id_type", "file_type"].anyIt(not source.settings.hasKey(it)):
            echo fmt"source {name} is missing mandatory settings! cannot continue execution!"
            return

        if not dirExists(name):
            createDir(name)

        let diff = try:
            source.diff(source)
        except InvalidIdTypeException:
            let idType = source.settings["id_type"]

            echo fmt"invalid id type {idType}!"
            return

        let fileType = source.settings["file_type"]

        var i = 1

        for song in diff.additions:
            stdout.styledWriteLine fgBlue, fmt"({i}/{diff.additions.len}) {song.title}"

            let command = fmt"yt-dlp 'https://www.youtube.com/watch?v={song.id}' --extract-audio --audio-format {fileType} -o '{name}/{song.title}.{fileType}'"
            discard execShellCmd(command)
            stateSources[name].songs.incl(song)

            i += 1

    serialization.write()

proc init*() =
    cli.rootDefaultCommand = helpCommand

    cli.rootCommands["init"]    = init
    cli.rootCommands["src-new"] = srcNew
    cli.rootCommands["src-mod"] = srcModify
    cli.rootCommands["src-del"] = srcDelete
    cli.rootCommands["status"]  = status
    cli.rootCommands["sync"]    = sync
    cli.rootCommands["help"]    = helpCommand
