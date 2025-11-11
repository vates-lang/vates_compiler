import gleam/list
import gleam/string
import splitter

pub type ParsedToken {
  ParsedToken(token: Token, offset: Int)
}

pub type Token {
  Identifier(String)
  Number(Int)
  String(String)

  // Keywords
  ConstantKeyword
  LetKeyword
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
    "let " <> source -> token(lexer, LetKeyword, source, 4)
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
    "0" <> rest
    | "1" <> rest
    | "2" <> rest
    | "3" <> rest
    | "4" <> rest
    | "5" <> rest
    | "6" <> rest
    | "7" <> rest
    | "8" <> rest
    | "9" <> rest -> todo as "number parsing not implemented"
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
  lexer: Lexer,
  token: Token,
  source: String,
  offset: Int,
) -> #(Lexer, ParsedToken) {
  #(advance(lexer, source, offset), ParsedToken(token:, offset: lexer.offset))
}
