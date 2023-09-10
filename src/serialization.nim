import sources, state
import std/[json, tables, sets, strformat]

type
    UnrecognizedSourceTypeException* = object of ValueError

const MUSYN_STATE_FILE = "musyn_state.json"

# per-type serialization
proc writeSong*(song: Song): JsonNode =
    result = newJObject()

    result["title"] = newJString(song.title)
    result["id"] = newJString(song.id)
    result["duration"] = newJInt(song.duration)

proc writeSource*(source: Source): JsonNode =
    result = newJObject()

    result["kind"] = newJString(source.kind)

    var settings = newJObject()

    for key in source.settings.keys:
        settings[key] = newJString(source.settings[key])

    result["settings"] = settings

    var songs = newJArray()

    for song in source.songs:
        songs.add(writeSong(song))

    result["songs"] = songs

proc readSong*(json: JsonNode): Song =
    result.title = json["title"].getStr()
    result.id = json["id"].getStr()
    result.duration = json["duration"].getInt()

proc readSource*(json: JsonNode): Source =
    let kind = json["kind"].getStr()

    case kind
    of "youtube":
        result = ytSource()
    else:
        echo kind
        echo "youtube"
        raise newException(UnrecognizedSourceTypeException, fmt"unrecognized source type {kind}!")

    let settings = json["settings"]

    for key in settings.keys:
        result.settings[key] = settings[key].getStr()

    let songs = json["songs"]

    for song in songs:
        result.songs.incl(readSong(song))

proc read*(): bool =
    try:
        let json = parseJson(readFile(MUSYN_STATE_FILE))

        for key in json.keys:
            stateSources[key] = readSource(json[key])

        return true
    except IOError:
        return false

proc write*() =
    var json = newJObject()

    for key in stateSources.keys:
        json[key] = writeSource(stateSources[key])

    writeFile(MUSYN_STATE_FILE, pretty(json, 4))
