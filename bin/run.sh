#! /bin/sh
#
#   Copyright
#
#       Copyright (C) 2024-2025 Jari Aalto
#
#   License
#
#       This program is free software; you can redistribute it and/or modify
#       it under the terms of the GNU General Public License as published by
#       the Free Software Foundation; either version 2 of the License, or
#       (at your option) any later version.
#
#       This program is distributed in the hope that it will be useful,
#       but WITHOUT ANY WARRANTY; without even the implied warranty of
#       MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#       GNU General Public License for more details.
#
#       You should have received a copy of the GNU General Public License
#       along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# Usage
#
#       See the --help option.

set -o errexit # Exit on error
set -o nounset # Treat unused variables as errors

PREFIX="-- "
PROGRAM=${0##*/}
LINE=$(printf '%*s' "55" '' | tr ' ' '-')
RUN_SHELL=""

pwd=$(cd "$(dirname "$0")" && pwd)

# ignore follow
# shellcheck disable=SC1091

. "$pwd/t-lib.sh"   # Common library

Help ()
{
    echo "\
SYNOPSIS
    $PROGRAM [options] <test case> [<test case> ...]

OPTIONS
    -s, --shell SHELL
        Run test case unser SHELL. Like ksh, mksh etc.

    -h, --help
        Display help.

DESCRIPTION
    Display commentary from <test case> and run the file.

EXAMPLES
    ./$PROGRAM t-test-case.sh
    ./$PROGRAM --shell ksh t-test-case.sh

    # Modify the default repeat count \$loop_max (see t-lib.sh)
    loop_max=500 ./$PROGRAM t-test-case.sh"

    exit 0
}

FileInfo ()
{
    awk '
        /^#!/, /^$/ {
            print
        }

    ' "$1"
}

Header ()
{
    echo "\
${PREFIX}$LINE
${PREFIX}$1
${PREFIX}$LINE"

}

Run ()
{
    Header "$1"
    FileInfo "$1"

    if [ "$RUN_SHELL" ]; then
        echo "Run shell: $RUN_SHELL"
        $RUN_SHELL "./$1"
    else
        "./$1"
    fi
}

Main ()
{
    local dummy

    while :
    do
        # Unused, but useful during debug
        # shellcheck disable=SC2034
        dummy="OPT: $1"

        case "$1" in
            -s | --shell)
                RUN_SHELL=$2
                shift ; shift
                ;;
            -h | --help)
                shift
                Help
                ;;
            --)
                shift
                break
                ;;
            -*)
                Warn "$PROGRAM: WARN Unknown option: $1"
                shift
                ;;
            *)
                break
                ;;
        esac
    done

    if [ ! "$1" ]; then
        Die "ERROR: missing <test case file>. See --help."
    fi

    for file in "$@"
    do
        [ -f "$file" ] || continue
        Run "$file"
    done
}

Main "$@"

# End of file
