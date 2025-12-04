import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

type Res {
  Res(v: Int, r: Int)
}

pub fn debug(str: String) {
  let _ = str
  // io.println(str)
}

pub fn run1() -> Nil {
  let part = ".part1"
  let ext = ".txt"
  // let ext = ".test.txt"

  let assert Ok(contents) = simplifile.read("src/input" <> ext)
  let lines = string.split(string.trim(contents), "\n")

  let base = 1_000_000
  let initial = Res(base + 50, 0)

  let res =
    list.fold(lines, initial, fn(current, line) {
      let assert Ok(#(dir, value_str)) = string.pop_grapheme(line)
      let assert Ok(value) = case dir {
        "R" -> int.parse(value_str)
        "L" -> int.parse("-" <> value_str)
        _ -> panic
      }

      let next_v = current.v + value
      let dx = case value < 0 {
        True -> { base * 2 - next_v } / 100 - { base * 2 - current.v } / 100
        False -> next_v / 100 - current.v / 100
      }
      let next_r = current.r + dx

      let _ =
        debug(
          int.to_string(value)
          <> " "
          <> int.to_string(next_v)
          <> " "
          <> int.to_string(dx),
        )

      Res(v: next_v, r: next_r)
    })

  let r_str = int.to_string(res.r)

  io.println("Result: " <> r_str)
  let assert Ok(_) = simplifile.write("src/result" <> part <> ext, r_str)

  Nil
}

pub fn main() -> Nil {
  run1()
}
