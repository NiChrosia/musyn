import std/[sugar, tables, json, strformat, httpclient, hashes, sets]

type
    InvalidIdTypeException* = object of ValueError

    Song* = object
        title*, id*: string
        duration*: int # seconds

    Diff* = object
        additions*, deletions*: HashSet[Song]

    Source* = object
        kind*: string
        settings*: Table[string, string]
        songs*: HashSet[Song]

        diff*: (Source) -> Diff
        valid*: (Source) -> string

const INVIDIOUS_INSTANCE = "invidious.io.lol"

# type functions
proc hash*(song: Song): Hash =
    return hash(song.title) !& hash(song.id) !& hash(song.duration)

# utility functions
proc diffOf*(oldSongs, newSongs: HashSet[Song]): Diff =
    result.additions = newSongs - oldSongs
    result.deletions = oldSongs - newSongs

# source-type specific networking functions
# - youtube
proc ytPlaylistSongs*(id: string): HashSet[Song] =
    let client = newHttpClient()

    let url = fmt"https://{INVIDIOUS_INSTANCE}/api/v1/playlists/{id}"
    let raw = client.getContent(url)
    let json = parseJson(raw)

    for video in json["videos"].getElems():
        let title = video["title"].getStr()
        let id = video["videoId"].getStr()
        let duration = video["lengthSeconds"].getInt()

        result.incl(Song(title: title, id: id, duration: duration))

    client.close()

proc ytChannelSongs*(id: string, continuation: string = ""): HashSet[Song] =
    let client = newHttpClient()

    var url = fmt"https://{INVIDIOUS_INSTANCE}/api/v1/channels/{id}/videos" 

    if continuation != "":
        url &= fmt"?continuation={continuation}"

    let raw = client.getContent(url)
    let json = parseJson(raw)

    for video in json["videos"].getElems():
        let title = video["title"].getStr()
        let id = video["videoId"].getStr()
        let duration = video["lengthSeconds"].getInt()

        result.incl(Song(title: title, id: id, duration: duration))

    if json.hasKey("continuation"):
        for song in ytChannelSongs(id, json["continuation"].getStr()):
            result.incl(song)

    client.close()

proc ytStatus*(source: Source): Diff =
    let idType = source.settings["id_type"]

    let newSongs = case idType
    of "playlist":
        ytPlaylistSongs(source.settings["id"])
    of "channel":
        ytChannelSongs(source.settings["id"])
    else:
        # should never occur, in theory
        raise newException(InvalidIdTypeException, fmt"Unrecognized id type '{idType}'!")

    return diffOf(source.songs, newSongs)

proc ytValid*(source: Source): string =
    if "id" notin source.settings or
       "id_type" notin source.settings or
       "file_type" notin source.settings:
        return "missing one or more critical settings (id, id_type, file_type)!"

    if source.settings["id_type"] notin ["playlist", "channel"]:
        return "id type is not a valid option (playlist, channel)!"

    return ""

# sources
proc ytSource*(): Source =
    result.kind = "youtube"
    result.diff = ytStatus
    result.valid = ytValid
