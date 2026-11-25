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

#problem("Problem A", "Shirina Daniel")[
  == Prompt
  #set quote(block: true)
  #quote()[like the implementation for problem b, could you implement problem a using the languages in src/a/ each in an idiomatic way]

  === Go
  #raw(read("../src/a/imperative.go"), lang: "go", block: true)

  === Python
  #raw(read("../src/a/object_oriented.py"), lang: "python", block: true)

  === F\#
  #raw(read("../src/a/functional.fsx"), lang: "fs", block: true)

  == Evaluation

  All scripts run. No changes seem necessary.

  === State Management

  *Go (imperative):* Go stores mutable state in the `total` accumulator and the
  `items` slice. Each input record updates the total, and in-stock records are
  appended to the slice. Sorting reorders that same slice in place. Unlike the C
  implementation in Problem B, this program needs no explicit pointer
  manipulation or manual memory cleanup.

  *Python (object-oriented):* `Inventory` encapsulates a mutable `_items` list.
  The leading underscore marks the list as internal by convention, not through
  enforced access control. The `read` method appends `InventoryItem` objects.
  Their frozen dataclass prevents normal field reassignment, but it does not
  make the inventory list immutable. Methods operate on the list without
  requiring getters or setters.

  *F\# (functional):* F\# represents items with immutable records and stores
  them in immutable lists. Filtering and sorting produce new lists rather than
  changing the input. The total comes from a reduction instead of an explicitly
  updated accumulator. Parsing and report construction remain separate from
  console input and output.

  === Control Flow

  *Go (imperative):* An explicit loop reads input until end-of-file.
  Conditionals validate fields, check overflow, and exclude out-of-stock records
  from the listing. A comparison function directs stable sorting by price and
  then name. A second loop prints the results. Error branches report a problem
  and terminate the program.

  *Python (object-oriented):* The entry point creates an `Inventory` and calls
  its `read` and `write_report` methods. These calls organize behavior around
  the object's state. Internally, loops read records and print items, while
  generator expressions feed `sum` and `sorted`. A sorting key selects price
  and name. The design needs neither subclasses nor overridden methods.

  *F\# (functional):* Pipelines connect parsing, filtering, sorting, and
  formatting. Higher-order functions such as `List.sumBy`, `List.filter`,
  `List.sortBy`, and `List.map` perform the list traversals. Function composition
  combines the blank-line test with negation. Pattern matching validates parsed
  fields, and exception handlers report invalid input or overflow. The
  implementation contains no explicit loops or recursion.

  === Type System Role

  *Go (imperative):* The `item` struct groups a `string` name with `int64`
  quantity and price fields. Static typing checks the field and collection types
  at compile time. Integer cents avoid floating-point rounding, but `int64` does
  not guarantee nonnegative values or safe arithmetic. Parsing and explicit
  overflow checks enforce those requirements at runtime.

  *Python (object-oriented):* `InventoryItem` models an inventory record, and
  `Inventory` groups the records with their operations. The classes do not form
  an inheritance hierarchy. Python uses dynamic typing; annotations such as
  `list[InventoryItem]` describe expected types but do not enforce them at
  runtime. Input validation supplies those checks. Python's integers grow as
  needed rather than imposing Go's fixed 64-bit arithmetic limit.

  *F\# (functional):* The `Item` record is a product type that groups a name,
  quantity, and price with statically checked field types. Type inference gives
  the reporting transformation the type `Item list -> string` without an
  explicit annotation. Tuple and array patterns support input validation; no
  custom discriminated union is needed. As in Go, `int64` does not encode
  nonnegativity. Parsing checks values, while checked arithmetic detects
  overflow at runtime.

  == AI Evaluation

  - *Did the AI successfully write _idiomatic_ code for each paradigm?* Yes.
  - *Any optimizations, edge-cases, vulnerabilities or anti-patterns the AI
    introduced?* None that I could think of.
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

