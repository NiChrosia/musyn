# Musyn

A tool to more easily synchronize online "repositories" of music to local storage.

# Quickstart

1. Initialize a repository.

```
musyn init
```

2. Create a source (youtube is currently the only option).

```
musyn src-new <name> (yt | youtube)
```

3. Configure required settings (only current options are playlist and channel).

```
musyn src-mod <name> id <playlist or channel id>
musyn src-mod <name> id_type (playlist | channel)
musyn src-mod <name> file_type <valid audio file extension>
```

4. Synchronize.

```
musyn sync
```

# Further reading

Simply running `musyn` or `musyn help` will display an overview of the available commands. For more detail, simply run `musyn help <command>`, or `musyn help :<concept>` for other information, like available source types or source settings.
