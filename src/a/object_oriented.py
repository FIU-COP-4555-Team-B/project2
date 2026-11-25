import sys
from dataclasses import dataclass
from typing import Iterable, TextIO


@dataclass(frozen=True)
class InventoryItem:
    name: str
    quantity: int
    price_cents: int


class Inventory:
    def __init__(self) -> None:
        self._items: list[InventoryItem] = []

    def read(self, lines: Iterable[str]) -> None:
        """Read inventory records, rejecting malformed nonblank lines."""
        for line_number, line in enumerate(lines, start=1):
            fields = line.split()
            if not fields:
                continue
            if len(fields) != 3:
                raise ValueError(
                    f"line {line_number}: expected NAME QUANTITY PRICE_CENTS"
                )

            name, quantity, price_cents = fields
            if not name.isascii():
                raise ValueError(f"line {line_number}: name must be ASCII")
            if not all(
                value.isascii() and value.isdecimal()
                for value in (quantity, price_cents)
            ):
                raise ValueError(
                    f"line {line_number}: quantity and price must be "
                    "nonnegative decimal integers"
                )

            self._items.append(
                InventoryItem(name, int(quantity), int(price_cents))
            )

    def write_report(self, output: TextIO) -> None:
        """Write the total value and in-stock items sorted by price and name."""
        total_cents = sum(
            item.quantity * item.price_cents for item in self._items
        )
        print(f"Total stock value: {format_cents(total_cents)}", file=output)
        print("In-stock items (by price):", file=output)

        in_stock = sorted(
            (item for item in self._items if item.quantity > 0),
            key=lambda item: (item.price_cents, item.name),
        )
        for item in in_stock:
            print(
                f"{item.name} {item.quantity} {format_cents(item.price_cents)}",
                file=output,
            )


def format_cents(cents: int) -> str:
    """Format integer cents as dollars without floating-point arithmetic."""
    dollars, remainder = divmod(cents, 100)
    return f"{dollars}.{remainder:02d}"


def main() -> int:
    """Read stdin and report inventory, or a validation error on stderr."""
    inventory = Inventory()
    try:
        inventory.read(sys.stdin)
    except ValueError as error:
        print(f"Error: {error}", file=sys.stderr)
        return 1

    inventory.write_report(sys.stdout)
    return 0


if __name__ == "__main__":
    sys.exit(main())
