# Converts your git stashes to a .patch to apply
# this is helpful when you have a new device and need to transfer/backup your stashes in case you need them.
#
# Tested on macOS Sequoia
#
# Save this in the base of the repo
# Run this in terminal:
# chmod +x stash_to_patch.sh
# ./stash_to_patch.sh


#!/bin/bash

# Get the current directory name as the repo name
repo_name=$(basename "$PWD")

# Create a directory to store the patch files
mkdir -p "${repo_name}_stashes"

# Function to sanitize branch names
sanitize_branch_name() {
    echo "$1" | sed 's/[^a-zA-Z0-9._-]/_/g'
}

# Use git fsck to find all stash commits
git fsck --no-reflog | awk '/dangling commit/ {print $3}' | while read -r commit; do

    if git show -s --format=%s "$commit" | grep -q "WIP on"; then

        # This is likely a stash commit
        stash_message=$(git show -s --format=%s "$commit")
        branch_name=$(echo "$stash_message" | sed 's/WIP on \(.*\):.*/\1/' | xargs)
        sanitized_branch=$(sanitize_branch_name "$branch_name")

        # Create patch file
        git show "$commit" >"${repo_name}_stashes/${repo_name}_${sanitized_branch}_${commit:0:7}.patch"
        echo "Created patch for stash on branch $branch_name (commit ${commit:0:7})"

    fi
done

echo "All found stashes have been exported to ${repo_name}_stashes directory"
