#  -*- mode: sh; -*-
#
#   t-lib.sh - Liibrary of common shell functions for testing.
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
#       . <file>
#
# Description
#
#       This is a library. Common utilities. When sourced, it will
#       create the following test files to be used by <test cases>:
#
#           t.random.numbers.tmp
#
#       Global variables used:
#
#           $verbose         in Verbose()
#
#       Exported variables:
#
#           $random_file
#           $loop_max

# Exported variables
random_file=${random_file:-t.random.numbers.tmp}  # create random number test file
loop_max=${loop_max:-100}
PROGRAM=$0

# Private variables. Will be unset after end of the file.
random_file_count=${random_file_count:-10000}
RUNNER=t.run

Warn ()
{
    echo "$*" >&2
}

Die ()
{
    Warn "$*"
    exit 1
}

Verbose ()
{
    [ "$verbose" ] || return 0
    echo "$*"
}

IsCygwin ()
{
    [ -d /cygdrive/c ]
}

Runner ()
{
    local run="$RUNNER.$$"

    echo "$*" > "$run"

    sh ./"$run"
    rm --force "$run"
}

RandomWordsGibberish ()
{
    # - Create file with SIZE containing random words.
    # - Limit output to column 80.
    # - Separate words by spaces.

    base64 --decode /dev/urandom |
        tr --complement --delete 'a-zA-Z0-9 ' |
        fold --width=80 |
        head --bytes="${1:-100k}"
}

RandomWordsDictionary ()
{
    if [ ! -e /usr/share/dict/words ]; then
        Die "ERROR: missing word dict. Debian: apt-get install wamerican"
    else
        shuf --head-count=200000 /usr/share/dict/words |
        awk '
            BEGIN {
                total_size = 0;
            }

            {
                if (length(line) + length($0) + 1 <= 80)
                {
                    if (length(line) > 0)
                        line = line " " $0;
                    else
                        line = $0;
                }
                else
                {
                    print line;
                    total_size += length(line) + 1;
                    line = $0;
                }
            }

            END {
                if (length(line) > 0)
                {
                    print line;
                    total_size += length(line) + 1;
                }
            }' |
        head --bytes=${1:-100k}
    fi
}

RandomNumbersAwk ()
{
    awk -v n="$1" '
    BEGIN {
        srand();

        for (i = 1; i <= n; i++)
            print int(rand() * (2**14 - 1))
    }'
}

RandomNumbersPerl ()
{
    perl -e "print int(rand(2**14-1)) . qq(\n) for 1..$1"
}

RandomNumbersPython ()
{
    python3 -c "import random; print('\n'.join(str(random.randint(0, 2**14-1)) for _ in range($1)))"
}

t () # Run a test case
{
    # We're supposing recent Bash 5.x or Ksh
    # which defines TIMEFORMAT
    #
    # In Ksh, ignore 'local' keyword

    local format hasformat 2> /dev/null
    format="real %3R  user %3U  sys %3S" # precision (3): N.NNN

    if [ "$ZSH_VERSION" ]; then
        # https://zsh.sourceforge.io/Doc/Release/Parameters.html
        # hasformat="TIMEFMT"
        # format="real %*E  user %*U  sys %*S"

        # ... maybe some later release
        Die "ERROR: in function t(), unfortunately zsh cannot time functions"
    elif [ "$BASH_VERSION" ]; then
        # https://www.gnu.org/software/bash/manual/bash.html#Bash-Variables
        hasformat="TIMEFORMAT"
    elif [ "$KSH_VERSION" ]; then
        case "$KSH_VERSION" in
            *MIRBSD*) # No format choise in mksh(1)
                ;;
            *)  hasformat="TIMEFORMAT"
                ;;
        esac
    else
        case "$0" in
            ksh | */ksh | */ksh93*)
                hasformat="TIMEFORMAT"
                ;;
        esac
    fi

    if [ "$hasformat" ]; then
        local timeformat 2> /dev/null

        eval "timeformat=\$$hasformat" # save
        printf "# %-15s" "$1"

        eval "$hasformat='$format'"    # set

        time "$@"

        eval "$hasformat='$timeformat'" # restore
        unset timeformat

    elif type time 2> /dev/null 2>&1; then
        # format the output using other means.

        printf "# $1  "

        # Wed Feb 12 15:16:15 EET 2025 0m00.00s real 0m00.00s user 0m00.00s system
        # =============================
        # sed to delete this part and limit output to 2 spaces.

        { time "$@" ; } 2>&1 |
            paste --serial --delimiters=" " |
            sed --regexp-extended \
                --expression 's,^.* +([0-9]+m[0-9.]+s +real),\1, ' \
                --expression 's,   +,  ,g' \
                --expression 's,\t,  ,g'

        echo  # Add newline
    else
        Die "ERROR: in function t(), no 'time' command"
    fi

    unset hasformat format
}

TestData ()
{
    # Create test data to use with all test cases.
    #
    # AWK is the fastest
    #
    # 0m0.008s  awk
    # 0m0.011s  perl
    # 0m0.043s  python
    #
    # time RandomNumbersAwk "$1" > /dev/null
    # time RandomNumbersPerl "$1" > /dev/null
    # time RandomNumbersPython "$1" > /dev/null

    if [ ! -f "$random_file" ]; then
        RandomNumbersAwk "$1" > "$random_file"
    fi
}

TestData $random_file_count
unset random_file_count

# End of file
