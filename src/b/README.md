# Problem B: Text analyzer

Requirements: Make, a C11 compiler, GHC with `containers`, and JDK 17 or later.

Run these commands from this directory:

```sh
make imperative
make functional
make objectOriented
```

Each target builds its program and reads `example.txt` through standard input.
All versions count ASCII words without regard to case and filter the same
English stop-words. They print up to five words by descending frequency, with
alphabetical order for ties.

Expected output for `example.txt`:

```text
cat 4
play 4
bird 3
dog 3
garden 3
```

Build files stay in `.build/`. Run `make clean` to remove them.
