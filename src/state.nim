import sources
import std/[tables]

type
    LogLevel* = enum
        llNormal, llDebug

var stateSources*: Table[string, Source]
var logLevel* = llNormal
