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
  let part = ".part1"
  let ext = ".txt"
  // let ext = ".test.txt"

  let assert Ok(contents) = simplifile.read("src/input" <> ext)
  let lines =
    contents
    |> string.trim
    |> string.split("\n")

  let assert Ok(line0) = list.first(lines)
  let width = string.length(line0)
  let height = list.length(lines)

  let empty_grid: dict.Dict(#(Int, Int), Int) = dict.new()

  let grid =
    lines
    |> string.concat
    |> string.to_graphemes
    |> list.index_fold(empty_grid, fn(cur_grid, char, index) {
      let x = index % width
      let y = index / width
      dict.insert(cur_grid, #(x, y), case char {
        "@" -> 1
        _ -> 0
      })
    })

  let dirs = [
    #(0, -1),
    #(1, -1),
    #(1, 0),
    #(1, 1),
    #(0, 1),
    #(-1, 1),
    #(-1, 0),
    #(-1, -1),
  ]

  let sum =
    list.range(0, height - 1)
    |> list.fold(0, fn(cury, y) {
      list.range(0, width - 1)
      |> list.fold(cury, fn(curx, x) {
        let nbs = case dict.get(grid, #(x, y)) {
          Ok(1) ->
            list.fold(dirs, 0, fn(cur_nbs, dxy) {
              let #(dx, dy) = dxy
              case dict.get(grid, #(x + dx, y + dy)) {
                Ok(value) -> cur_nbs + value
                _ -> cur_nbs
              }
            })
          _ -> 9
        }
        case nbs < 4 {
          True -> curx + 1
          _ -> curx
        }
      })
    })

  let r_str = int.to_string(sum)

  io.println("Result: " <> r_str)
  let assert Ok(_) = simplifile.write("src/result" <> part <> ext, r_str)

  Nil
}
