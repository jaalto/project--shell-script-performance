#! /bin/bash
#
# Q: Howabout using `parallel` to speed up `grep`?
# A: `parallel` won't help in typical cases. Use only with huge files.
# priority: 1
#
#     t0  real 0m0.005s grep baseline
#     t1a real 0m0.210s --block-size <default> --pipepart
#     t1b real 0m0.240s --block-size <default> (Linux 64k)
#     t2  real 0m0.234s --block-size 64k (grep instance for every 1k lines)
#     t3  real 0m0.224s --block-size 32k
#
# Notes:
#
# The idea was to split file into chunks and run
# grep` in parallel for each chunk.
#
# The `grep` by itself is very fast. The startup time
# of `parallel`, implemented in `perl`, is taking the
# toll with the parallel if the file sizes are
# relatively small (test file: ~600 lines).

. ./t-lib.sh # ; f=$random_file

LANG=C

# can be set externally
re=${re:-'ad'}
size=${size:-50k}

dict=t.random.dictionary.$size
f=$dict

AtExit ()
{
    [ "$dict" ] || return 0
    [ -f "$dict" ] || return 0

    rm --force "$dict"
}

Setup ()
{
    RandomWordsDictionary $size > $dict
}

t0 ()  # Baseline
{
    grep --quiet --fixed-strings "$re" $f
}

t1a ()
{
    parallel --pipepart grep --quiet --fixed-strings "$re" < $f
}

t1b ()
{
    # Use default values. In Linux blocksize is around 64k
    parallel --pipe grep --quiet --fixed-strings "$re" < $f
}

t2 ()
{
    parallel --pipe --block-size 32k grep --quiet --fixed-strings "$re" < $f
}

t3 ()
{
    parallel --pipe --block-size 16k grep --quiet --fixed-strings "$re" < $f
}


trap AtExit EXIT HUP INT QUIT TERM

Setup
echo "test file: $(ls -l $f)"
echo "test file: lines $(wc -l $f)"

if ! command -v parallel > /dev/null; then
    Warn "INFO: no parallel found. Skipping tests."
else

    t t0

    if IsCygwin; then
        echo "# t1 ... skip on Cygwin (no 64k blocksize in parallel)"
    else
        t t1a
        t t1b
    fi

    t t2
    t t3
fi

# End of file
