import cli, help, serialization, sources, state, log
import std/[tables, strformat, sets, terminal, os, sequtils, strutils]

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

proc helpCommand(parts, options: seq[string]) =
    if parts.len > 0:
        let key = parts[0]

        if key notin help.help:
            echo fmt"no help entry exists for key '{key}'!"
            return

        echo help.help[key]
    else:
        echo help.help[""]

proc init(parts, options: seq[string]) =
    if not fileExists(MUSYN_STATE_FILE):
        serialization.write()
        echo "repository initialized!"
    else:
        echo "cannot override existing repository!"

proc srcNew(parts, options: seq[string]) =
    if not tryReadState() or not assertArgumentCount(2, parts):
        return

    let name = parts[0]
    let kind = parts[1]

    case kind
    of "yt", "youtube":
        stateSources[name] = ytSource()
    else:
        echo fmt"unrecognized source type '{kind}'!"
        return

    if "-g" in options or "--guide" in options:
        case kind
        of "yt", "youtube":
            stdout.write("id: ")
            let id = stdin.readLine()

            var idType: string

            while true:
                stdout.write("id_type: ")
                idType = stdin.readLine()

                if idType == "playlist" or idType == "channel":
                    break
                else:
                    echo fmt"invalid id type {idType}!"

            stdout.write("file_type: ")
            let fileType = stdin.readLine()

            stateSources[name].settings["id"] = id
            stateSources[name].settings["id_type"] = idType
            stateSources[name].settings["file_type"] = fileType

            stdout.write("sync (Y/n): ")
            let shouldSync = stdin.readLine()

            if ["", "y", "Y", "yes", "YES"].anyIt(it == shouldSync):
                echo "synchronizing..."
                cli.rootCommands["sync"](@[], @[])
            else:
                echo "not syncing."

    serialization.write()

proc srcRename(parts, options: seq[string]) =
    if not tryReadState() or not assertArgumentCount(2, parts):
        return

    let name = parts[0]
    let newName = parts[1]

    if name notin stateSources:
        log.error(fmt"invalid source name '{name}'!")
        return

    stateSources[newName] = stateSources[name]
    stateSources.del(name)

    if dirExists(name):
        log.info(fmt"moving '{name}/' to '{newName}/'...")
        moveDir(name, newName)

proc srcModify(parts, options: seq[string]) =
    if not tryReadState() or not assertArgumentCount(3, parts):
        return

    let name = parts[0]
    let key = parts[1]
    let value = parts[2]

    try:
        stateSources[name].settings[key] = value
    except KeyError:
        echo fmt"unknown source '{name}'!"
        return

    serialization.write()

proc srcDelete(parts, options: seq[string]) =
    if not tryReadState() or not assertArgumentCount(1, parts):
        return

    let name = parts[0]

    stateSources.del(name)

    serialization.write()

proc srcRecover(parts, options: seq[string]) =
    if not tryReadState():
        return

    var names: seq[string]

    if parts.len == 0:
        for name in stateSources.keys:
            names.add(name)
    else:
        names = parts

    for name in names:
        var titles: HashSet[string]
        var fileType = ""

        if not dirExists(name):
            if parts.len > 0:
                log.error(fmt"cannot recover from nonexistent directory '{name}'!")

            return

        for (kind, path) in walkDir(name):
            if kind != pcFile:
                continue

            var (_, title, ext) = splitFile(path)
            ext = ext[1 .. ext.high]

            titles.incl(title)

            if fileType != ext and fileType != "":
                log.error(fmt"inconsistent song file types in directory '{name}' (expected '{fileType}' but found '{ext}')! cannot accurately recover unless song file types are all the same!")
                return

            # only take the xyz part of .xyz
            fileType = ext

        if titles.len == 0:
            echo "directory empty, aborting..."
            return

        let source = try:
            stateSources[name]
        except KeyError:
            echo fmt"unknown source '{name}'!"
            return

        stateSources[name].settings["file_type"] = fileType

        if not source.settings.hasKey("id") or not source.settings.hasKey("id_type"):
            echo "missing one or both of required settings 'id' and 'id_type', cannot continue!"
            return

        let diff = source.diff(source)

        for song in diff.additions:
            if song.title.replace("/", "_") in titles:
                stateSources[name].songs.incl(song)

        serialization.write()

