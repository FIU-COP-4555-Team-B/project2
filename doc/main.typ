#set page(
  paper: "us-letter",
  margin: 1.5cm,
  header: context {
    let current-page = here().page()
    let problems = query(<problem>).filter(
      problem => problem.location().page() <= current-page,
    )
    if problems.len() > 0 {
      let problem = problems.last()
      if problem.location().page() < current-page {
        text(size: 9pt, fill: luma(35%))[
          #problem.value.title #h(1fr) #problem.value.author
        ]
      }
    }
  },
)
#set text(
  font: (
    "Libertinus Serif",
    "Times New Roman",
  ),
  size: 11pt,
)
#set par(justify: true, leading: 0.65em)

#show raw.where(block: true): it => {
  set text(size: 8pt)
  block(
    width: 100%,
    stroke: 1pt + luma(85%),
    fill: luma(95%),
    radius: 4pt,
    inset: 8pt,
    breakable: true,
  )[#it]
  pagebreak(weak: true)
}

#let problem(title, author, body) = [
  #metadata((title: title, author: author))<problem>
  #grid(
    columns: (1fr, auto),
    column-gutter: 1em,
    align: horizon,
    heading(level: 1, title), author,
  )

  #body
  #pagebreak(weak: true)
]

#align(center)[
  #text(
    size: 16pt,
    weight: "bold",
  )[Cross-Paradigm Feature Evaluation via Gen AI]

  #smallcaps[ Principles of Programming Languages  ] \
  Shirina Daniel, Marcelo Hernandez, Gabriel Garcia \
  #datetime.today().display()
]

#problem("Problem A", "TBD")[
  Shirina Daniel
]

#problem("Problem B", "Marcelo Hernandez")[
  == Prompt
  #set quote(block: true)
  #quote()[See problem B in the readme. Implement a minimal version of it in an idiomatic way in each of the languages in src/b/ along with a makefile to run `make imperative`, `make functional` or `make objectOriented` which will run the programs. Place the test input in a example.txt, no need to read the file if it's too difficult in the language, it can instead just be read through stdin and piped in the makefile.

    Delegate each language to a subagent and then tie it all up with a makefile yourself in the end.

    Do not use non-idiomatic features (e.g., procedural loop structures in Haskell or pure functional pipes in C) ]
  === C
  #raw(read("../src/b/imperative.c"), lang: "c", block: true)

  === Java
  #raw(read("../src/b/ObjectOriented.java"), lang: "java", block: true)

  === Haskell
  #raw(read("../src/b/functional.hs"), lang: "haskell", block: true)

  == Evaluation

  All code runs correctly. All I changed was extracting the `sizeof` math from the `count_word`'s for loop out into a variable in the C code.

  === State Management

  *C (imperative):* C stores mutable state in a token buffer and a dynamically
  allocated array of `struct Word` records. Loops overwrite buffer positions and
  increment counts through pointers. The programmer must manually resize storage,
  check allocation failures, and free each allocation. This makes memory
  management explicit but that adds _a lot_ of work that distracts from the
  core word counting logic.

  *Java (object-oriented):* Java encapsulates the mutable frequency map in a
  `public final Map<String, Long>`. No getters or setters were used since the map
  is encapsulated in our object. `final` prevents reassignment of the field, not
  changes to the map, letting us modify it while reading from input. Garbage
  collection removes the need for explicit memory cleanup.

  *Haskell (functional):* Haskell represents words, stop-words, and frequencies
  with immutable lists, a set, and a map. Counting constructs a map value without
  modifying shared state. The pure analysis functions leave their inputs
  unchanged. Reading input and printing results remain separate from those
  transformations in `main`.

  === Control Flow

  *C (imperative):* An explicit loop reads characters until end-of-file.
  Conditionals recognize letters, normalize case, and detect word boundaries.
  Other loops search for stop-words, update counts, and print results. `qsort`
  orders the records through a comparison function. Error branches use `goto
cleanup` to release allocations in one place.

  *Java (object-oriented):* The entry point creates an instance of its own class
  as an "analyzer" and invokes `analyze` followed by `printTopWords`. These
  methods organize behavior around the object's state. Internally, `while` loops
  process lines with regex matches to find words, and a `for` loop prints the
  results. Sorting uses a comparator lambda. The implementation needs neither
  overridden methods nor a custom inheritance hierarchy.

  *Haskell (functional):* Function composition connects tokenization, stop-word
  filtering, frequency counting, sorting, and selection of five results.
  Higher-order functions such as `map`, `filter`, and `sortOn` describe the
  transformations without explicit loop counters. `Map.fromListWith (+)`
  combines repeated words. Library functions perform the traversal; this
  implementation contains no explicit recursion.

  === Type System Role

  *C (imperative).* `struct Word` groups a string pointer with a `size_t` count.
  Static types distinguish characters, counts, and pointers, but they do not
  guarantee valid allocation sizes or pointer lifetimes. Those checks remain
  explicit. The generic `qsort` interface accepts `void *` pointers, which the
  comparator must interpret as word records.

  *Java (object-oriented).* Collection interfaces describe the data
  (`Map<String, Long>` maps words to counts). Generics check key and value types
  at compile time. `ObjectOriented` (our class) groups the data and operations in
  one place. The design uses library interfaces rather than introducing a
  hierarchy of domain classes.

  *Haskell (functional).* The signature `String -> [(String, Int)]` states that
  the analysis maps text to word-count pairs. Type inference supplies the types
  of intermediate expressions, keeping the composed transformations concise.
  Built-in lists and tuples suffice; no custom algebraic data type is needed.
  The `IO ()` signature on `main` distinguishes input/output actions from the
  pure analysis.

  == AI Evaluation

  - *Did the AI successfully write _idiomatic_ code for each paradigm?* Given
    the simple example, yes.
  - *Any optimizations, edge-cases, vulnerabilities or anti-patterns the AI
    introduced?* I personally think that creating a new instance of
    `ObjectOriented` from within itself is a bit of an anti-pattern. I'd prefer
    a separate entry point class, however for the simplicity of the prompt it's
    not _bad_.
]

#problem("Problem C - Haskell (Functional)", "Gabriel Garcia")[
  Matrix math utility that performs matrix multiplication, transposition, and
  extracts diagonal elements.
]
