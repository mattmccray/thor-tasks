# Thor Tasks

    backbone
    --------
    thor backbone:new [TYPE] [NAME]  # Creates new backbone files or projects, use 'backbone:new help' for more.
    thor backbone:serve              # Serves this directory via WebBrick (since some browser don't handle file:// urls well)
    thor backbone:update             # Updates app_scripts

    desktop
    -------
    thor desktop:icons:hide  # Hide the icons on your (Mac) desktop
    thor desktop:icons:show  # Show the icons on your (Mac) desktop

    organize
    --------
    thor organize:files [FOLDER]  # Organize files in FOLDER based on file type

    vhost
    -----
    thor vhost:edit            # Edit hosts and apache vhosts files in Textmate
    thor vhost:list            # List all vhost entries
    thor vhost:new URL [PATH]  # Create new vhost entry

    yui
    ---
    thor yui:compress [*SOURCES]  # Compress source with YUI