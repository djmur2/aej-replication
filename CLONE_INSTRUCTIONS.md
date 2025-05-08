# Clone and Update Instructions

This document provides instructions for cloning and updating the replication package repository.

## Cloning the Repository

To clone the repository to your local machine, use one of the following methods:

### Using HTTPS

```bash
# Navigate to the directory where you want to clone the repository
cd /path/to/desired/location

# Clone the repository
git clone https://github.com/djmur2/aej-replication.git

# Navigate into the cloned repository
cd aej-replication
```

### Using SSH (if you have SSH keys set up)

```bash
# Navigate to the directory where you want to clone the repository
cd /path/to/desired/location

# Clone the repository
git clone git@github.com:djmur2/aej-replication.git

# Navigate into the cloned repository
cd aej-replication
```

## Updating the Repository

If you've already cloned the repository and want to get the latest updates:

```bash
# Navigate to your local copy of the repository
cd /path/to/aej-replication

# Fetch the latest changes
git fetch origin

# Update your local copy with the latest changes
git pull origin main
```

## Checking Status

To check the status of your local repository:

```bash
# View the current status
git status

# View the commit history
git log --oneline --graph --decorate --all
```

## Creating Directories for Output

The replication code expects certain directories to exist. Create them if they don't:

```bash
# Create the final data and output directories
mkdir -p 2_final_data 4_output
```

## Running the Replication

After cloning, follow the instructions in the README.md file to run the replication: