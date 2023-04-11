#!/bin/bash
# This checks if the number of arguments is correct
# If the number of arguments is incorrect ( $# != 2) print error message and exit
if [[ $# != 2 ]]; then
  echo "Usage: $0 target_directory_name destination_directory_name"
  exit
fi

# This checks if argument 1 and argument 2 are valid directory paths
if [[ ! -d $1 ]] || [[ ! -d $2 ]]; then
  echo "Invalid directory path provided"
  exit
fi

# [TASK 1]
targetDirectory=$1
destinationDirectory=$2

# [TASK 2]
echo "the target directory is $targetDirectory"
echo "the destination directory is $destinationDirectory"

# [TASK 3]
currentTS=$(date +%s)

# [TASK 4]
backupFileName="backup-$currentTS.tar.gz"

# We're going to:
# 1: Go into the target directory
# 2: Create the backup file
# 3: Move the backup file to the destination directory

# To make things easier, we will define some useful variables...

# [TASK 5]
origAbsPath=$(pwd)

# [TASK 6]
cd $destinationDirectory
destDirAbsPath=$(pwd)

# [TASK 7]
cd $origAbsPath
cd $targetDirectory
# this code will create a variable yesterday and store  the date difference
# [TASK 8]
yesterdayTS=$(($currentTS - 24 *60 * 60))

declare -a toBackup
for file in $(ls); do
  # [TASK 9]
  if [[ -f "$file" ]]; then
    # [TASK 10]
    if (( `date -r "$file" +%s` > $yesterdayTS ));
     then
      # [TASK 11]
      toBackup+=($file)
    fi
  fi
done
if [[ ${#toBackup[@]} -eq 0 ]]; then
  echo "No files to backup"
  exit
fi

# [TASK 12]
tar -czvf $backupFileName ${toBackup[@]}

if [[ ! -s $backupFileName ]]; then
  echo "Backup failed"
  rm $backupFileName
  exit
fi

# [TASK 13]
mv $backupFileName $destDirAbsPath
# Congratulations! You completed the final project for this course!
