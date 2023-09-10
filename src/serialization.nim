import sources, state
import std/[json, marshal]

const MUSYN_STATE_FILE = "musyn_state.json"

proc read*() =
    stateSources = to[seq[Source]](readFile(MUSYN_STATE_FILE))

proc write*() =
    writeFile(MUSYN_STATE_FILE, $$stateSources)
