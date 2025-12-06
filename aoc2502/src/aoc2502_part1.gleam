import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

// Deliberately without RegExs

pub fn debug(str: String) -> Nil {
  let _ = str
  io.println(str)
}

pub fn xdebug(str: String) -> Nil {
  let _ = str
  Nil
}

type Res {
  Res(sum: Int)
}

@external(erlang, "math", "log10")
fn log10(x: Float) -> Float

fn int_log10(x: Int) -> Int {
  case x {
    0 -> 1
    _ -> float.truncate(log10(int.to_float(x)))
  }
}

@external(erlang, "math", "pow")
fn float_pow(base: Float, exp: Float) -> Float

fn int_pow(base: Int, exp: Int) -> Int {
  float_pow(int.to_float(base), int.to_float(exp))
  |> float.truncate
}

type State {
  State(a1: Int, a: Int, b: Int, sum: Int)
}

fn my_loop(state: State) -> State {
  let State(a1:, a:, b:, sum:) = state
  let a1_mul = int_pow(10, int_log10(a1) + 1)
  let a1a1 = a1 * a1_mul + a1
  case a1a1 <= b {
    False -> state
    True -> {
      case a1a1 >= a {
        True -> {
          io.println(
            "LOOP a1a1="
            <> int.to_string(a1a1)
            <> " a1="
            <> int.to_string(a1)
            <> " b="
            <> int.to_string(b)
            <> " a1_mul="
            <> int.to_string(a1_mul),
          )
          my_loop(State(..state, a1: a1 + 1, sum: sum + a1a1))
        }
        False -> my_loop(State(..state, a1: a1 + 1))
      }
    }
  }
}

pub fn main() -> Nil {
  let part = ".part1"
  let ext = ".txt"
  // let ext = ".test.txt"

  let assert Ok(contents) = simplifile.read("src/input" <> ext)
  let lines = string.split(string.trim(contents), "\n")

  let initial = Res(0)

  let res =
    list.fold(lines, initial, fn(current, line) {
      let assert [a_str0, b_str0] = string.split(line, "-")

      let a_str = case string.length(a_str0) % 2 == 1 {
        True -> "0" <> a_str0
        _ -> a_str0
      }
      let b_str = case string.length(b_str0) % 2 == 1 {
        True -> "0" <> b_str0
        _ -> b_str0
      }

      let a1_strlen = string.length(a_str) / 2
      let b1_strlen = string.length(b_str) / 2

      case string.starts_with(a_str, "0") && string.starts_with(b_str, "0") {
        True -> {
          debug("Uneven source and target, skipping line " <> line)
          current
        }
        _ -> {
          let a1_str = string.slice(a_str, 0, a1_strlen)
          let b1_str = string.slice(b_str, 0, b1_strlen)

          let assert Ok(a1) = int.parse(a1_str)
          let assert Ok(a) = int.parse(a_str)
          let assert Ok(b) = int.parse(b_str)

          let _ =
            debug(
              ">>"
              <> a_str
              <> " :: "
              <> b_str
              <> "  "
              <> a1_str
              <> " :: "
              <> b1_str,
            )

          debug("res=" <> int.to_string(my_loop(State(a1, a, b, 0)).sum))

          Res(current.sum + my_loop(State(a1, a, b, 0)).sum)
        }
      }
    })

  let r_str = int.to_string(res.sum)

  io.println("Result: " <> r_str)
  let assert Ok(_) = simplifile.write("src/result" <> part <> ext, r_str)

  Nil
}
