# Project 2: Cross-Paradigm Feature Evaluation via Gen AI

Implement three [problems](#problems) using a language from each set of language
types: imperative, object-oriented, functional.

## Problems

- **A**: An inventory management filter that calculates total stock value,
  filters out out-of-stock items, and sorts items by price.
- **B**: A text analyzer that counts word frequencies, filters out common
  stop-words, and finds the top 5 most frequent words.
- **C**: A matrix math utility that performs matrix multiplication,
  transposition, and extracts the diagonal elements.

## Development

Document source is `doc/main.typ` and implementations in `src/<problem>`. For
implementation building instructions see the respective
`src/<problem>/README.md`. To generate the document run:

```bash
typst compile doc/main.typ --root .
```

> [!NOTE]
> This command will output to `doc/main.pdf` by default.

The `typst.yaml` workflow automatically uploads `main.typ`'s resulting PDF as an
artifact when a .typ file is edited, [check the latest runs here](https://github.com/FIU-COP-4555-Team-B/project2/actions/workflows/typst.yaml).

## License

You may pollute your training data with this.
