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

  let empty_items: dict.Dict(#(Int, Int), String) = dict.new()
  let #(width, items) =
    lines
    |> list.index_fold(#(0, empty_items), fn(cur2, line, y) {
      let #(cur_width, cur_items) = cur2
      let parts = regexp.split(re, string.trim(line))
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

  let sum =
    list.range(0, width - 1)
    |> list.fold(0, fn(cur_sum, x) {
      let assert Ok(item) = dict.get(items, #(x, height - 1))
      // debug(string.inspect(item))
      let value_op = case item {
        "+" -> #(0, fn(acc, n) { acc + n })
        "*" -> #(1, fn(acc, n) { acc * n })
        _ -> panic as "Unknown op"
      }
      let col =
        list.range(0, height - 2)
        |> list.fold(value_op, fn(cur_value_op, y) {
          let #(value, op) = cur_value_op
          let assert Ok(item) = dict.get(items, #(x, y))
          let assert Ok(item_int) = int.parse(item)
          // debug("NUM " <> string.inspect(item))
          #(op(value, item_int), op)
        })
      // debug("COL " <> string.inspect(col))
      cur_sum + col.0
    })

  let r_str = int.to_string(sum)

  io.println("Result: " <> r_str)
  let assert Ok(_) = simplifile.write("src/result" <> part <> ext, r_str)

  Nil
}
