#!/bin/bash

echo "Stopping Docker and cleaning up processes..."
# Terminate Docker-related processes
osascript -e 'quit app "Docker"' 2>/dev/null

echo "Removing Docker Desktop and Binaries..."
# Remove the main application and CLI tools
sudo rm -rf /Applications/Docker.app
sudo rm -f /usr/local/bin/docker
sudo rm -f /usr/local/bin/kubectl
sudo rm -f /usr/local/bin/kubeadm
sudo rm -f /usr/local/bin/kubelet
sudo rm -f /usr/local/bin/docker-compose
sudo rm -f /usr/local/bin/docker-credential-desktop
sudo rm -f /usr/local/bin/docker-credential-ecr-login
sudo rm -f /usr/local/bin/docker-credential-osxkeychain

echo "Purging Kubernetes and Docker configuration files..."
# This removes the local cluster data and settings
rm -rf ~/.docker
rm -rf ~/.kube
rm -rf ~/Library/Containers/com.docker.docker
rm -rf ~/Library/Containers/com.docker.helper
rm -rf ~/Library/Group\ Containers/group.com.docker
rm -rf ~/Library/Application\ Support/Docker\ Desktop
rm -rf ~/Library/Preferences/com.docker.docker.plist
rm -rf ~/Library/Saved\ Application\ State/com.electron.docker-frontend.savedState

# Remove privileged helper tools
sudo rm -f /Library/PrivilegedHelperTools/com.docker.vmnetd
sudo rm -f /Library/LaunchDaemons/com.docker.vmnetd.plist

echo "Cleanup complete."
