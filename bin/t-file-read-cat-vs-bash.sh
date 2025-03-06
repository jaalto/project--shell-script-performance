#! /bin/bash
#
# Q: Should I use `$(< FILE)´ over `$(cat FILE)`?
# A: The `$(< FILE)´ 1s bbout 2x faster for small files
#
#     t1 real 0m0.166s $(< file)
#     t2 real 0m0.365s $(cat file)
#
# Notes:
#
# With big files, they are equal.
#
#     . ./t-lib.sh; RandomWordsDictionary 1M > t.1M
#
#     time bash -c 's=$(cat t.1M); echo "$s" > /dev/null'
#     real 0m0.059s
#
#     time bash -c 's=$(< t.1M); echo "$s" > /dev/null'
#     real 0m0.056s

. ./t-lib.sh ; f=$random_file

tmp=t.tmp

t1 ()
{
    for i in $(seq $loop_max)
    do
        val=$(< $f)
    done
}

t2 ()
{
    for i in $(seq $loop_max)
    do
        val=$(cat $f)
    done
}

t ()
{
    echo -n "# $1"
    time $1
    echo
}

t t1
t t2

# End of file
