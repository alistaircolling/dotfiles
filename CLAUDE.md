# Clipboard behavior

Whenever you suggest a command, shell snippet, or URL that the user should run or visit themselves (i.e. you are NOT executing it via the Bash tool), automatically copy it to the user's clipboard by running `printf '%s' "<the command or URL>" | pbcopy` via Bash, then tell the user it has been copied to their clipboard. Do not do this for commands you are executing yourself.
