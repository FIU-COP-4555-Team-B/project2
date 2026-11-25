# Problem C: Matrix Math

A matrix math utility that performs matrix multiplication, transposition, and extracts the diagonal elements.

Requirements: Nix with flakes. Run `direnv allow` or `nix develop` in this
directory to get a C and C++ compiler, GHC, and `just`.

> [!NOTE]
> Nix reads only files that Git tracks. Commit `flake.nix` and `flake.lock`
> before you use direnv, or run `nix develop path:.` until then.

Run these commands from this directory:

```sh
just imp    # C
just oop    # C++
just fn     # Haskell
just test   # Compare all versions with test/
```

Each recipe builds its program and reads `example.txt` through standard input.
To use a different file, give its path, for example `just imp test/decimals.in`.

The input has two matrices, A and B. Each matrix is a row count and a column
count, then its values in row-major order:

```text
2 3
1 2 3
4 5 6

3 2
7 8
9 10
11 12
```

Expected output for `example.txt`:

```text
A * B:
58 64
139 154
transpose(A):
1 4
2 5
3 6
diagonal(A):
1 5
```

Haskell writes each value with a decimal point, for example `58.0`. If A is
not square, its diagonal has one value per index in both dimensions.

If the input is not valid, or the columns of A do not equal the rows of B, the
program writes one error line to standard error and exits with status 1.

Build files stay in `.build/`. Run `just clean` to remove them.
