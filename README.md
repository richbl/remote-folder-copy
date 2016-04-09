# Remote-Folder-Copy
A [bash](https://en.wikipedia.org/wiki/Bash_%28Unix_shell%29) script to remotely copy a folder using the secure remote copy ([scp](http://man7.org/linux/man-pages/man1/scp.1.html)) command.

## Templated Script Design

This script is using a bash template designed to make script development and command line argument management easier to implement. This template includes the following features:

- Dependencies checker: routine that checks all external program dependencies (*e.g.*, [sshpass](http://linux.die.net/man/1/sshpass) and [jq](https://stedolan.github.io/jq/))
- Arguments and script details--such as script description and syntax--are stored in the [JSON](http://www.json.org/) file format (*e.g.*, `args.json`)
- Script banner function automates banner generation: reads directly from `args.json`
- Command line arguments are parsed and tested for completeness using both short and long-format argument syntax (*e.g.*, `-u|--username`)
- Template functions organized into libraries to minimize code footprint in the main script

### Dependencies Checker
The dependencies checker is a routine that checks that all external program dependencies are met. For example, `remote_folder_copy.sh` relies on two external programs for proper execution: [sshpass](http://linux.die.net/man/1/sshpass) and [jq](https://stedolan.github.io/jq/).

To configure dependency checking in `remote_folder_copy.sh`, the array variable `REQ_PROGRAMS` is set to `('sshpass' 'jq')`. The script then calls into the `check_dependencies` function found in the `args` library (found in the `./lib` folder).

### Script Configuration in JSON
Script details, such as the script description and script syntax, and all command line argument options are stored in a single JSON file called `args.json` (found in the `./data` folder).

The JSON file used in `remote_folder_copy.sh` is displayed below:

    {
      "details":
        {
          "title": "A bash script to remotely copy a folder using scp",
          "syntax": "remote_folder_copy -u username -p password -w website -s source -d destination"
        },
      "arguments":
        [
          {
            "short_form": "-u",
            "long_form": "--username",
            "text_string": "username",
            "description": "username (must have local/remote permissions)"
          },
          {
            "short_form": "-p",
            "long_form": "--password",
            "text_string": "password",
            "description": "password used to access remote server"
          },
          {
            "short_form": "-w",
            "long_form": "--website",
            "text_string": "website",
            "description": "website domain name (e.g., example.com)"
          },
          {
            "short_form": "-s",
            "long_form": "--source",
            "text_string": "source",
            "description": "absolute source folder path"
          },
          {
            "short_form": "-d",
            "long_form": "--destination",
            "text_string": "destination",
            "description": "destination folder path"
          }
        ]
    }

### Automated Script Banner
The informational banner that displays details about how to use the script is automatically generated using configuration details held in the JSON file. A call to `display_banner` in the `./lib/general` library displays the following:

    |
    | A bash script to remotely copy a folder using scp
    |
    | Usage:
    |   remote_folder_copy -u username -p password -w website -s source -d destination
    |
    |   -u, --username	username (must have local/remote permissions)
    |   -p, --password	password used to access remote server
    |   -w, --website	website domain name (e.g., example.com)
    |   -s, --source	absolute source folder path
    |   -d, --destination	destination folder path
    |

### Command Line Parsing and Completeness Testing
When `remote_folder_copy.sh` is first run, it parses the command line to identify command line argument assignments (*e.g.*, `--password = pass123`), and also check to see whether all arguments have been set. If command line arguments are missing, the script will report it:

    |
    | A bash script to remotely copy a folder using scp
    |
    | Usage:
    |   remote_folder_copy -u username -p password -w website -s source -d destination
    |
    |   -u, --username	username (must have local/remote permissions)
    |   -p, --password	password used to access remote server
    |   -w, --website	website domain name (e.g., example.com)
    |   -s, --source	absolute source folder path
    |   -d, --destination	destination folder path
    |

    Error: username argument (-u|--username) missing.
    Error: destination argument (-d|--destination) missing.


----



## Requirements

 - An operational [bash](https://en.wikipedia.org/wiki/Bash_%28Unix_shell%29) environment (bash 4.3.2 used during development)
 -  Two additional external programs:
    + [sshpass](http://linux.die.net/man/1/sshpass), for piping password into the ([scp](http://man7.org/linux/man-pages/man1/scp.1.html)) command
    + [jq](https://stedolan.github.io/jq/), for parsing JSON files

While this package was written and tested under Linux (Ubuntu 15.10), there should be no reason why this won't work under other Unix-like operating systems.


## Basic Usage
Copy-Remote-Folder is run through a command-line interface (CLI), so all of the command options are made available there.

Here's the default response when running `remote_folder_copy.sh` with no parameters:

    $ bash remote_folder_copy.sh

     |
     | A bash script to remotely copy a folder using scp
     |
     | Usage:
     |   remote_folder_copy -u username -p password -w website -s source -d destination
     |
     |   -u, --username	username (must have local/remote permissions)
     |   -p, --password	password used to access remote server
     |   -w, --website	website domain name (e.g., example.com)
     |   -s, --source	absolute source folder path
     |   -d, --destination	destination folder path
     |

    Error: username argument (-u|--username) missing.
    Error: password argument (-p|--password) missing.
    Error: website argument (-w|--website) missing.
    Error: source argument (-s|--source) missing.
    Error: destination argument (-d|--destination) missing.


In this example, the utility responds by indicating that all of the script arguments must be set before proper operation.

When all arguments are correctly passed, the script provides feedback on the success or failure of the remote folder copy:

    $ bash remote_folder_copy.sh -u user -p 'pass123' -w example.com -s /home/user/src -d /home/user/desktop

     |
     | A bash script to remotely copy a folder using scp
     |
     | Usage:
     |   remote_folder_copy -u username -p password -w website -s source -d destination
     |
     |   -u, --username	username (must have local/remote permissions)
     |   -p, --password	password used to access remote server
     |   -w, --website	website domain name (e.g., example.com)
     |   -s, --source	absolute source folder path
     |   -d, --destination	destination folder path
     |

    Copying remote folder...

    Success.
    Remote folder example.com:/home/user/src copied to /home/user/desktop/src.
