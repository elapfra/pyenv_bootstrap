#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

# Get the platform (Linux or Windows)
platform=$(uname)

venv_directory="venv"
use_dev_requirements=false
force_reinstall=false
requirements_file="requirements.txt"

# Function to display help message
display_help() {
  echo "Usage: pyenv_bootstrap.sh [OPTIONS]"
  echo "Options:"
  echo "  -d, --dev             use dev requirements"
  echo "  -f, --force           force reinstall of packages"
  echo "  -h, --help            show help"
  echo "  -r, --requirements=   specify requirements file"
  echo "  -p, --venv-dir=       specify virtual environment directory"
  exit 0
}

while getopts ":dfhr:p:-:" opt; do
  case $opt in
  d)
    use_dev_requirements=true
    ;;
  f)
    force_reinstall=true
    ;;
  h)
    display_help
    ;;
  r)
    requirements_file="$OPTARG"
    ;;
  p)
    venv_directory="$OPTARG"
    ;;
  -)
    case "${OPTARG}" in
    dev)
      use_dev_requirements=true
      ;;
    force)
      force_reinstall=true
      ;;
    help)
      display_help
      ;;
    requirements=*)
      requirements_file="${OPTARG#*=}"
      ;;
    venv-dir=*)
      venv_directory="${OPTARG#*=}"
      ;;
    *)
      echo "Invalid option: --$OPTARG" >&2
      exit 1
      ;;
    esac
    ;;
  \?)
    echo "Invalid option: -$OPTARG" >&2
    exit 1
    ;;
  :)
    echo "Option -$OPTARG requires an argument." >&2
    exit 1
    ;;
  esac
done

# Set virtual environment directory
if [ -n "$venv_directory" ]; then
  venv_name="$venv_directory"
fi

# Function to create virtual environment
create_venv() {
  echo "Creating Python virtual environment..."
  # Install Python virtual environment
  if ! python3 -m venv "$venv_name"; then
    echo "Error: Failed to create virtual environment." >&2
    exit 1
  fi
  echo "Python virtual environment created successfully."
}

# Function to activate virtual environment
activate_virtualenv() {
  if [ "$platform" == "Linux" ]; then
    source "$venv_name/bin/activate"
  elif [ "$platform" == "Windows" ]; then
    source "$venv_name/Scripts/activate"
  fi
}

# Function to display the spinner animation
display_spinner() {
  local pid=$1
  local delay=0.75
  local spinstr='|/-\'
  while kill -0 $pid 2>/dev/null; do
    local temp=${spinstr#?}
    printf " [%c]  " "$spinstr"
    local spinstr=$temp${spinstr%"$temp"}
    sleep $delay
    printf "\b\b\b\b\b\b"
  done
  printf "    \b\b\b\b"
}

# Function to prompt for reusing virtual environment
prompt_for_reuse() {
  while true; do
    read -p "The virtual environment directory '$venv_name' already exists. Do you want to reuse it? (y/n): " yn
    case $yn in
    [Yy]*)
      echo "Reusing existing virtual environment..."
      break
      ;;
    [Nn]*)
      echo "Removing existing virtual environment..."
      if ! rm -rf "$venv_name"; then
        echo "Error: Failed to remove existing virtual environment directory." >&2
        exit 1
      fi
      create_venv
      break
      ;;
    *)
      echo "Please answer 'y' for yes or 'n' for no."
      ;;
    esac
  done
}

# Check if virtual environment directory already exists, else create it
if [ -d "$venv_name" ]; then
  prompt_for_reuse
else
  create_venv
fi

# Activate virtual environment
activate_virtualenv

upgrade_pip() {
  local cmd="pip install --upgrade pip"
  cmd+=" > ${venv_name}/pip_upgrade_output.txt 2>&1 "
  eval "${cmd}"
}

upgrade_pip_in_background() {
  # Run pip upgrade in the background and capture its PID
  upgrade_pip &
  pip_upgrade_pid=$!

  # Display the spinner animation while the pip upgrade command is running
  display_spinner $pip_upgrade_pid

  # Wait for the pip upgrade command to complete and capture its exit status
  wait $pip_upgrade_pid
  pip_upgrade_status=$?

  # Check if the pip upgrade command was successful
  if [ $pip_upgrade_status -ne 0 ]; then
    echo "Error: Failed to upgrade pip." >&2
    exit 1
  fi
}

echo "Upgrading pip..."
upgrade_pip_in_background
echo "pip upgraded successfully."

if [ -z "$requirements_file" ]; then
  if [ "$use_dev_requirements" = true ]; then
    requirements_file="dev-requirements.txt"
  else
    requirements_file="requirements.txt"
  fi
fi

# Verify if the requirements file exists
if [ ! -f "$requirements_file" ]; then
  echo "Error: The specified requirements file '$requirements_file' does not exist." >&2
  echo "You can provide a valid requirements file using the -r or --requirements option." >&2
  exit 1
fi

# Function to install required packages using pip
install_packages() {
  local cmd="pip install -r $requirements_file"
  if [ "$force_reinstall" = true ]; then
    cmd+=" --force-reinstall"
  fi
  cmd+=" > ${venv_name}/pip_install_output.txt 2>&1 "
  eval "${cmd}"
}

install_packages_in_background() {
  # Run pip install in the background and capture its PID
  install_packages &
  pip_install_pid=$!

  # Display the spinner animation while the pip install command is running
  display_spinner $pip_install_pid

  # Wait for the pip install command to complete and capture its exit status
  wait $pip_install_pid
  pip_install_status=$?

  # Check if the pip install command was successful
  if [ $pip_install_status -ne 0 ]; then
    echo "Error: Failed to install required packages." >&2
    exit 1
  fi
}

# Install required packages
echo "Installing required packages from $requirements_file..."
install_packages_in_background
echo "Required packages installed successfully."

echo "Python virtual environment setup completed successfully."

# Recap of operations
echo -e "\n=== Recap of Operations ==="
echo "Virtual Environment Directory: $venv_name"
echo "Use Dev Requirements: $use_dev_requirements"
echo "Force Reinstall: $force_reinstall"
echo "Requirements File: $requirements_file"
echo "Platform: $platform"
