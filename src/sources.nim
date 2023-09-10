import std/[sugar, tables, json, strformat, httpclient, hashes, sets]

type
    InvalidIdTypeException* = object of ValueError
    NonexistentOldSongException* = object of ValueError

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

const INVIDIOUS_INSTANCE = "invidious.io.lol"

let client = newHttpClient()

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
    let url = fmt"https://{INVIDIOUS_INSTANCE}/api/v1/playlists/{id}"
    let raw = client.getContent(url)
    let json = parseJson(raw)

    for video in json["videos"].getElems():
        let title = video["title"].getStr()
        let id = video["videoId"].getStr()
        let duration = video["lengthSeconds"].getInt()

        result.incl(Song(title: title, id: id, duration: duration))

proc ytChannelSongs*(id: string, continuation: string = ""): HashSet[Song] =
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

proc ytStatus*(source: Source): Diff =
    let idType = source.settings["id_type"]

    let newSongs = case idType
    of "playlist":
        ytPlaylistSongs(source.settings["id"])
    of "channel":
        ytChannelSongs(source.settings["id"])
    else:
        raise newException(InvalidIdTypeException, fmt"Unrecognized id type '{idType}'!")

    return diffOf(source.songs, newSongs)

# sources
proc ytSource*(): Source =
    result.kind = "youtube"
    result.diff = ytStatus
