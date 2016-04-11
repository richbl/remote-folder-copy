# Remote-Folder-Copy
**Remote-Folder-Copy** (`remote_folder_copy.sh`) is a [bash](https://en.wikipedia.org/wiki/Bash_%28Unix_shell%29) script to remotely copy a folder using the secure remote copy ([scp](http://man7.org/linux/man-pages/man1/scp.1.html)) command.

`run_remote_folder_copy.sh` is a related script intended to be used for making unattended script calls into `remote_folder_copy.sh` (*e.g.*, running cron jobs).

## Developed with a Bash Template (BaT)

**Remote-Folder-Copy** uses a bash template designed to make script development and command line argument management more robust, easier to implement, and easier to maintain. This bash template includes the following features:

- Dependencies checker: a routine that checks all external program dependencies (*e.g.*, [sshpass](http://linux.die.net/man/1/sshpass) and [jq](https://stedolan.github.io/jq/))
- Arguments and script details--such as script description and syntax--are stored in the [JSON](http://www.json.org/) file format (*i.e.*, `config.json`)
- Script banner function automates banner generation, and reads directly from `config.json`
- Command line arguments are parsed and tested for completeness using both short and long-format argument syntax (*e.g.*, `-u|--username`)
- Optional command line arguments are permissible and managed through the JSON configuration file
- Template functions organized into libraries to minimize code footprint in the main script

### Dependencies Checker
The dependencies checker is a routine that checks that all external program dependencies are met. For example, `remote_folder_copy.sh` relies on two external programs for proper execution: [sshpass](http://linux.die.net/man/1/sshpass) and [jq](https://stedolan.github.io/jq/).

To configure dependency checking in `remote_folder_copy.sh`, the array variable `REQ_PROGRAMS` is set to `('sshpass' 'jq')`. The script then calls into the `check_dependencies` function in the `args` library (found in the `./lib` folder).

### Script Configuration in JSON
Script details, such as the script description, version and script syntax, and all command line argument options are stored in a single JSON file called `config.json` located in the `./data` folder.

The JSON file used in `remote_folder_copy.sh` is displayed below:

      {
        "details":
          {
            "title": "A bash script to remotely copy a folder using scp",
            "syntax": "remote_folder_copy -u username -p password -w website [-P port] -s source -d destination",
            "version": "0.3.0"
            "compress_results": true
          },
        "arguments":
          [
            {
              "short_form": "-u",
              "long_form": "--username",
              "text_string": "username",
              "description": "username (must have local/remote permissions)",
              "required": true
            },
            {
              "short_form": "-p",
              "long_form": "--password",
              "text_string": "password",
              "description": "password used to access remote server",
              "required": true
            },
            {
              "short_form": "-w",
              "long_form": "--website",
              "text_string": "website",
              "description": "website domain name (e.g., example.com)",
              "required": true
            },
            {
              "short_form": "-P",
              "long_form": "--port",
              "text_string": "port",
              "description": "website/server SSH port",
              "required": false
            },
            {
              "short_form": "-s",
              "long_form": "--source",
              "text_string": "source",
              "description": "absolute source folder path",
              "required": true
            },
            {
              "short_form": "-d",
              "long_form": "--destination",
              "text_string": "destination",
              "description": "destination folder path",
              "required": true
            }
          ]
      }


### Automated Script Banner
The informational banner that displays details about how to use the script is generated using configuration details held in the JSON file. A call to `display_banner` in the `./lib/general` library displays the following:

      |
      | A bash script to remotely copy a folder using scp
      |   0.3.0
      |
      | Usage:
      |   remote_folder_copy -u username -p password -w website [-P port] -s source -d destination
      |
      |   -u, --username 		username (must have local/remote permissions)
      |   -p, --password 		password used to access remote server
      |   -w, --website 		website domain name (e.g., example.com)
      |   -P, --port 			website/server SSH port
      |   -s, --source 			absolute source folder path
      |   -d, --destination 	destination folder path
      |

### Command Line Parsing and Completeness Testing
When **Remote-Folder-Copy** is first run, it parses the command line to identify command line argument assignments (*e.g.*, `--password = pass123`), and also check to see whether all required arguments have been set. If command line arguments are missing, the script will report it:

      |
      | A bash script to remotely copy a folder using scp
      |   0.3.0
      |
      | Usage:
      |   remote_folder_copy -u username -p password -w website [-P port] -s source -d destination
      |
      |   -u, --username 		username (must have local/remote permissions)
      |   -p, --password 		password used to access remote server
      |   -w, --website 		website domain name (e.g., example.com)
      |   -P, --port 			website/server SSH port
      |   -s, --source 			absolute source folder path
      |   -d, --destination 	destination folder path
      |

      Error: username argument (-u|--username) missing.
      Error: password argument (-p|--password) missing.



## Requirements

 - An operational [bash](https://en.wikipedia.org/wiki/Bash_%28Unix_shell%29) environment (bash 4.3.2 used during development)
 -  Two additional external programs:
    + [sshpass](http://linux.die.net/man/1/sshpass), for piping password into the ([scp](http://man7.org/linux/man-pages/man1/scp.1.html)) command
    + [jq](https://stedolan.github.io/jq/), for parsing the `config.json` file

While this package was written and tested under Linux (Ubuntu 15.10), there should be no reason why this won't work under other Unix-like operating systems.


## Basic Usage
**Remote-Folder-Copy** is run through a command line interface, so all of the command options are made available there.

Here's the default response when running `remote_folder_copy.sh` with no arguments:

      $ ./remote_folder_copy.sh

       |
       | A bash script to remotely copy a folder using scp
       |   0.3.0
       |
       | Usage:
       |   remote_folder_copy -u username -p password -w website [-P port] -s source -d destination
       |
       |   -u, --username 		username (must have local/remote permissions)
       |   -p, --password 		password used to access remote server
       |   -w, --website 		website domain name (e.g., example.com)
       |   -P, --port 			website/server SSH port
       |   -s, --source 		absolute source folder path
       |   -d, --destination 	destination folder path
       |

      Error: username argument (-u|--username) missing.
      Error: password argument (-p|--password) missing.
      Error: website argument (-w|--website) missing.
      Error: source argument (-s|--source) missing.
      Error: destination argument (-d|--destination) missing.



In this example, the program responds by indicating that the required script arguments must be set before proper operation.

When arguments are correctly passed, the script provides feedback on the success or failure of the remote folder copy:

    $ ./remote_folder_copy.sh -u user -p 'pass123' -w example.com -s /home/user/src -d /home/user/desktop

     |
     | A bash script to remotely copy a folder using scp
     |   0.3.0
     |
     | Usage:
     |   remote_folder_copy -u username -p password -w website [-P port] -s source -d destination
     |
     |   -u, --username 		username (must have local/remote permissions)
     |   -p, --password 		password used to access remote server
     |   -w, --website 			website domain name (e.g., example.com)
     |   -P, --port 			website/server SSH port
     |   -s, --source 			absolute source folder path
     |   -d, --destination 		destination folder path
     |

    Copying remote folder...

    Success.
    Remote folder example.com:/home/user/src copied to /home/user/desktop/src.
