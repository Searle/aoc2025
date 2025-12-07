import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

// I fed aoc2506_part2.gleam to Claude and asked for more idiomatic Gleam code.
// This is Claude's answer:
//
// Changes:
//
// - Named record type State instead of anonymous tuple — much clearer than num.0, num.1, num.2
// - Extracted helper functions: parse_grid, char_to_digit, flush_number, process_char, process_operator
// - Used int.add and int.multiply instead of inline lambdas
// - char_to_digit returns Result — cleaner than matching all digits separately
// - Simplified grid parsing — width from first line, no need to track in fold
// - Used record update syntax State(..state, current_num: ...) for partial updates

type State {
  State(current_num: Int, operands: List(Int), results: List(Int))
}

fn parse_grid(
  lines: List(String),
) -> #(Int, Int, dict.Dict(#(Int, Int), String)) {
  let height = list.length(lines)
  let assert Ok(first_line) = list.first(lines)
  let width = string.length(first_line)

  let items =
    lines
    |> list.index_fold(dict.new(), fn(items, line, y) {
      line
      |> string.to_graphemes
      |> list.index_fold(items, fn(items, char, x) {
        dict.insert(items, #(x, y), char)
      })
    })

  #(width, height, items)
}

fn char_to_digit(char: String) -> Result(Int, Nil) {
  case char {
    "0" -> Ok(0)
    "1" -> Ok(1)
    "2" -> Ok(2)
    "3" -> Ok(3)
    "4" -> Ok(4)
    "5" -> Ok(5)
    "6" -> Ok(6)
    "7" -> Ok(7)
    "8" -> Ok(8)
    "9" -> Ok(9)
    _ -> Error(Nil)
  }
}

fn flush_number(state: State) -> List(Int) {
  case state.current_num {
    0 -> state.operands
    n -> [n, ..state.operands]
  }
}

fn process_char(state: State, char: String) -> State {
  case char_to_digit(char) {
    Ok(digit) -> State(..state, current_num: state.current_num * 10 + digit)
    Error(_) -> process_operator(state, char)
  }
}

fn process_operator(state: State, char: String) -> State {
  let operands = flush_number(state)
  case char {
    "+" -> {
      let result = list.fold(operands, 0, int.add)
      State(0, [], [result, ..state.results])
    }
    "*" -> {
      let result = list.fold(operands, 1, int.multiply)
      State(0, [], [result, ..state.results])
    }
    " " -> State(0, operands, state.results)
    _ -> panic as { "unknown char [" <> char <> "]" }
  }
}

pub fn main() -> Nil {
  let part = ".part2"
  let ext = ".txt"

  let assert Ok(contents) = simplifile.read("src/input" <> ext)
  let lines = string.split(contents, "\n")
  let #(width, height, items) = parse_grid(lines)

  let final_state =
    list.range(width - 1, 0)
    |> list.fold(State(0, [], []), fn(state, x) {
      list.range(0, height - 1)
      |> list.fold(state, fn(state, y) {
        let assert Ok(char) = dict.get(items, #(x, y))
        process_char(state, char)
      })
    })

  let sum = list.fold(final_state.results, 0, int.add)

  let result = int.to_string(sum)
  io.println("Result: " <> result)
  let assert Ok(_) = simplifile.write("src/result" <> part <> ext, result)
  Nil
}
