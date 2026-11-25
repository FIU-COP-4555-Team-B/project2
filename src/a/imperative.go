package main

import (
	"bufio"
	"fmt"
	"io"
	"math"
	"os"
	"sort"
	"strconv"
	"strings"
)

type item struct {
	name     string
	quantity int64
	price    int64
}

// parseNonnegative accepts only decimal digits and values within the int64 range.
func parseNonnegative(text string) (int64, bool) {
	for i := 0; i < len(text); i++ {
		if text[i] < '0' || text[i] > '9' {
			return 0, false
		}
	}

	value, err := strconv.ParseInt(text, 10, 64)
	return value, err == nil
}

func main() {
	reader := bufio.NewReader(os.Stdin)
	var items []item
	var total int64

	for lineNumber := 1; ; lineNumber++ {
		line, readErr := reader.ReadString('\n')
		if readErr != nil && readErr != io.EOF {
			fmt.Fprintf(os.Stderr, "Failed to read input: %v\n", readErr)
			os.Exit(1)
		}

		fields := strings.Fields(line)
		if len(fields) != 0 {
			if len(fields) != 3 {
				fmt.Fprintf(os.Stderr, "Line %d: expected NAME QUANTITY PRICE_CENTS\n", lineNumber)
				os.Exit(1)
			}

			for i := 0; i < len(fields[0]); i++ {
				if fields[0][i] > 127 {
					fmt.Fprintf(os.Stderr, "Line %d: name must be ASCII\n", lineNumber)
					os.Exit(1)
				}
			}

			quantity, ok := parseNonnegative(fields[1])
			if !ok {
				fmt.Fprintf(os.Stderr, "Line %d: invalid quantity\n", lineNumber)
				os.Exit(1)
			}

			price, ok := parseNonnegative(fields[2])
			if !ok {
				fmt.Fprintf(os.Stderr, "Line %d: invalid price\n", lineNumber)
				os.Exit(1)
			}

			// Check multiplication and addition before updating the total.
			if quantity != 0 && price > (math.MaxInt64-total)/quantity {
				fmt.Fprintf(os.Stderr, "Line %d: total stock value exceeds int64\n", lineNumber)
				os.Exit(1)
			}
			total += quantity * price

			if quantity != 0 {
				items = append(items, item{fields[0], quantity, price})
			}
		}

		if readErr == io.EOF {
			break
		}
	}

	sort.SliceStable(items, func(i, j int) bool {
		if items[i].price != items[j].price {
			return items[i].price < items[j].price
		}
		return items[i].name < items[j].name
	})

	writer := bufio.NewWriter(os.Stdout)
	fmt.Fprintf(writer, "Total stock value: %d.%02d\n", total/100, total%100)
	fmt.Fprintln(writer, "In-stock items (by price):")
	for _, item := range items {
		fmt.Fprintf(writer, "%s %d %d.%02d\n", item.name, item.quantity, item.price/100, item.price%100)
	}

	if err := writer.Flush(); err != nil {
		fmt.Fprintf(os.Stderr, "Failed to write output: %v\n", err)
		os.Exit(1)
	}
}
