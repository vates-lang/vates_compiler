import gleam/io
import gleam/string
import vates_compiler/internal/lexer

pub fn main() -> Nil {
  lexer.lex("const something = ")
  |> string.inspect
  |> io.println
}
