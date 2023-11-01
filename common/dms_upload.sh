#!/bin/bash

# Directory to watch
WATCH_DIR="/home/maweki/Downloads"

# Maximum file size in bytes (1MB)
MAX_FILE_SIZE=1048576

# Maximum page count
MAX_PAGE_COUNT=10

# Remote host and directory for uploading PDF files
REMOTE_HOST="root@192.168.1.3"
REMOTE_DIR="/mnt/dms/paperless/consume/"

# Function to test SSH connection
test_ssh_connection() {
  if ssh -q "$REMOTE_HOST" exit; then
    echo "SSH connection to $REMOTE_HOST is successful."
    return 0
  else
    echo "Error: SSH connection to $REMOTE_HOST failed. Please check your SSH configuration."
    return 1
  fi
}

# Function to process PDF files
process_pdf() {
  local file="$1"
  local file_size=$(stat -c %s "$file")

  # Check if pdfinfo is installed
  if ! command -v pdfinfo &>/dev/null; then
    echo "Error: pdfinfo is not installed. Please install it before running this script."
    return 1
  fi

  local page_count=$(pdfinfo "$file" | grep "Pages:" | awk '{print $2}')

  # Test SSH connection before attempting to use scp for each file
  if [[ $file_size -le $MAX_FILE_SIZE && $page_count -le $MAX_PAGE_COUNT ]]; then
    echo "Processing PDF file: $file"
    if test_ssh_connection; then
      # Use scp to upload the PDF file to the remote host
      scp "$file" "$REMOTE_HOST:$REMOTE_DIR"
    else
      echo "Skipping PDF file: $file due to SSH connection error."
    fi
  else
    echo "Skipping PDF file: $file (Size: $file_size bytes, Pages: $page_count)"
  fi
}

# Check if inotifywait is installed
if ! command -v inotifywait &>/dev/null; then
  echo "Error: inotifywait is not installed. Please install it before running this script."
  exit 1
fi

# Start monitoring the directory for create and move events on PDF files
inotifywait -m -e create -e moved_to "$WATCH_DIR" |
  while read -r directory event file; do
    if [[ "$file" =~ \.pdf$ ]]; then
      sleep 10
      process_pdf "$directory/$file"
    fi
  done
