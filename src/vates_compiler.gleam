import gleam/io
import gleam/string
import vates_compiler/internal/lexer

pub fn main() -> Nil {
  lexer.lex("const let type pub fn ()[]{}:,.=->|>+-")
  |> string.inspect
  |> io.println
}
