# Musyn

A tool to more easily synchronize online repositories of music to local storage.

# Quickstart

1. Initialize a repository.

```
musyn init
```

2. Create a source. Currently, the only available type is YouTube, which can be input as "youtube" or "yt".

```
musyn src-new <name> <type>
```

3. Configure required settings. Currently, the only options for YouTube are playlist and channel IDs.

```
musyn src-mod <name> id <id>
musyn src-mod <name> id_type (playlist | channel)
musyn src-mod <name> file_type <audio file extension>
```

4. Synchronize.

```
musyn sync
```

For example, with a playlist of Qumu's original songs, the process would be:

```
musyn init

musyn src-new Qumu yt

musyn src-mod Qumu id PL0PCz_ViBzWZPPjiVmYXZWHbXkGpbQNA6
musyn src-mod Qumu id_type playlist
musyn src-mod Qumu file_type mp3

musyn sync
```

# Further reading

Simply running `musyn` or `musyn help` will display an overview of the available commands. For more detail, simply run `musyn help <command>`, or `musyn help :<concept>` for other information, like available source types or source settings.
