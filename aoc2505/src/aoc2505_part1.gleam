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
  let part = ".part1"
  let ext = ".txt"
  // let ext = ".test.txt"

  let assert Ok(contents) = simplifile.read("src/input" <> ext)
  let lines12 =
    contents
    |> string.trim
    |> string.split("\n\n")

  let assert Ok(ranges_raw) = list.first(lines12)
  let ranges =
    ranges_raw
    |> string.split("\n")
    |> list.map(fn(s) {
      let assert [from_str, upto_str] = string.split(s, "-")
      let assert Ok(from) = int.parse(from_str)
      let assert Ok(upto) = int.parse(upto_str)
      #(from, upto)
    })

  let assert Ok(ingts_raw) = list.last(lines12)
  let ingts =
    ingts_raw
    |> string.split("\n")
    |> list.map(fn(s) {
      let assert Ok(ingt) = int.parse(s)
      ingt
    })

  let sum =
    ingts
    |> list.count(fn(ingt) {
      list.any(ranges, fn(range) { ingt >= range.0 && ingt <= range.1 })
    })

  let r_str = int.to_string(sum)

  io.println("Result: " <> r_str)
  let assert Ok(_) = simplifile.write("src/result" <> part <> ext, r_str)

  Nil
}