#problem("Problem C", "Gabriel Garcia")[
  == Prompt

  ```md
  ## Problem

  A matrix math utility that performs matrix multiplication, transposition, and extracts the diagonal elements.

  ## Languages

  Implement in three languages from the below groups:

  - *Imperative:* C, Pascal, or Go
  - *Object-Oriented:* Java, C++, or Python
  - *Functional:* Haskell, ML, or F#

  ## Design

  Use idiomatic choices for each particular language and overall language
  group, as applicable to the particular problem. These are some broad
  guidelines, but are certainly _inexhaustive_:

  - Generally: 
    - DRY, YAGNI, separation of concerns, principle of least knowledge
    - Favor simplicity and brevity
    - Document appropriately, without excess
    - Use /asd-ste-100 style of writing, and ommit `.` at the end of comments
  - Imperative: Careful control flow and structure
  - OOP:  SOLID principles
  - Functional: Error handling, pattern matching, avoiding side effects

  Given the matrix _and_ 'utility' aspect: 

  - Use appropriate data types
  - Validate inputs
  - Have reasonable error handling
  - Keep client API and developer ergonomics in mind


  ## Requirements

  > [!NOTE]
  > Write all outputs in `./src/c/`!

  - Read the documentation
  - Include a justfile for quick usage, with three sub commands for `fn`, `oop`, and `imp`
  - This machine has nix available, write a nix flake to load dependencies (via direnv)
  - For tests/inputs, pipeing in input files as stdin is acceptable if file
    handling would balloon code size or otherwise hide the goal of this problem
    behind plumbing
  ```

  All implementations below compile/run, and have a couple of testfiles set up
  to compare outputs. No adjustments were necessary to achieve the baseline.

  === Imperative: C

  #raw(read("../src/c/imperative.c"), lang: "c", block: true)

  === Object-Oriented: C++

  #raw(read("../src/c/object_oriented.cpp"), lang: "cpp", block: true)

  === Functional: Haskell

  #raw(read("../src/c/functional.hs"), lang: "haskell", block: true)

  == Evaluation

  #table(
    columns: (auto, auto, auto, auto),
    inset: 10pt,
    align: horizon,
    table.header([], [*Imperative*], [*Object-Oriented*], [*Functional*]),
    [*State*],
    [
      Matrices are allocated on the heap and passed around through pointers.

      The
      input matrices are read through `Matrix *` values, then the calculation
      functions accept `const Matrix *` to indicate they will _not_ modify those
      inputs.

      Each operation allocates a separate result and fills its values in
      place. The multiplication loop also updates a running `sum` and `main` fress
      all allocated matrices during cleanup
    ],
    [
      `Matrix` keeps its row and column counts, and row-major values in private
      fields. It also exposes dimensions through getters (`rows()`, `cols()`) and uses `operator()` to access elements.
      It doesn't expose any setters (given the matrix utility part it is reasonable).
    ],
    [
      `Matrix` values are immutable lists, and the calculations are pure
      functions returning new results. `diagonal` uses recursion to take the first
      element of each row while dropping one column for the next step. All side
      effects are kept at the program boundary (`main` reads input and prints output)
    ],

    [*Flow*],
    [
      `main` reads two matrices, checks that they can be multiplied, then
      computes the product, transpose, and diagonal in sequence.

      Each operation uses nested loops to visit matrix elements, and when
      encountering a failure (e.g. reading, dimension checking, allocation error),
      the program reports an error and jumps to shared cleanup, or otherwise
      prints the three results.
    ],
    [
      `transpose()` and `diagonal()` are `Matrix` methods, while multiplication
      and stream I/O are handled by overloaded functions. The program invokes
      these directly, and avoids runtime polymorphism or virtual methods.
    ],
    [
      Computation is structured via list comprehensions and higher-order functions: `multiply` combines `transpose`, `zipWith`, and `sum` to compute each cell, `diagonal` uses `map` recursively , and `run` uses function composition to format the result.
      We also can see that `traverse`
    ],

    [*Types*],
    [
      C's static types means that dimensions and indices are of `size_t` and
      matrix elements `double`, while input dimensions and the exit status use
      `int`. These types guide indexing, arithmetic, I/O, but require explicit
      conversions when dimensions are passed to allocation.

      C does not enforce matrix shape compatability through types, so this
      implementation must check dimensions at runtime (unlike other languages) and use
      `assert` for assumptions.
    ],
    [
      The domain model has one custom class, `Matrix`, with a
      `std::vector<double>` to store its values. There are no custom interfaces,
      subclassses, or inheritance relationships.
    ],
    [
      `Failure` is a sum type for invalid input and shape mismatches, while
      `Either Failure` carries either an error or a result. `Matrix` is a type
      synonym for `[[Double]]`, and tuples represent dimensions. Explicit
      signatures are helpful here and make the main types clear, but Haskell
      infers the types of local helpers and expressions
    ],
  )
]
