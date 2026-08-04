#!/bin/zsh
# Get script directory and dotfiles root directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"  # Parent of scripts directory

# Jupyter notebook helpers

# Function to start Jupyter notebook without browser
# Usage: jup [port] [directory]
jup() {
    local port=${1:-8888}
    local directory=${2:-"$HOME"}
    
    # Check if Jupyter is installed
    if ! command -v jupyter &> /dev/null; then
        echo "Jupyter not found. Installing..."
        if command -v conda &> /dev/null; then
            conda install -y jupyter
        else
            pip install jupyter
        fi
    fi
    
    # Navigate to the directory and start jupyter
    cd "$directory" && jupyter notebook --no-browser --port=$port
}

# Function to create a symlink to Windows Documents in WSL
# Usage: jup-link [windows_username]
jup-link() {
    # Only run on WSL
    if [[ ! -f /proc/version ]] || ! grep -q Microsoft /proc/version 2>/dev/null; then
        echo "This command is only for WSL environments."
        return 1
    fi
    
    local username=${1:-$(cmd.exe /c echo %USERNAME% 2>/dev/null | tr -d '\r')}
    local windows_docs="/mnt/c/Users/$username/Documents"
    local notebook_dir="$HOME/notebooks"
    
    # Check if Windows Documents directory exists
    if [ ! -d "$windows_docs" ]; then
        echo "Windows Documents directory not found at $windows_docs"
        echo "Please provide the correct Windows username as parameter"
        return 1
    fi
    
    # Create symlink if it doesn't exist
    if [ ! -L "$notebook_dir" ]; then
        echo "Creating symlink from $windows_docs to $notebook_dir"
        ln -s "$windows_docs" "$notebook_dir"
    else
        echo "Symlink already exists at $notebook_dir"
    fi
    
    echo "You can now use 'jup 8888 ~/notebooks' to start Jupyter with access to Windows files"
}

# Function to setup a full Jupyter environment
# Usage: jup-setup
jup-setup() {
    if command -v conda &> /dev/null; then
        echo "Setting up Jupyter environment..."
        conda install -y jupyter ipykernel nb_conda_kernels
        
        # Install common data science packages
        conda install -y numpy pandas matplotlib seaborn scikit-learn
        
        # Install jupyter extensions
        conda install -y -c conda-forge jupyter_contrib_nbextensions
        jupyter contrib nbextension install --user
        
        echo "Jupyter environment setup complete!"
    else
        echo "Conda not found. Please install conda first."
        return 1
    fi
}

# Aliases for Jupyter commands
alias jnb='jupyter notebook'
alias jnb-browser='jupyter notebook'
alias jnb-no-browser='jupyter notebook --no-browser'
alias jlab='jupyter lab'
alias jlab-no-browser='jupyter lab --no-browser'

# If we're in WSL, add specific WSL aliases
if [[ -f /proc/version ]] && grep -q Microsoft /proc/version 2>/dev/null; then
    alias jnb='jupyter notebook --no-browser'
    alias jlab='jupyter lab --no-browser'
    
    # Alias to quickly create link to Windows documents
    alias notebooks-link='jup-link'
fi
