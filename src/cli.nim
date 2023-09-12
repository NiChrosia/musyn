import state, logging
import std/[tables, sets, sugar, strformat]

type
    Cmd = (arguments: seq[string], options: Table[string, string], flags: HashSet[string]) -> void

    CommandProcessor* = object
        helpEntries: Table[string, string]
        options: HashSet[string]

        default: Cmd
        commands: Table[string, Cmd]

proc init*(
    _: typedesc[CommandProcessor], 
    entries: Table[string, string], 
    options: HashSet[string], 
    default: Cmd, 
    commands: Table[string, Cmd]
): CommandProcessor =
    result.helpEntries = entries
    result.default = default
    result.commands = commands
    result.options = options

proc process*(processor: CommandProcessor, rawArguments: seq[string]) =
    if rawArguments.len == 0:
        processor.default(@[], initTable[string, string](), initHashSet[string]())

    let commandName = rawArguments[0]

    if commandName notin processor.commands:
        log.error(fmt"no such command '{commandName}'!")
        quit(QuitFailure)

    var arguments: seq[string]
    var options: Table[string, string]
    var flags: HashSet[string]

    var optionKey = ""

    for rawArgument in rawArguments:
        if optionKey != "":
            options[optionKey] = rawArgument
            continue

        if rawArgument in processor.options:
            optionKey = rawArgument
            continue

        if rawArgument[0] == '-':
            flags.incl(rawArgument)
            continue

        arguments.add(rawArgument)

    let command = processor.commands[commandName]
    command(arguments, options, flags)
