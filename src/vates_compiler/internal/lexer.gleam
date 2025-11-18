import gleam/float
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import splitter

pub type ParsedToken {
  ParsedToken(token: Token, offset: Int)
}

pub type Token {
  Identifier(String)
  Integer(Int)
  Float(Float)
  String(String)

  // Keywords
  ConstantKeyword
  TypeKeyword
  PublicKeyword
  FunctionKeyword

  // Symbols
  LeftBrace
  RightBrace
  LeftBracket
  RightBracket
  LeftParenthesis
  RightParenthesis
  Colon
  Comma
  Dot
  Arrow
  Pipe
  Equals

  // Operators
  Plus
  Minus

  EndOfFile
}

type Lexer {
  Lexer(source: String, offset: Int)
}

pub fn lex(input: String) -> List(ParsedToken) {
  Lexer(input, 0)
  |> do_lex([])
  |> list.reverse
}

fn do_lex(lexer: Lexer, tokens: List(ParsedToken)) -> List(ParsedToken) {
  case consume(lexer) {
    #(_, ParsedToken(EndOfFile, _)) -> tokens
    #(lexer, token) -> do_lex(lexer, [token, ..tokens])
  }
}

fn consume(lexer: Lexer) -> #(Lexer, ParsedToken) {
  case lexer.source {
    " " <> source | "\n" <> source | "\r" <> source | "\t" <> source ->
      advance(lexer, source, 1) |> consume
    "const " <> source -> token(lexer, ConstantKeyword, source, 6)
    "type " <> source -> token(lexer, TypeKeyword, source, 5)
    "pub " <> source -> token(lexer, PublicKeyword, source, 4)
    "fn " <> source -> token(lexer, FunctionKeyword, source, 3)
    "{" <> source -> token(lexer, LeftBrace, source, 1)
    "}" <> source -> token(lexer, RightBrace, source, 1)
    "[" <> source -> token(lexer, LeftBracket, source, 1)
    "]" <> source -> token(lexer, RightBracket, source, 1)
    "(" <> source -> token(lexer, LeftParenthesis, source, 1)
    ")" <> source -> token(lexer, RightParenthesis, source, 1)
    ":" <> source -> token(lexer, Colon, source, 1)
    "," <> source -> token(lexer, Comma, source, 1)
    "." <> source -> token(lexer, Dot, source, 1)
    "->" <> source -> token(lexer, Arrow, source, 2)
    "|>" <> source -> token(lexer, Pipe, source, 2)
    "=" <> source -> token(lexer, Equals, source, 1)
    "+" <> source -> token(lexer, Plus, source, 1)
    "-" <> source -> token(lexer, Minus, source, 1)
    "" -> token(lexer, EndOfFile, "", 0)
    "\"" <> source -> todo as "string parsing not implemented"
    "0" <> _
    | "1" <> _
    | "2" <> _
    | "3" <> _
    | "4" <> _
    | "5" <> _
    | "6" <> _
    | "7" <> _
    | "8" <> _
    | "9" <> _ -> consume_number(lexer)
    source ->
      case
        splitter.new([" ", "\n", "\r", "\t"])
        |> splitter.split_before(source)
      {
        #(word, source) ->
          token(lexer, Identifier(word), source, string.length(word))
      }
  }
}

fn advance(lexer: Lexer, source: String, offset: Int) -> Lexer {
  Lexer(source:, offset: lexer.offset + offset)
}

fn token(
  lexer lexer: Lexer,
  token token: Token,
  source source: String,
  offset offset: Int,
) -> #(Lexer, ParsedToken) {
  #(advance(lexer, source, offset), ParsedToken(token:, offset: lexer.offset))
}

fn consume_number(lexer: Lexer) -> #(Lexer, ParsedToken) {
  let #(to_parse, rest, offset, is_floating_point) =
    read_digits("", lexer.source, lexer.offset, False)
  let assert Ok(parsed_token) =
    case is_floating_point {
      True ->
        float.parse(to_parse)
        |> result.map(Float)
      False ->
        int.parse(to_parse)
        |> result.map(Integer)
    }
    |> result.map(token(lexer:, token: _, source: rest, offset:))
  parsed_token
}

fn read_digits(
  accumulator: String,
  input: String,
  offset: Int,
  is_floating_point: Bool,
) -> #(String, String, Int, Bool) {
  case input {
    "_" <> rest -> read_digits(accumulator, rest, offset + 1, is_floating_point)
    "0" <> rest ->
      read_digits(accumulator <> "0", rest, offset + 1, is_floating_point)
    "1" <> rest ->
      read_digits(accumulator <> "1", rest, offset + 1, is_floating_point)
    "2" <> rest ->
      read_digits(accumulator <> "2", rest, offset + 1, is_floating_point)
    "3" <> rest ->
      read_digits(accumulator <> "3", rest, offset + 1, is_floating_point)
    "4" <> rest ->
      read_digits(accumulator <> "4", rest, offset + 1, is_floating_point)
    "5" <> rest ->
      read_digits(accumulator <> "5", rest, offset + 1, is_floating_point)
    "6" <> rest ->
      read_digits(accumulator <> "6", rest, offset + 1, is_floating_point)
    "7" <> rest ->
      read_digits(accumulator <> "7", rest, offset + 1, is_floating_point)
    "8" <> rest ->
      read_digits(accumulator <> "8", rest, offset + 1, is_floating_point)
    "9" <> rest ->
      read_digits(accumulator <> "9", rest, offset + 1, is_floating_point)
    "." <> rest if !is_floating_point ->
      read_digits(accumulator <> ".", rest, offset + 1, True)
    _ -> #(accumulator, input, offset, is_floating_point)
  }
}
