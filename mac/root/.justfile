# Global justfile — available anywhere with `just --global`


# Show available commands
default:
    @just --justfile ~/.justfile --list

# Launch zellij with the layout in the current directory
zwork:
    zellij --layout {{invocation_directory()}}/zellij.kdl

# Attach to (or create) a session named after the current folder, with its layout
zattach session=`basename "$PWD"`:
    zellij attach --create {{session}} --layout {{invocation_directory()}}/zellij.kdl

# Dump current zellij layout into the current directory
zdump:
    zellij action dump-layout > {{invocation_directory()}}/zellij.kdl
    @echo "Layout saved to {{invocation_directory()}}/zellij.kdl"
