import cli, commands
import std/[os]

commands.init()

cli.process(commandLineParams(), cli.rootCommands)
