import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

pub fn debug(str: String) -> Nil {
  let _ = str
  io.println(str)
}

type Range =
  #(Int, Int)

pub fn merge_range(current_ranges: List(Range), range: Range) {
  list.fold(current_ranges, #([], False), fn(merged_was_merged, next_range) {
    let #(merged, was_merged) = merged_was_merged
    case range.1 < next_range.0 || range.0 > next_range.1 {
      True -> {
        #([next_range, ..merged], was_merged)
      }
      False -> {
        let from = int.min(range.0, next_range.0)
        let upto = int.max(range.1, next_range.1)
        #([#(from, upto), ..merged], True)
      }
    }
  })
}

pub fn merge_ranges(ranges: List(Range)) {
  ranges
  |> list.fold(#([], False), fn(current_ranges_changed, range) {
    let #(current_ranges, changed) = current_ranges_changed
    //
    // io.println("RANGE " <> string.inspect(range))
    // io.println("NEXT_RANGES " <> string.inspect(next_ranges))
    //
    let #(merged_ranges, range_was_merged) = merge_range(current_ranges, range)

    let next_ranges = case range_was_merged {
      True -> merged_ranges
      False -> {
        [range, ..merged_ranges]
      }
    }

    // io.println("RES " <> string.inspect(xx1))

    #(next_ranges, changed || range_was_merged)
  })
}

pub fn process_ranges(ranges: List(Range)) {
  let #(merged, changed) = merge_ranges(ranges)
  case changed {
    True -> process_ranges(merged)
    False -> merged
  }
}

pub fn main() -> Nil {
  let part = ".part2"
  let ext = ".txt"
  // let ext = ".test.txt"

  let assert Ok(contents) = simplifile.read("src/input" <> ext)
  let lines12 =
    contents
    |> string.trim
    |> string.split("\n\n")

  let assert Ok(ranges_raw) = list.first(lines12)
  let ranges =
    ranges_raw
    |> string.split("\n")
    |> list.map(fn(s) {
      let assert [from_str, upto_str] = string.split(s, "-")
      let assert Ok(from) = int.parse(from_str)
      let assert Ok(upto) = int.parse(upto_str)
      #(from, upto)
    })

  let sum =
    ranges
    |> process_ranges
    |> list.fold(0, fn(sum, range) { sum + range.1 - range.0 + 1 })

  // debug("FINAL: " <> string.inspect(final))

  let r_str = int.to_string(sum)

  io.println("Result: " <> r_str)
  let assert Ok(_) = simplifile.write("src/result" <> part <> ext, r_str)

  Nil
}
