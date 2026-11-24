CC ?= cc
CFLAGS ?= -std=c11 -Wall -Wextra -Wpedantic

.PHONY: imperative functional objectOriented clean

imperative: .build/imperative
	./$< < example.txt

functional: .build/functional
	./$< < example.txt

objectOriented: .build/ObjectOriented.class
	java -cp .build ObjectOriented < example.txt

.build/imperative: imperative.c | .build
	$(CC) $(CFLAGS) $< -o $@

.build/functional: functional.hs | .build
	ghc -Wall -O2 -outputdir .build -o $@ $<

.build/ObjectOriented.class: ObjectOriented.java | .build
	javac -Xlint:all -d .build $<

.build:
	mkdir -p $@

clean:
	rm -rf .build
