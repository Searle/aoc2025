import gleam/int
import gleam/io
import gleam/list
import gleam/order
import gleam/string
import simplifile

// I fed aoc2503_part2.gleam to Claude and asked for more idiomatic Gleam code.
// This is Claude's answer:
//
// Changes:
// - Extracted extract_digits function for clarity
// - More pipeline style in main
// - Used |> fn(result) { result.0 } to extract tuple element at end of pipe

fn find_max_char(chars: List(String)) -> #(String, Int) {
  list.index_fold(chars, #("0", -1), fn(best, char, index) {
    case string.compare(char, best.0) {
      order.Gt -> #(char, index)
      _ -> best
    }
  })
}

fn extract_digits(chars: List(String), n: Int) -> String {
  list.range(n - 1, 0)
  |> list.fold(#("", 0), fn(acc, i) {
    let #(digits, start_index) = acc
    let remaining = list.drop(chars, start_index)
    let #(best_char, best_index) =
      remaining
      |> list.take(list.length(remaining) - i)
      |> find_max_char
    #(digits <> best_char, start_index + best_index + 1)
  })
  |> fn(result) { result.0 }
}

pub fn main() -> Nil {
  let part = ".part2"
  let ext = ".txt"

  let assert Ok(contents) = simplifile.read("src/input" <> ext)

  let sum =
    contents
    |> string.trim
    |> string.split("\n")
    |> list.fold(0, fn(sum, line) {
      let assert Ok(value) =
        line
        |> string.to_graphemes
        |> extract_digits(12)
        |> int.parse
      sum + value
    })

  let result = int.to_string(sum)
  io.println("Result: " <> result)
  let assert Ok(_) = simplifile.write("src/result" <> part <> ext, result)
  Nil
}
