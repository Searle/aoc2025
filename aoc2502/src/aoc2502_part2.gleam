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

pub fn xdebug(str: String) -> Nil {
  let _ = str
  Nil
}

pub fn main() -> Nil {
  let part = ".part2"
  let ext = ".txt"
  // let ext = ".test.txt"

  let assert Ok(contents) = simplifile.read("src/input" <> ext)
  let lines = string.split(string.trim(contents), "\n")

  let assert Ok(re) = regexp.from_string("^(\\d+)(\\1)+$")

  let res =
    list.fold(lines, 0, fn(current, line) {
      let assert [a_str, b_str] = string.split(line, "-")

      let assert Ok(a) = int.parse(a_str)
      let assert Ok(b) = int.parse(b_str)

      let sum =
        list.range(a, b)
        |> list.fold(0, fn(acc, i) {
          case regexp.check(re, int.to_string(i)) {
            True -> {
              // io.println(int.to_string(i))
              acc + i
            }
            False -> acc
          }
        })

      current + sum
    })

  let r_str = int.to_string(res)

  io.println("Result: " <> r_str)
  let assert Ok(_) = simplifile.write("src/result" <> part <> ext, r_str)

  Nil
}
