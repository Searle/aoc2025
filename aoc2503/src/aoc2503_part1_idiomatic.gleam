import gleam/int
import gleam/io
import gleam/list
import gleam/order
import gleam/string
import simplifile

// I fed aoc2503_part1.gleam to Claude and asked for more idiomatic Gleam code.
// This is Claude's answer:
//
// Changes:
//
// - string.to_graphemes(line) instead of string.split(line, "")
// - list.drop instead of list.split + destructure
// - Extracted find_max_char helper to avoid repetition
// - Used best.0 for tuple access in the helper
// - More pipeline style where it flows naturally

fn find_max_char(chars: List(String)) -> #(String, Int) {
  list.index_fold(chars, #("0", -1), fn(best, char, index) {
    case string.compare(char, best.0) {
      order.Gt -> #(char, index)
      _ -> best
    }
  })
}

pub fn main() -> Nil {
  let part = ".part1"
  let ext = ".txt"

  let assert Ok(contents) = simplifile.read("src/input" <> ext)

  let sum =
    contents
    |> string.trim
    |> string.split("\n")
    |> list.fold(0, fn(sum, line) {
      let chars = string.to_graphemes(line)

      let #(best1_char, best1_index) =
        find_max_char(list.take(chars, list.length(chars) - 1))
      let assert True = best1_index >= 0

      let #(best2_char, best2_index) =
        chars
        |> list.drop(best1_index + 1)
        |> find_max_char
      let assert True = best2_index >= 0

      let assert Ok(best) = int.parse(best1_char <> best2_char)
      sum + best
    })

  let result = int.to_string(sum)
  io.println("Result: " <> result)

  let assert Ok(_) = simplifile.write("src/result" <> part <> ext, result)
  Nil
}
