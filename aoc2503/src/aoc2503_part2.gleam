import gleam/int
import gleam/io
import gleam/list
import gleam/order
import gleam/string
import simplifile

pub fn debug(str: String) -> Nil {
  let _ = str
  io.println(str)
}

pub fn xdebug(str: String) -> Nil {
  let _ = str
  Nil
}

fn find_max_char(chars: List(String)) -> #(String, Int) {
  list.index_fold(chars, #("0", -1), fn(best, char, index) {
    case string.compare(char, best.0) {
      order.Gt -> #(char, index)
      _ -> best
    }
  })
}

pub fn main() -> Nil {
  let part = ".part2"
  let ext = ".txt"
  // let ext = ".test.txt"

  let assert Ok(contents) = simplifile.read("src/input" <> ext)
  let lines =
    contents
    |> string.trim
    |> string.split("\n")

  let sum =
    list.fold(lines, 0, fn(sum, line) {
      let n = 12
      let chars = string.to_graphemes(line)
      let best =
        list.range(n - 1, 0)
        |> list.fold(#("", 0), fn(best_tuple, i) {
          let #(cur_best, best1_index) = best_tuple
          let remaining = list.drop(chars, best1_index)
          let #(best2_char, best2_index) =
            remaining
            |> list.take(list.length(remaining) - i)
            |> find_max_char
          #(cur_best <> best2_char, best1_index + best2_index + 1)
        })

      let assert Ok(best_parsed) = int.parse(best.0)
      sum + best_parsed
    })

  let r_str = int.to_string(sum)

  io.println("Result: " <> r_str)
  let assert Ok(_) = simplifile.write("src/result" <> part <> ext, r_str)

  Nil
}
