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

pub fn main() -> Nil {
  let part = ".part1"
  let ext = ".txt"
  // let ext = ".test.txt"

  let assert Ok(contents) = simplifile.read("src/input" <> ext)
  let lines = string.split(string.trim(contents), "\n")

  let sum =
    list.fold(lines, 0, fn(sum, line) {
      let s1 = string.split(line, "")
      let best1 =
        list.take(s1, list.length(s1) - 1)
        |> list.index_fold(#("0", -1), fn(cur_best, s1_char, s1_index) {
          let #(best_char, _) = cur_best
          case string.compare(s1_char, best_char) {
            order.Gt -> #(s1_char, s1_index)
            _ -> cur_best
          }
        })

      let #(best1_char, best1_index) = best1
      let assert True = best1_index >= 0

      let best2 =
        list.split(s1, best1_index + 1)
        |> fn(l1l2) {
          let #(_, l2) = l1l2
          l2
        }
        |> list.index_fold(#("0", -1), fn(best, s1_char, s1_index) {
          let #(best_char, _) = best
          case string.compare(s1_char, best_char) {
            order.Gt -> #(s1_char, s1_index)
            _ -> best
          }
        })

      let #(best2_char, best2_index) = best2
      let assert True = best2_index >= 0
      let assert Ok(best) = int.parse(best1_char <> best2_char)

      // debug("BEST " <> int.to_string(best))

      sum + best
    })

  let r_str = int.to_string(sum)

  io.println("Result: " <> r_str)
  let assert Ok(_) = simplifile.write("src/result" <> part <> ext, r_str)

  Nil
}
