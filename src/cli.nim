const HELP_ROOT* = """
usage: musyn [-v | --version] [-h | --help]
       <command> [<args>]

Typical commands:

manage a working area
   init      Create an empty repository
   src       Create, delete, or modify a music source

manage local files
   status    Check for any updates in music sources
   sync      Synchronize local files to online sources

See 'musyn help <command>' for help on any specific command,
or 'musyn help <concept>' for help with any musyn-specific concept.
"""

const HELP_INIT* = """
NAME
       musyn-init - Initialize a new repository
SYNOPSIS
       musyn init [dir]
DESCRIPTION
       This command initializes the necessary data for
       musyn to function in either [dir], or, by default,
       the current directory.
"""

const HELP_SRC* = """
NAME
       musyn-src - Manage the state of a music source
SYNOPSIS
       musyn src (<new> | <mod> | <del>)
DESCRIPTION
       This command can initialize a new source, change the parameters of an
       existing one, or delete an unneeded source.

See 'musyn help src <subcommand>' for help on each subcommand.
"""

const HELP_SRC_NEW* = """
NAME
       musyn-src-new - Create a new music source in the repository
SYNOPSIS
       musyn src new <name> <type> <args>
DESCRIPTION
       This command creates a new music source named <name>,
       with type <type> and arguments <args>. Typically, the arguments
       are a URL pointing to, say, a playlist, or a YouTube channel.

See 'musyn help source-types' for more information about the types of sources available.
"""

const HELP_SRC_MOD* = """
NAME
       musyn-src-mod - Change the settings of a music source
SYNOPSIS
       musyn src mod <name> <key> <value>
DESCRIPTION
       This command changes the setting named <key> to <value>
       in music source <name>.

See 'musyn help source-settings' for more information about available source settings.
"""

const HELP_SRC_DEL* = """
NAME
       musyn-src-del - Delete a music source in the repository
SYNOPSIS
       musyn src del <name>
DESCRIPTION
       This command deletes the music source named <name> in the repository.
"""

const HELP_STATUS* = """
NAME
       musyn-status - Check the status of music sources in the repository
SYNOPSIS
       musyn status [-v | --verbose]
DESCRIPTION
       This command displays information about updates to music sources, such as 
       new songs, changes to existing sources, or other changes, depending on the 
       type of source.
"""

const HELP_SYNC* = """
NAME
       musyn-sync - Synchronize online files to local files
SYNOPSIS
       musyn sync <name> <name> ...
DESCRIPTION
       This command can either synchronize all sources, or a specific subset
       specified after the command.
"""