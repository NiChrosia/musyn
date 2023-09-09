import std/[sugar, tables, json, strformat, httpclient, sets]

type
    Status* = object
        outdated*: bool

        additions*: HashSet[string]
        removals*: HashSet[string]

    Source* = object
        settings*: Table[string, string]
        titles*: HashSet[string]
        ids*: HashSet[string]

        status*: (var Source) -> Status
        sync*: (var Source) -> void

const INVIDIOUS_INSTANCE = "invidious.io.lol"

let client = newHttpClient()

proc statusOf*(oldTitles, newTitles: HashSet[string]): Status =
    result.outdated = oldTitles != newTitles
    result.additions = newTitles - oldTitles
    result.removals = oldTitles - newTitles

proc youtubeSource*(): Source =
    proc queryStatus(source: var Source): Status =
        let playlistId = source.settings["playlist_id"]

        let apiUrl = fmt"https://{INVIDIOUS_INSTANCE}/api/v1/playlists/{playlistId}"
        let raw = client.getContent(apiUrl)
        let json = parseJson(raw)

        var titles = initHashSet[string]()

        for video in json["videos"].getElems():
            titles.incl(video["title"].getStr())

        result = statusOf(source.titles, titles)
        source.titles = titles

    proc sync(source: var Source) =
        let playlistId = source.settings["playlist_id"]

        let apiUrl = fmt"https://{INVIDIOUS_INSTANCE}/api/v1/playlists/{playlistId}"
        let raw = client.getContent(apiUrl)
        let json = parseJson(raw)

        var ids = initHashSet[string]()

        for video in json["videos"].getElems():
            ids.incl(video["ids"].getStr())

        let idStatus = statusOf(source.ids, ids)

        for addition in idStatus.additions:
            echo addition

    result.settings = initTable[string, string]()
    result.titles = initHashSet[string]()

    result.status = queryStatus
    result.sync = sync
