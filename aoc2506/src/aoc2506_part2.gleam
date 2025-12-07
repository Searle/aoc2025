import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

pub fn debug(str: String) -> Nil {
  let _ = str
  io.println(str)
}

pub fn main() -> Nil {
  let part = ".part2"
  let ext = ".txt"
  // let ext = ".test.txt"

  let assert Ok(contents) = simplifile.read("src/input" <> ext)
  let lines =
    contents
    |> string.split("\n")

  let height = list.length(lines)

  let empty_items: dict.Dict(#(Int, Int), String) = dict.new()
  let #(width, items) =
    lines
    |> list.index_fold(#(0, empty_items), fn(cur2, line, y) {
      let #(cur_width, cur_items) = cur2
      let parts = string.to_graphemes(line)
      let items1 =
        list.index_fold(parts, cur_items, fn(items1, part, x) {
          dict.insert(items1, #(x, y), part)
        })
      case cur_width == 0 {
        True -> #(list.length(parts), items1)
        False -> {
          assert list.length(parts) == cur_width
          #(cur_width, items1)
        }
      }
    })

  let initial_state: #(Int, List(Int), List(Int)) = #(0, [], [])

  let state =
    list.range(width - 1, 0)
    |> list.fold(initial_state, fn(cur_num, x) {
      list.range(0, height - 1)
      |> list.fold(cur_num, fn(num, y) {
        let assert Ok(item) = dict.get(items, #(x, y))
        let num1 = case item {
          "0" -> #(num.0 * 10 + 0, num.1, num.2)
          "1" -> #(num.0 * 10 + 1, num.1, num.2)
          "2" -> #(num.0 * 10 + 2, num.1, num.2)
          "3" -> #(num.0 * 10 + 3, num.1, num.2)
          "4" -> #(num.0 * 10 + 4, num.1, num.2)
          "5" -> #(num.0 * 10 + 5, num.1, num.2)
          "6" -> #(num.0 * 10 + 6, num.1, num.2)
          "7" -> #(num.0 * 10 + 7, num.1, num.2)
          "8" -> #(num.0 * 10 + 8, num.1, num.2)
          "9" -> #(num.0 * 10 + 9, num.1, num.2)
          "+" -> {
            let nums = case num.0 {
              0 -> num.1
              _ -> [num.0, ..num.1]
            }
            #(0, [], [list.fold(nums, 0, fn(cur, n) { cur + n }), ..num.2])
          }
          "*" -> {
            let nums = case num.0 {
              0 -> num.1
              _ -> [num.0, ..num.1]
            }
            #(0, [], [list.fold(nums, 1, fn(cur, n) { cur * n }), ..num.2])
          }
          " " -> {
            let nums = case num.0 {
              0 -> num.1
              _ -> [num.0, ..num.1]
            }
            #(0, nums, num.2)
          }
          _ -> {
            let msg = "unknown char [" <> item <> "]"
            panic as msg
          }
        }
        // debug(string.inspect(#(item, num1)))
        num1
      })
    })

  let sum = list.fold(state.2, 0, fn(cur, n) { cur + n })

  let r_str = int.to_string(sum)

  io.println("Result: " <> r_str)
  let assert Ok(_) = simplifile.write("src/result" <> part <> ext, r_str)

  Nil
}
