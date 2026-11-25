GO ?= go
DOTNET ?= dotnet
PYTHON ?= python3

.PHONY: imperative functional objectOriented clean

imperative: .build/imperative
	./$< < example.txt

functional:
	$(DOTNET) fsi --exec functional.fsx < example.txt

objectOriented:
	$(PYTHON) object_oriented.py < example.txt

.build/imperative: imperative.go | .build
	$(GO) build -o $@ $<

.build:
	mkdir -p $@

clean:
	rm -rf .build
