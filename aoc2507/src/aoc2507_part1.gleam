import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/regexp
import gleam/string
import simplifile

pub fn debug(str: String) -> Nil {
  let _ = str
  io.println(str)
}

pub fn main() -> Nil {
  let part = ".part1"
  let ext = ".txt"
  // let ext = ".test.txt"

  let assert Ok(contents) = simplifile.read("src/input" <> ext)
  let assert Ok(re) = regexp.from_string("\\s+")

  let lines =
    contents
    |> string.trim
    |> string.split("\n")

  let height = list.length(lines)
  let assert Ok(first_line) = list.first(lines)
  let width = string.length(first_line)

  let empty_items: dict.Dict(#(Int, Int), String) = dict.new()
  let items =
    lines
    |> list.index_fold(empty_items, fn(cur_items, line, y) {
      let parts = string.to_graphemes(line)
      list.index_fold(parts, cur_items, fn(items1, part, x) {
        dict.insert(items1, #(x, y), part)
      })
    })

  let start_x =
    list.range(0, width - 1)
    |> list.fold(-1, fn(cur_index, x) {
      case dict.get(items, #(x, 0)) {
        Ok("S") -> x
        _ -> cur_index
      }
    })

  let beams: dict.Dict(Int, Int) = dict.new()
  let beams1 = dict.insert(beams, start_x, 0)

  let sum1 =
    list.range(1, height - 1)
    |> list.fold(#(0, beams1), fn(cur_n_beams, y) {
      let #(n, cur_beams) = cur_n_beams
      let cc =
        list.fold(dict.keys(cur_beams), #(n, cur_beams), fn(cur_n_beams, x1) {
          let #(n, cur_beams) = cur_n_beams
          case dict.get(items, #(x1, y)) {
            Ok("^") -> {
              #(
                n + 1,
                cur_beams
                  |> dict.insert(x1 - 1, 0)
                  |> dict.insert(x1 + 1, 0)
                  |> dict.delete(x1),
              )
            }
            _ -> {
              cur_n_beams
            }
          }
        })
      cc
    })

  let sum = sum1.0

  let r_str = int.to_string(sum)

  io.println("Result: " <> r_str)
  let assert Ok(_) = simplifile.write("src/result" <> part <> ext, r_str)

  Nil
}
