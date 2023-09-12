import sources, cli, logging
import std/[json, strformat]

const STATE_FILE_NAME = "musyn_state.json"
const LOG_FILE_NAME = "musyn.log"

var allSources*: seq[Source]
var processor*: CommandProcessor
var log*: Logger

# utility
proc s(json: JsonNode, key: string): string =
    return json[key].getStr()

proc i(json: JsonNode, key: string): int =
    return json[key].getInt()

# per-type io
proc loadSource(json: JsonNode) =
    discard

proc saveSource(json: var JsonNode, source: Source) =
    discard

# per-version io
proc loadVersion0(json: JsonNode) =
    discard

proc loadVersion1(json: JsonNode) =
    discard

# api
proc init*() =
    log = Logger.init(LOG_FILE_NAME)

proc load*() =
    var json: JsonNode

    try:
        json = parseJson(readFile(STATE_FILE_NAME))
    except:
        log.error("error occurred while parsing json!")
        log.debug(getCurrentExceptionMsg())
        quit(QuitFailure)

    try:
        var version: int

        try:
            version = json.i("version")
        # pre-rewrite version didn't have a version field; the root type was an array
        except:
            version = 0

        case version
        # pre-rewrite state
        of 0:
            loadVersion0(json)
        of 1:
            loadVersion1(json)
        else:
            log.error(fmt"unrecognized state version '{version}'!")
            quit(QuitFailure)
    except:
        log.error(fmt"error occurred while reading json!")
        log.debug(getCurrentExceptionMsg())
        quit(QuitFailure)

# version 1
proc save*() =
    discard
