# Commands

```
example help page:

SYNOPSIS
    musyn (c | create) <name> [(-k | --kind) <kind>] [(-ft | --file-type) <filetype>] [<kind-specific options>]
EXAMPLES
    musyn c Qumu
    kind (yt, youtube)? yt
    repository kind (playlist, channel)? playlist
    playlist id? PL0PCz_ViBzWZPPjiVmYXZWHbXkGpbQNA6
    file type? mp3

    musyn c Qumu --kind yt --file-type mp3 --repository-kind playlist
    playlist id? PL0PCz_ViBzWZPPjiVmYXZWHbXkGpbQNA6
DESCRIPTION
    Creates a new music source, and configures it with the necessary options.

    If any options are not provided in the initial command, they will be manually
    queried from the user instead.
OPTION                   REQUIREMENTS    DESCRIPTION
-k, --kind                               kind of online source
                                         valid values: yt, youtube

-ft, --file-type                         downloaded song file type
                                         valid values: any audio file extension yt-dlp accepts

-rk, --repository-kind   kind: youtube   kind of repository
                                         valid values: playlist, channel

-i, --id                 kind: youtube   playlist or channel id
                                         valid values: any valid YouTube playlist or channel id

command synopses:

musyn (c | create)  <name> [<kind> [<kind-dependent arguments>]]
musyn (n | rename)  <name> <new name>
musyn (v | set)     <name> <setting> <value>
musyn (f | recover) <name>
musyn (d | delete)  <name>

musyn (s | sync) [(-i | --ignore-private)]

musyn (h | help) (<command> | :<concept>)

```
```diff
+ has abbreviations
+ has much more intuitive names
+ supports specifying specific parameters and querying the rest
+ automatically initializes the state if it doesn't exist
```

# Internals

## Sources

```nim
type
    SourceKind = enum
        skYt

    YtRepositoryKind = enum
        ypkPlaylist, ypkChannel

    Song = object
        case kind: SourceKind
        of skYt:
            id: string

        title: string

    Diff = object
        additions, deletions: HashSet[Song]

    Source = object
        case kind: SourceKind
        of skYt:
            repositoryKind: YtRepositoryKind
            id: string

        songs: HashSet[Song]
        filetype: string

# kind: (Source) -> Diff
diffs: Table[string, (Source) -> Diff]
# kind: (filename, song) -> void
downloads: Table[string, (string, Song) -> void]
```
```diff
+ kind-specific code abstracted to diffs and downloads
+ enums prevent possible invalid values
- more complex JSON due to enums and field case statements
```

## CLI

```nim
type
    Cmd = (arguments: seq[string], options: Table[string, string], flags: HashSet[string]) -> void

    CommandProcessor
        helpEntries: Table[string, string]

        default: Cmd
        commands: seq[Cmd]

proc process(processor: CommandProcessor, rawArguments: seq[string]) -> void

```
```diff
+ no more per-file state
+ allows much easier subcommands
+ builtin help command
+ distinction between options and flags
```

## Serialization

```json
{
    "source name": {
        "kind": "kind name",
        "settings": {
            "kind-specific key": "kind-specific value"
        },
        "filetype": "audio file extension"
        "songs": [
            {
                "kind-specific-key": "kind-specific-value"
                "title": "some title"
            }
        ]
    }
}

```
```diff
+ has kind-specific settings
```

## Logging

```
(blue)  [I] (white) some informative message
(green) [D] (white) some debug message
(red)   [E] (white) some error message

musyn.log

```
```diff
+ keeps a readable logfile
```
