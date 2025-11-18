import gleeunit/should
import vates_compiler/internal/lexer

pub fn keyword__test() {
  let input = "const type pub fn "

  lexer.lex(input)
  |> should.equal([
    lexer.ParsedToken(lexer.ConstantKeyword, 0),
    lexer.ParsedToken(lexer.TypeKeyword, 6),
    lexer.ParsedToken(lexer.PublicKeyword, 11),
    lexer.ParsedToken(lexer.FunctionKeyword, 15),
  ])
}

pub fn integer__test() {
  let input = "1234_5678_9"

  lexer.lex(input)
  |> should.equal([
    lexer.ParsedToken(lexer.Integer(123_456_789), 0),
  ])
}

pub fn float__test() {
  let input = "1234.5678"

  lexer.lex(input)
  |> should.equal([
    lexer.ParsedToken(lexer.Float(1234.5678), 0),
  ])
}

pub fn const_assignment__test() {
  let input = "const x = -123.456"

  lexer.lex(input)
  |> should.equal([
    lexer.ParsedToken(lexer.ConstantKeyword, 0),
    lexer.ParsedToken(lexer.Identifier("x"), 6),
    lexer.ParsedToken(lexer.Equals, 8),
    lexer.ParsedToken(lexer.Minus, 10),
    lexer.ParsedToken(lexer.Float(123.456), 11),
  ])
}
