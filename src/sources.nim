import std/[sets, sugar]

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
var diffs*: array[SourceKind, (Source) -> Diff]
# kind: (filename, song) -> void
var downloads*: array[SourceKind, (string, Song) -> void]

proc ytDiff(source: Source): Diff =
    discard

proc ytDownload(filename: string, song: Song) =
    discard

proc init*() =
    diffs[skYt] = ytDiff
    downloads[skYt] = ytDownload
