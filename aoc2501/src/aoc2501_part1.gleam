import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

type Res {
  Res(v: Int, r: Int)
}

pub fn run1() -> Nil {
  let part = ".part1"
  // let ext = ".txt"
  let ext = ".test.txt"

  let assert Ok(contents) = simplifile.read("src/input" <> ext)
  let lines = string.split(string.trim(contents), "\n")

  let initial = Res(10_050, 0)

  let res =
    list.fold(lines, initial, fn(current, line) {
      let assert Ok(#(dir, value_str)) = string.pop_grapheme(line)
      let assert Ok(value) = int.parse(value_str)
      let next = case dir {
        "R" -> {
          // io.print("RIGHT ")
          Res(..current, v: current.v + value)
        }
        "L" -> {
          // io.print("LEFT ")
          Res(..current, v: current.v - value)
        }
        _ -> panic
      }

      // io.println(int.to_string(value) <> " " <> int.to_string(next.v))

      Res(..next, r: case next.v % 100 {
        0 -> next.r + 1
        _ -> next.r
      })
    })

  let r_str = int.to_string(res.r)

  io.println("Result: " <> r_str)
  let assert Ok(_) = simplifile.write("src/result" <> part <> ext, r_str)

  Nil
}

pub fn main() -> Nil {
  run1()
}
