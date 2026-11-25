# Problem A: Inventory management filter

Requirements: Make, Go, the .NET SDK with F# Interactive, and Python 3.10 or later.

Run these commands from this directory:

```sh
make imperative
make functional
make objectOriented
```

Each target reads `example.txt` through standard input. Go uses imperative loops,
F# uses immutable records and list transformations, and Python uses inventory
objects.

Each nonblank input line contains three whitespace-separated fields:

```text
NAME QUANTITY PRICE_CENTS
```

Names must be single ASCII tokens. Quantities and prices must be nonnegative
ASCII decimal integers. Prices use cents to avoid rounding errors; for example, `250`
means `2.50`. Blank lines are ignored. Invalid records produce an error on
standard error and a nonzero exit status.

Go and F# reject quantities, prices, or total values above the signed 64-bit
integer limit.

All versions print the total stock value, omit out-of-stock items, and list the
remaining items by ascending unit price, then by ASCII name. Duplicate records
remain separate, and records with the same price and name keep their input order.
Output prices use two decimal places.

Expected output for `example.txt`:

```text
Total stock value: 53.75
In-stock items (by price):
Eraser 5 0.75
Pencil 20 0.75
Ruler 4 1.00
Marker 3 2.00
Notebook 10 2.50
```

Go build files stay in `.build/`. Run `make clean` to remove them.
