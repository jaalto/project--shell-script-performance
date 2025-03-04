# SHELL SCRIPT PERFORMANCE TESTS

How to write faster and optimized shell scripts?

That's the question these tests try to answer.
See files:

- [RESULTS](./doc/RESULTS.txt)
- [RESULTS-BRIEF](./doc/RESULTS-BRIEF.txt)
- The test cases and code in [bin/](./bin/)
- [USAGE](./USAGE.md)

This project includes tests to determine the
most efficient way to write shell script code.

Consider the raw `time(1)` results only as
guidance, as they reflect the system used.
Instead, compare the relative order in which
each test case produced the fastest results.

## The project structure

        bin/          The tests
        doc/          Results generated by "make doc"
        COPYING       License file (GNU GPL)
        INSTALL       Install instructions
        USAGE.md      How to run the tests
        CONTRIBUTING  Writing more tests shell scripts

## Project details

- Homepage:
  https://github.com/jaalto/project--shell-script-performance

- To report bugs:
  see homepage.

- Source code repository:
  see homepage.

- Depends:
  Bash and POSIX shell.

- Optional depends:
  `make` (any version). Used as
  a frontend to call utilities.

# MAJOR PERFORMANCE GAINS

- Avoid extra processes at all costs.
  Instead, a single
  [awk(1)](https://www.gnu.org/software/gawk/)
  may be able to handle all.
  Program `awk` is *very* fast and
  more efficient than perl(1) or python(1)
  for many quite a many file manipulation
  tasks.

```
    cmd | awk '{...}'

    # ... Avoid
    cmd | head ... | cut ...
    cmd | grep ... | sed ...
```

- Use built-ins. Not binaries:

```
    echo ...    # not /bin/echo
    printf ...  # not /bin/printf
    [ ... ]     # not: /bin/test
```

- In functions, using nameref (Bash) to return a
  value is about 40 times faster than `ret=$(fn)`.
  Use this:


```
    fn()
    {
        local -n retref=$1  # nameref
        shift
        local arg=$1

        retref="value"
    }

    # return value in 'ret'
    fn ret "arg"
```

- For line-by-line handling, read the file
  into an array and then loop through the array.
  If you're wondering `readarray' vs `maparray',
  there is no differende.

```
    readarray -t array < file

    for i in "${array[@]}"
    do
        ...
    done

    # This would be 2x slower

    while read -r ...
    do
        ...
    done < FILE
```

- To process only certain lines, use a prefilter
  with grep(1) instead of reading the whole file
  into a loop and then selecting lines. Bash loops
  are slow in general..

```
  while read -r ...
  do
          ...
  done < <(grep -E "$re" "$file")
```

  That will be much faster than excluding or
  picking lines inside loop with `contine` or
  `if...fi`.

- It is faster to read a file into memory as a
  string and use Bash regular expression tests
  on that string. This is much more efficient
  than calling the external `grep(1)` command.

```
   read -N100000 < "$file"

   if [[ $REPLY =~ $regexp1 ]]; then
       ...
   elif [[ $REPLY =~ $regexp2 ]]; then
       ...
   fi
```

# MODERATE PERFORMANCE GAINS

- To split a string into an array, use `eval`,
  which is much faster than using a here-string.
  This is likely because `<<<` uses a temporary
  file, whereas `eval` operates entirely in
  memory.

```
    string=$(echo {1..100})
    eval 'array=($string)'

    # Much slower
    read -ra array <<< "$string"
```

# NEGLIGIBLE OR NO PERFORMANCE GAINS

According to the tests, there is no practical
difference between the following examples. See
the raw test results for details and further
commentary.

- The Bash specific `[[ ]]` might offer
  a tad minuscle advantage.

```
    [ "$var" = "1" ] # POSIX
    [[ $var = 1 ]]   # Bash

    [ ! "$var" ]     # POSIX
    [[ ! $var ]]     # Bash
    [ -z "$var" ]    # archaic
```

- There are no differences between these:

```
    i=$((i + 1))     # POSIX
    : $((i++))       # POSIX, Uhm...
    ((i++))          # Bash
    let i++          # Bash
```

- The Bash-specific `{1..N}` might offer a
  minuscule advantage, but it's impractical
  because `N` cannot be parameterized.
  Surprisingly, a simple and elegant winner by a
  hair is `$(seq N)`. The POSIX `while`-loop
  variant was slightly slower in all subsequent
  tests.

```
    for i in {1..100}
        do
                ...
        done

        for i in $(seq $N)
        do
                ...
        done

        for ((i=0; i < $N; i++))
        do
                ...
        done

    while [ "$i" -le "$N" ]
        do
                i=$((i + 1))
        done
```

# RANDOM NOTES

See the
[bash(1)](https://www.gnu.org/software/bash/manual/bash.html#index-TIMEFORMAT)
manual page how to use `time`
command to display results in different formats:

        TIMEFORMAT='real: %R'  # '%R %U %S'

You could also drop kernel cache before testing:

        echo 3 > /proc/sys/vm/drop_caches

# COPYRIGHT

Copyright (C) 2024-2025 Jari Aalto

# LICENSE

These programs are free software; you can redistribute it and/or modify
them under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

These programs are distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with these programs. If not, see <http://www.gnu.org/licenses/>.

License: GPL-2-or-later - https://spdx.org/licenses

Keywords: shell, sh, posix, bash, programming,
optimize, performance, profiling
