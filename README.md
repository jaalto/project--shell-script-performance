# README: Shell script performance tests

How to write faster shell scripts?

That's the question these tests try to answer:
see the `RESULTS*' files.

This project includes tests to determine the
most efficient way to write shell script code.

Please do not rely on raw result times, as
they reflect the system used. Instead, compare
the relative order in which each test case
yielded the fastest results.

## The file structure

```
    bin/            The tests
    RESULTS*        Generated; run "make doc"
```

## Important files

```
    COPYING         GPL-2-or-later
    INSTALL         Install instructions
```

## Project details

- Homepage:
  https://github.com/jaalto/project--shell-script-performance

- To report bugs:
  See above

- Source code repository:
  See above

- Depends:
  Bash and POSIX shell.

- Optional Depends:
  `make` (any version). Used as
  a frontend to call utilities.

# GENERAL PERFORMANCE TIPS

- Avoid extra processes at all costs.

- Use buitins.

- Use name refs (Bash) to return value from
  functions.


- In general, read file into memory as a
  STRING and use bash regexp tests on STRING.
  This is much faster than calling external
  grep(1).

- For line-to-line handling, read file
  into an array and then loop the array.

  It will be faster than doing:
  "while read ... done < FILE".

- To process only certain lines,
  use prefilter grep as in:
     "grep ... | while read -r ...done".
  Much faster than excluding or picking lines
  inside loop (contine, or if...fi).

# RANDOM NOTES

    See bash(1) manual how to use 'time' command
    to display results in different formats:

        TIMEFORMAT='real: %R'  # '%R %U %S'

    You could also drop kernel cache before testing:

        echo 3 > /proc/sys/vm/drop_caches

# COPYRIGHT

    Copyright (C) 2024-2025 Jari Aalto

# LICENSE

    This program is free software; you can
    redistribute and/or modify program under the
    terms of GNU General Public license either
    version 2 of the License, or (at your option)
    any later version.

End of file
