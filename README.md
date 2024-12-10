> **DEPRECATED PROJECT**: note that **this project has been replaced by a backward-compatible upgrade called [Remote-Copy](https://github.com/richbl/remote-copy)** which permits the secure remote copy of *both files and folders*. As a result, this project will no longer be maintained in favor of support for this more comprehensive project.

# Remote-Folder-Copy

**Remote-Folder-Copy** (`remote_folder_copy.sh`) is a [bash](https://en.wikipedia.org/wiki/Bash_%28Unix_shell%29) script to remotely copy a folder using the secure remote copy ([scp](http://man7.org/linux/man-pages/man1/scp.1.html)) command, or the less-secure [sshpass](http://linux.die.net/man/1/sshpass) command when the localhost user is not certificate-authenticated on the remote server.

`run_remote_folder_copy.sh` is a related wrapper script intended to be used for making unattended script calls into `remote_folder_copy.sh` (*e.g.*, running cron jobs).

## [<img src="https://github.com/user-attachments/assets/4dc1e16e-3fd3-481c-9a43-b027c029dd27" width="150" />](https://github.com/richbl/a-bash-template)[Developed with a Bash Template (BaT)](https://github.com/richbl/a-bash-template)

**Remote-Folder-Copy** uses a bash template (BaT) called **[A-Bash-Template](https://github.com/richbl/a-bash-template)** designed to make script development and command line argument management more robust, easier to implement, and easier to maintain. Here are a few of those features:

- Dependencies checker: a routine that checks all external program dependencies (*e.g.*, [sshpass](http://linux.die.net/man/1/sshpass) and [jq](https://stedolan.github.io/jq/))
- Arguments and script details--such as script description and syntax--are stored in the [JSON](http://www.json.org/) file format (*i.e.*, `config.json`)
- JSON queries (using [jq](https://stedolan.github.io/jq/)) handled through wrapper functions
- A script banner function automates banner generation, reading directly from `config.json`
- Command line arguments are parsed and tested for completeness using both short and long-format argument syntax (*e.g.*, `-u|--username`)
- Optional command line arguments are permissible and managed through the JSON configuration file
- Template functions organized into libraries to minimize code footprint in the main script

For more details about using a bash template, [check out the BaT sources here](https://github.com/richbl/a-bash-template).

## Requirements

 - An operational [bash](https://en.wikipedia.org/wiki/Bash_%28Unix_shell%29) environment (bash 4.3.46 used during development)
 -  Two additional external programs:
    + [sshpass](http://linux.die.net/man/1/sshpass), for piping password into the [scp](http://man7.org/linux/man-pages/man1/scp.1.html) command when [scp](http://man7.org/linux/man-pages/man1/scp.1.html) cannot be used directly (*e.g.*, localhost user is not certificate-authenticated on the remote server)
    + [jq](https://stedolan.github.io/jq/), for parsing the `config.json` file

While this package was written and tested under Linux (Ubuntu 16.10), there should be no reason why this won't work under other Unix-like operating systems.


## Basic Usage
**Remote-Folder-Copy** is run through a command line interface, so all of the command options are made available there.

Here's the default response when running `remote_folder_copy.sh` with no arguments:

      $ ./remote_folder_copy.sh

       |
       | A bash script to remotely copy a folder using scp
       |   0.6.0
       |
       | Usage:
       |   remote_folder_copy -u username [-p password] -w website [-P port] -s source -d destination
       |
       |   -u, --username 		username (must have local/remote permissions)
       |   -p, --password 		password used to access remote server (optional)
       |   -w, --website 		website domain name (e.g., example.com)
       |   -P, --port 			website/server SSH port
       |   -s, --source 		absolute source folder path
       |   -d, --destination 	destination folder path
       |

      Error: username argument (-u|--username) missing.
      Error: website argument (-w|--website) missing.
      Error: source argument (-s|--source) missing.
      Error: destination argument (-d|--destination) missing.


In this example, the program responds by indicating that the required script arguments must be set before proper operation.

When arguments are correctly passed, the script provides feedback on the success or failure of the remote folder copy:

    $ ./remote_folder_copy.sh -u user -p 'pass123' -w example.com -s /home/user/src -d /home/user/desktop

     |
     | A bash script to remotely copy a folder using scp
     |   0.6.0
     |
     | Usage:
     |   remote_folder_copy -u username [-p password] -w website [-P port] -s source -d destination
     |
     |   -u, --username 		username (must have local/remote permissions)
     |   -p, --password 		password used to access remote server (optional)
     |   -w, --website 		website domain name (e.g., example.com)
     |   -P, --port 			website/server SSH port
     |   -s, --source 		absolute source folder path
     |   -d, --destination 	destination folder path
     |

    Copying remote folder...

    Success.
    Remote folder example.com:/home/user/src copied to /home/user/desktop/src.

### Choosing Between the `scp` and `sshpass` Commands
**Remote-Folder-Copy** (`remote_folder_copy.sh`) uses two methods for copying folders from a remote server: [scp](http://man7.org/linux/man-pages/man1/scp.1.html) and [sshpass](http://linux.die.net/man/1/sshpass). The decision on which command to use is based on whether the `-p, --password` argument has been passed into the script. If no password is used, then the [scp](http://man7.org/linux/man-pages/man1/scp.1.html) command is used directly. If a password is passed into the script, then the [sshpass](http://linux.die.net/man/1/sshpass) command is used instead.

In general, it's preferred to use [scp](http://man7.org/linux/man-pages/man1/scp.1.html) with a current [certificate of authority](https://www.ssh.com/manuals/server-admin/44/Server_Authentication_with_Certificates.html) in place on the remote server. For the security-minded, users of this script should review the section entitled *Security Considerations* on the [sshpass](http://linux.die.net/man/1/sshpass) website.
