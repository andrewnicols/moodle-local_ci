#!/usr/bin/env bash
# $WORKSPACE
# $phpcmd: Path to the PHP CLI executable
# $gitdir: Directory containing git repo
# $gitbranch: Branch we are going to check

# Let's go strict (exit on error)
set -e

# Verify everything is set
required="WORKSPACE phpcmd gitdir gitbranch"
for var in $required; do
    if [ -z "${!var}" ]; then
        echo "Error: ${var} environment variable is not defined. See the script comments."
        exit 1
    fi
done

# file where results will be sent
resultfile=$WORKSPACE/check_upgrade_savepoints_${gitbranch}.txt
echo -n > "$resultfile"

# calculate some variables
mydir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Co to proper gitdir and gitpath
cd "$gitdir"
if [ -d "{$gitdir}/.git" ]; then
  # Only if it's a git dir.
  if git -C . rev-parse 2> /dev/null; then
      git reset --hard $gitbranch
  fi
else
  echo "Not a git directory. Not resetting git directories."
fi

# copy the checker to the gitdir
cp $mydir/check_upgrade_savepoints.php $gitdir/

# Run the savpoints checker utility, saving results to file
${phpcmd} $gitdir/check_upgrade_savepoints.php > "$resultfile"

# remove the checker from gitdir
rm -fr $gitdir/check_upgrade_savepoints.php

# Look for ERROR or WARN in the resultsfile
count=`grep -P "ERROR|WARN" "$resultfile" | wc -l`
# Check if there are problems
if (($count > 0))
then
    exit 1
fi
exit 0