proc status(parts, options: seq[string]) =
    if not tryReadState():
        return

    for name in stateSources.keys:
        let source = stateSources[name]

        if not source.settings.hasKey("id") or not source.settings.hasKey("id_type"):
            echo "missing one or both of required settings 'id' and 'id_type', cannot continue!"
            return

        echo fmt"[{name}]"

        let diff = source.diff(source)

        for song in diff.additions:
            stdout.styledWrite fgGreen, "+"
            stdout.writeLine " " & song.title

        for song in diff.deletions:
            stdout.styledWrite fgRed, "-"
            stdout.writeLine " " & song.title

        if diff.additions.len == 0 and diff.deletions.len == 0:
            echo "no upstream changes"

proc sync(parts, options: seq[string]) =
    try:
        if not tryReadState() or findExe("yt-dlp") == "":
            return

        var sources: Table[string, Source]

        # add source names
        for name in parts:
            if name notin stateSources:
                log.error(fmt"invalid source name '{name}'!")
                return

            sources[name] = stateSources[name]

        if parts.len == 0:
            sources = stateSources

        # validate sources
        for name, source in sources:
            let valid_string = source.valid(source)

            if valid_string != "":
                log.error(valid_string)
                return

            if not dirExists(name):
                createDir(name)

        let sourceLen = sources.len
        
        var
            globalSongIndex = 0
            sourceIndex = 0

        for name, source in sources:
            let
                diff = source.diff(source)

                fileType = source.settings["file_type"]
                sanitizedName = name.replace("'", "'\"'\"'").replace("/", "∕")

                addLen = diff.additions.len
                delLen = diff.deletions.len

            var songIndex = 0
            for song in diff.additions:
                log.info(fmt"adding ({sourceIndex + 1}:{songIndex + 1}/{sourceLen}:{addLen}) {name}/{song.title}...")

                if song.title == "[Private video]":
                    log.info("video is private, skipping...")
                    continue

                let command = fmt"yt-dlp 'https://www.youtube.com/watch?v={song.id}' --embed-metadata --embed-thumbnail --extract-audio --audio-format {fileType} -P '{sanitizedName}' -o '%(title)s.%(ext)s'"
                let result = execShellCmd(command)

                if result != 0:
                    if "--skip" in options:
                        log.info("command failed, skipping...")
                        continue
                    else:
                        log.error("yt-dlp command failed! exiting...")
                        log.debug(fmt"faulty yt-dlp command: {command}")

                        serialization.write()
                        return

                stateSources[name].songs.incl(song)

                songIndex += 1
                globalSongIndex += 1

                if globalSongIndex mod 10 == 0:
                    serialization.write()

            songIndex = 0
            for song in diff.deletions:
                log.info(fmt"removing ({sourceIndex + 1}:{songIndex + 1}/{sourceLen}:{delLen}) {name}/{song.title}...")

                let songFile = fmt"{sanitizedName}/{song.title}.{fileType}"

                if fileExists(songFile):
                    removeFile(songFile)

                stateSources[name].songs.excl(song)

                songIndex += 1
                globalSongIndex += 1

                if globalSongIndex mod 10 == 0:
                    serialization.write()

            sourceIndex += 1

        serialization.write()
    except:
        log.error("error in execution! saving existing songs to index...")
        log.debug("message: \n" & getCurrentExceptionMsg())

        serialization.write()

proc init*() =
    cli.rootDefaultCommand = helpCommand

    cli.rootCommands["init"]        = init
    cli.rootCommands["src-new"]     = srcNew
    cli.rootCommands["src-rename"]  = srcRename
    cli.rootCommands["src-mod"]     = srcModify
    cli.rootCommands["src-del"]     = srcDelete
    cli.rootCommands["src-recover"] = srcRecover
    cli.rootCommands["status"]      = status
    cli.rootCommands["sync"]        = sync
    cli.rootCommands["help"]        = helpCommand
