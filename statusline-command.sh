#!/bin/bash

# Efficient bash status line for Claude Code
# Reads JSON from stdin and outputs status information

# Read JSON input
input=$(cat)

# Extract basic info using jq (fast single pass)
model_name=$(echo "$input" | jq -r '.model.display_name // .model.id')
current_dir=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
transcript_path=$(echo "$input" | jq -r '.transcript_path')

# Get folder name
folder_name=$(basename "$current_dir")

# Get git branch (suppress errors)
git_branch=""
if git -C "$current_dir" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    git_branch=$(git -C "$current_dir" branch --show-current 2>/dev/null)
    if [ -z "$git_branch" ]; then
        git_branch=$(git -C "$current_dir" rev-parse --short HEAD 2>/dev/null)
    fi
fi

# Get current date and time
current_datetime=$(date '+%Y-%m-%d %H:%M:%S')
datetime_info=" | \033[93m⏰ $current_datetime\033[0m"

# Build output with ANSI colors
# Hacker green: \033[92m, Cyan: \033[96m, Bright yellow: \033[93m, Reset: \033[0m
output="\033[92m[$model_name]\033[0m 📁 \033[96m$folder_name\033[0m"
if [ -n "$git_branch" ]; then
    output="$output | ⚡️ $git_branch"
fi

# Add datetime info
output="$output$datetime_info"

echo -e "$output"