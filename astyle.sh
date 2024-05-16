#!/bin/bash

OPTIONS=$@

ASTYLE=$(which astyle)
if [ $? -ne 0 ]; then
	echo "[!] astyle not installed. Unable to check source file format policy." >&2
	exit 1
fi

RETURN=0
git diff --cached --name-status --diff-filter=ACMR |
{
	# Command grouping to workaround subshell issues. When the while loop is
	# finished, the subshell copy is discarded, and the original variable
	# RETURN of the parent hasn't changed properly.
	while read STATUS FILE; do
	if [[ "$FILE" =~ ^.+(c|cpp|h)$ ]]; then
		$ASTYLE $OPTIONS $FILE | read RESULT
		if [ -f $FILE.orig ]; then
			echo "[!] $FILE does not respect the agreed coding standards." >&2
			echo $RESULT
			RETURN=1
			rm $FILE.orig
		fi
	fi
	done

	exit $RETURN
}