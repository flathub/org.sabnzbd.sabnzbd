#!/bin/sh
# Run from the root of the sabnzbd sources or git repo to look for direct module imports.
# Outputs a sorted requirements file with the sabctools version taken from constants.py.
#
# Optional arguments:
# 1: SABnzbd source location [path] (default: current work directory)
# 2: Inherit versions pinned in the upstream requirements file? [yes|no] (default: yes)

set -e -u

# ----- <config> ---------------------------------------------------------------
# Modules only needed on windows or mac (separator=|)
PYTHON_FOREIGN_LIBS="win32.*|ntsecuritycon|objc|servicemanager|pywintypes|Foundation|AppKit|PyObjCTools|timer|windows_toasts"
# Modules handled directly in the manifest file or via an entry in EXTRA_LIBS such as gi->gobject (separator=|)
PYTHON_MANIFEST_LIBS="cryptography|dbus|gi|orjson|sabnzbd|ujson"
# Extra modules to insert (separator=\n)
PYTHON_EXTRA_LIBS="pycairo\npygobject"
# Python sources to search (space-separated files, directories, or glob patterns)
SABNZBD_PYTHON_FILES="SABnzbd.py sabnzbd/*.py sabnzbd/utils/*.py"
# ----- </config> --------------------------------------------------------------

# Handle command line arguments
[ $# -ge 1 ] && [ -d "$1" ] && cd "$1"
KEEP_UPSTREAM_VERSIONING="${2:-yes}"

# Collect the list of stdlib modules for the current Python version
PYTHON_STD_LIBS="$(python3 -c 'import sys; print("|".join(sys.stdlib_module_names))')"
# Determine the version of sabctools required by the current sabnzbd release
SABCTOOLS_VERSION="$(python3 -S -c 'import os; os.chdir("sabnzbd"); import constants as C; print(C.SABCTOOLS_VERSION_REQUIRED)')"

# Look for module imports that aren't commented out, in stdlib, or relative; then remove anything
# needed only on other operating systems or handled directly in the manifest file, and if necessary
# convert the import name to the pypi handle.
INITIAL_LIST=$(grep -E -r -h -- '^([^#]* )?import ' $SABNZBD_PYTHON_FILES \
	| grep -v -E -- "(from|import) +($PYTHON_STD_LIBS)($|\.|[[:space:]])" \
	| sed -n 's/^[[:space:]]*\(from\|import\) \([a-zA-Z0-9_]\+\).*/\2/p' \
	| grep -v -E -- "^($PYTHON_FOREIGN_LIBS|$PYTHON_MANIFEST_LIBS)$" \
	| sed -e "s/^Cheetah$/CT3/g" -e "s/^socks$/PySocks/g")

# Verify the results against the upstream requirements file and discard anything not listed there
VERIFIED_LIST=
for MODULE in $INITIAL_LIST; do
	# Import names may include an underscore but never a hyphen; pypi projects and requirements.txt
	# on the other hand do use hyphens (underscores still work though). Hence, a bit of flexibility
	# is needed when comparing module search results with upstream.
	MODULE_REGEXP="$(printf '%s' "$MODULE" | sed -e 's/_/[-_]/')"
	UPSTREAM_ENTRY="$(sed -n "s/^\($MODULE_REGEXP\([!<>=]=[^;#[:space:]]\+\)\?\).*/\1/p" requirements.txt)"
	if [ "$UPSTREAM_ENTRY" ]; then
		[ "$KEEP_UPSTREAM_VERSIONING" = "yes" ] && MODULE_ENTRY="$UPSTREAM_ENTRY" || MODULE_ENTRY="$MODULE"
		# Append to verified list
		[ -n "$VERIFIED_LIST" ] && VERIFIED_LIST="$VERIFIED_LIST\n$MODULE_ENTRY" || VERIFIED_LIST="$MODULE_ENTRY"
	else
		printf '%s\n' "WARNING: discarding module '$MODULE', not in upstream requirements; script '$(basename "$0")' may need an update" >&2
	fi
done

# Insert extra modules, set the sabctools version, replace underscores, sort, and print to stdout
printf '%b' "$VERIFIED_LIST" \
	| sed -e "\$a\\$PYTHON_EXTRA_LIBS" \
	| sed -e "s/^sabctools$/&==$SABCTOOLS_VERSION/" \
	| sed -e "s/_/-/g" \
	| sort -u -f
