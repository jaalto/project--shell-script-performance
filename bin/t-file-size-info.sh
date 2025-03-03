#! /bin/bash
#
# Q: What is the fastest way to read a file's size?
# A: GNU 'wc -c'. The stat(1) is not in POSIX + options are not portable.
#
# t1 real    0m0.288s stat -c file
# t2 real    0m0.380s wc -c file; GNU version efectively is like stat(1)
# t3 real    0m0.461s ls -l + awk

. ./t-lib.sh ; f=$random_file

t1 ()
{
    for i in $(seq $loop_max)
    do
        size=$(stat -c %s "$f")
    done
}

t2 ()
{
    for i in $(seq $loop_max)
    do
        # More portable
        #
        # GNU  coreutils implementation optimizes this
        # away using fstat(). Efectively same as stat().
        size=$(wc -c "$f")
    done
}

t3 ()
{
    for i in $(seq $loop_max)
    do
        size=$(ls -l "$f" | awk '{print $5; exit}')
    done
}

t t1
t t2
t t3

# End of file
