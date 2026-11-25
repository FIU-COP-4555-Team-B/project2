open System
open System.Globalization

type Item =
    { Name: string
      Quantity: int64
      PriceCents: int64 }

/// Parses ASCII decimal digits without signs and rejects values outside int64.
let parseNonnegative (text: string) =
    match Int64.TryParse(text, NumberStyles.None, CultureInfo.InvariantCulture) with
    | true, value when text |> Seq.forall (fun c -> c >= '0' && c <= '9') -> value
    | _ -> failwith "Quantity and price must be nonnegative 64-bit decimal integers."

/// Parses one nonblank record and validates its ASCII name.
let parseItem (line: string) =
    match line.Split((null: char array), StringSplitOptions.RemoveEmptyEntries) with
    | [| name; quantity; price |] when name |> Seq.forall (fun c -> c <= '\u007f') ->
        { Name = name
          Quantity = parseNonnegative quantity
          PriceCents = parseNonnegative price }
    | _ -> failwith "Expected NAME QUANTITY PRICE_CENTS with an ASCII name."

/// Formats integer cents exactly, without floating-point arithmetic.
let formatMoney (cents: int64) =
    sprintf "%d.%02d" (cents / 100L) (cents % 100L)

/// Builds the full report before output; products and List.sumBy use checked arithmetic.
let formatReport items =
    let total =
        items |> List.sumBy (fun item -> Checked.(*) item.Quantity item.PriceCents)

    let listing =
        items
        |> List.filter (fun item -> item.Quantity > 0L)
        |> List.sortBy (fun item -> item.PriceCents, item.Name)
        |> List.map (fun item ->
            sprintf "%s %d %s" item.Name item.Quantity (formatMoney item.PriceCents))

    [ sprintf "Total stock value: %s" (formatMoney total)
      "In-stock items (by price):" ]
    @ listing
    |> String.concat Environment.NewLine

try
    Console.In.ReadToEnd().Split([| '\r'; '\n' |], StringSplitOptions.RemoveEmptyEntries)
    |> Array.toList
    |> List.filter (String.IsNullOrWhiteSpace >> not)
    |> List.map parseItem
    |> formatReport
    |> Console.WriteLine
with
| Failure message ->
    eprintfn "Invalid record: %s" message
    Environment.Exit 1
| :? OverflowException ->
    eprintfn "Stock value exceeds the 64-bit integer range."
    Environment.Exit 1
