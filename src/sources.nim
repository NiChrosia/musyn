import std/[sugar, tables, json, strformat, httpclient, hashes]

type
    Status* = object
        outdated*: bool
        message*: string

    Source* = object
        settings*: Table[string, string]
        hash*: Hash

        status*: (var Source) -> Status
        sync*: (var Source) -> void

const INVIDIOUS_INSTANCE = "invidious.io.lol"

let client = newHttpClient()

proc youtubeSource*(): Source =
    proc queryStatus(source: var Source): Status =
        let playlistId = source.settings["playlist_id"]

        let apiUrl = fmt"https://{INVIDIOUS_INSTANCE}/api/v1/playlists/{playlistId}"
        let raw = client.getContent(apiUrl)
        let json = parseJson(raw)

        var ids: seq[string]

        for video in json["videos"].getElems():
            ids.add(video["videoId"].getStr())

        if source.hash == 0:
            source.hash = hash(ids)
            
            let message = "No local files - first synchronization."
            return Status(outdated: true, message: message)

        if hash(ids) != source.hash:
            let message = "Some change has occurred - later functionality will be implemented to show precisely what has changed."
            return Status(outdated: true, message: message)

        return Status(outdated: false)

    result.status = queryStatus
