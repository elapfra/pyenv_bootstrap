# Virtual Environment Bootstrap Script

This script automates the setup of Python virtual environments and installation of required packages. It provides options to specify the virtual environment directory, use development requirements, force package reinstallation, and choose a custom requirements file.

## Usage

```bash
pyenv_bootstrap.sh [OPTIONS]
```

## Options

- `-d, --dev`: Use development requirements. If specified, the script will look for `dev-requirements.txt`. If not specified, it will use `requirements.txt`.
- `-f, --force`: Force reinstall packages. If specified, packages will be reinstalled even if they are already installed.
- `-h, --help`: Show help message and usage information.
- `-r, --requirements=`*file*: Specify a custom requirements file. If not provided, the script will use either `dev-requirements.txt` or `requirements.txt` based on the `-d` option.
- `-p, --venv-dir=`*directory*: Specify the virtual environment directory. The default is `venv`.

## Examples

1. Create a virtual environment named "myenv" and install packages from "requirements.txt":
   ```bash
   pyenv_bootstrap.sh -p myenv
   ```

2. Use development requirements and force reinstall packages:
   ```bash
   pyenv_bootstrap.sh -d -f
   ```

3. Specify a custom requirements file and virtual environment directory:
   ```bash
   pyenv_bootstrap.sh -r custom-requirements.txt -p custom_env
   ```


## Virtual Environment Bootstrap Script Aliases

Add these aliases to your .bashrc for easy access to the pyenv_bootstrap.sh script.

```bash
alias venv-create='bash /path/to/pyenv_bootstrap.sh'
alias venv-create-dev='bash /path/to/pyenv_bootstrap.sh -d'
alias venv-create-force='bash /path/to/pyenv_bootstrap.sh -f'
alias venv-create-custom='bash /path/to/pyenv_bootstrap.sh -p /path/to/custom_env -r /path/to/custom-requirements.txt'
```

## Output

The script will provide status updates for each step of the process and summarize the operations performed at the end.

## Execution sample

```zsh
~ ❯ venv-create -r /path/to/requirements.txt -p ~/venv
Creating Python virtual environment...
Python virtual environment created successfully.
Upgrading pip...
pip upgraded successfully.
Installing required packages from /path/to/requirements.txt...
Required packages installed successfully.
Python virtual environment setup completed successfully.

=== Recap of Operations ===
Virtual Environment Directory: ~/venv
Use Dev Requirements: false
Force Reinstall: false
Requirements File: /path/to/requirements.txt
Platform: Linux
```

### Recap of Operations

- Virtual Environment Directory: *venv_name*
- Use Dev Requirements: *true/false*
- Force Reinstall: *true/false*
- Requirements File: *requirements_file*
- Platform: *Linux/Windows*
