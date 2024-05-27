#!/bin/sh
set -e

# # Check for common-utils feature in both local and global directories
# for dir in "/.devcontainer/features" "/usr/local/share/devcontainer/features"; do
#   if [ -f "${dir}/ghcr.io/devcontainers/features/common-utils/devcontainer-feature.json" ]; then
#     # Update common-utils configuration to set configureZshAsDefaultShell to true
#     json_file="${dir}/ghcr.io/devcontainers/features/common-utils/devcontainer-feature.json"
#     json_key=".options.configureZshAsDefaultShell"
#     new_value="true"

#     # Use jq command to update the JSON file
#     jq -r --arg new_value "$new_value" '.[$json_key]=$new_value' $json_file > temp.json && mv temp.json $json_file
#   fi
# done
# # The value of option1 for featureA would typically be passed as an environment variable
# OPTION1=${_REMOTE_USER_HOME}/.vscode-server/extensions/.devcontainer/featureA/option1

# # Check if option1 is true
# if [ "$OPTION1" != "true" ]; then
#     echo "Error: Feature B requires Feature A to have option1 set to true."
#     exit 1
# fi

echo "\nActivating feature 'Powerlevel10k with Meslo font'\n"

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

# Use provided environment variables
USERNAME="${_REMOTE_USER}"
USER_HOME="${_REMOTE_USER_HOME}"

export DEBIAN_FRONTEND=noninteractive

echo "\nUpdating package list and installing packages..."

apt-get update && apt-get install -y \
    curl \
    xz-utils \
    git && \
    # fontconfig \
    # jq  && \
    apt-get clean
    # rm -rf /var/lib/apt/lists/*

echo "Packages installed successfully."

echo "\nInstalling Meslo font."

mkdir -p /usr/local/share/fonts/ ;
cd /usr/local/share/fonts ;
curl -OL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.tar.xz ;
tar -xf Meslo.tar.xz ;
rm -f Meslo.tar.xz

# fc-cache -fv

echo "\nMeslo font installed and cached successfully."

#-----------Install powerlevel10k ---------
# Default install directory for powerlevel10k
P10_INSTALL_DIR="$USER_HOME/powerlevel10k"

# Check if common-utils feature is already installed
# if [ -f "/usr/local/share/devcontainer/features/ghcr.io/devcontainers/features/common-utils/devcontainer-feature.json" ]; then
#   # Update common-utils configuration to set configureZshAsDefaultShell to true
#   json_file="/usr/local/share/devcontainer/features/ghcr.io/devcontainers/features/common-utils/devcontainer-feature.json"
#   json_key=".options.configureZshAsDefaultShell"
#   new_value="true"

#   # Use jq command to update the JSON file
#   jq -r --arg new_value "$new_value" '.[$json_key]=$new_value' $json_file > temp.json && mv temp.json $json_file
# fi



echo "Checking whether oh-my-zsh has been installed and .zshrc has been configured"

# Check if oh-my-zsh is installed (Note: oh-my-zsh is not required for powerlevel10k to work)
# Define the path to the Oh My Zsh installation directory
OH_MY_ZSH_DIR="${USER_HOME}/.oh-my-zsh"
ZSHRC_FILE="${USER_HOME}/.zshrc"

# Check if the Oh My Zsh directory exists and contains expected files
if [ -d "$OH_MY_ZSH_DIR" ] && [ -f "$OH_MY_ZSH_DIR/oh-my-zsh.sh" ]; then
    echo "oh-my-zsh has been installed."
    # Check if .zshrc is configured to use Oh My Zsh
    if [ -f "$ZSHRC_FILE" ] && grep -q "oh-my-zsh.sh" "$ZSHRC_FILE"; then
        echo ".zshrc has been configured for oh-my-zsh."
        echo "powerlevel10k will be installed inside of oh-my-zsh custom themes directory."
        P10_INSTALL_DIR=${ZSH_CUSTOM:-$USER_HOME/.oh-my-zsh/custom}/themes/powerlevel10k:
    else
        echo ".zshrc has NOT been configured for oh-my-zsh."
        echo "powerlevel10k will be installed the user's home directory."
    fi
else
    echo "oh-my-zsh is not installed."
    echo "powerlevel10k will be installed the user's home directory."
fi

echo "Installing Powerlevel10k."

git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $P10_INSTALL_DIR
echo "source $P10_INSTALL_DIR/powerlevel10k.zsh-theme" >> $_REMOTE_USER_HOME/.zshrc

chown -R $_REMOTE_USER:$_REMOTE_USER "$P10_INSTALL_DIR"

echo "Powerlevel10k with Meslo font installed successfully."


# GREETING=${GREETING:-undefined}
# echo "The provided greeting is: $GREETING"

# The 'install.sh' entrypoint script is always executed as the root user.
#
# These following environment variables are passed in by the dev container CLI.
# These may be useful in instances where the context of the final
# remoteUser or containerUser is useful.
# For more details, see https://containers.dev/implementors/features#user-env-var
echo "The effective dev container remoteUser is '$_REMOTE_USER'"
echo "The effective dev container remoteUser's home directory is '$_REMOTE_USER_HOME'"

echo "The effective dev container containerUser is '$_CONTAINER_USER'"
echo "The effective dev container containerUser's home directory is '$_CONTAINER_USER_HOME'"

# cat > /usr/local/bin/hello \
# << EOF
# #!/bin/sh
# RED='\033[0;91m'
# NC='\033[0m' # No Color
# echo "\${RED}${GREETING}, \$(whoami)!\${NC}"
# EOF

# chmod +x /usr/local/bin/hello
