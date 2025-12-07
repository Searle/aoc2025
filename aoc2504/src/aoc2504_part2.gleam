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

pub type GridCells =
  dict.Dict(#(Int, Int), Int)

pub type Grid {
  Grid(width: Int, height: Int, cells: GridCells)
}

pub fn new_grid(width: Int, height: Int) -> Grid {
  Grid(width:, height:, cells: dict.new())
}

pub fn debug_grid(grid: Grid) -> Nil {
  list.range(0, grid.height - 1)
  |> list.each(fn(y) {
    list.range(0, grid.width - 1)
    |> list.fold(y, fn(y, x) {
      io.print(case dict.get(grid.cells, #(x, y)) {
        Ok(1) -> "@"
        _ -> " "
      })
      y
    })
    io.println("")
  })
  io.println("")
}

const dirs = [
  #(0, -1),
  #(1, -1),
  #(1, 0),
  #(1, 1),
  #(0, 1),
  #(-1, 1),
  #(-1, 0),
  #(-1, -1),
]

pub fn count_neighbors(cells: GridCells, x: Int, y: Int) {
  list.fold(dirs, 0, fn(cur_nbs, dxy) {
    let #(dx, dy) = dxy
    case dict.get(cells, #(x + dx, y + dy)) {
      Ok(value) -> cur_nbs + value
      _ -> cur_nbs
    }
  })
}

pub fn calc_cell(cells: GridCells, x: Int, y: Int, changed: Int) {
  case dict.get(cells, #(x, y)) {
    Ok(1) -> {
      case count_neighbors(cells, x, y) < 4 {
        True -> #(0, changed + 1)
        False -> #(1, changed)
      }
    }
    Ok(0) -> #(0, changed)
    _ -> panic as "Invalid cell"
  }
}

pub fn calc_next_grid(grid: Grid, changed: Int) -> #(Grid, Int) {
  let Grid(width:, height:, cells:) = grid
  let empty_grid = new_grid(width, height)

  list.range(0, height - 1)
  |> list.fold(#(empty_grid, changed), fn(cur_grid_changed, y) {
    let #(cur_grid, cur_changed) = cur_grid_changed
    let next_grid_y_changed =
      list.range(0, width - 1)
      |> list.fold(#(cur_grid, cur_changed), fn(cur_grid_changed1, x) {
        let #(cur_grid1, cur_changed1) = cur_grid_changed1
        let #(value, next_changed) = calc_cell(cells, x, y, cur_changed1)
        let next_cells = dict.insert(cur_grid1.cells, #(x, y), value)
        let next_grid = Grid(..cur_grid1, cells: next_cells)
        #(next_grid, next_changed)
      })
    #(next_grid_y_changed.0, next_grid_y_changed.1)
  })
}

pub fn process_grid(grid: Grid, changed) {
  let #(next_grid, next_changed) = calc_next_grid(grid, changed)
  case changed != next_changed {
    True -> process_grid(next_grid, next_changed)
    False -> next_changed
  }
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

  let assert Ok(line0) = list.first(lines)
  let width = string.length(line0)
  let height = list.length(lines)

  let empty_grid = new_grid(width, height)

  let grid =
    lines
    |> string.concat
    |> string.to_graphemes
    |> list.index_fold(empty_grid, fn(cur_grid, char, index) {
      let x = index % width
      let y = index / width
      Grid(
        ..cur_grid,
        cells: dict.insert(cur_grid.cells, #(x, y), case char {
          "@" -> 1
          _ -> 0
        }),
      )
    })

  // debug("GRID " <> string.inspect(grid))
  // debug_grid(grid)

  let sum = process_grid(grid, 0)

  let r_str = int.to_string(sum)

  io.println("Result: " <> r_str)
  let assert Ok(_) = simplifile.write("src/result" <> part <> ext, r_str)

  Nil
}
