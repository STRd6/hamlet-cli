stdin = require "stdin"
{parser, compile} = require 'hamlet-compiler'

cli = require("commander")
  .version(require('../package.json').version)
  .option("-a, --ast", "Output AST")
  .option("-r, --runtime [provider]", "Runtime provider")
  .parse(process.argv)

stdin (input) ->
  ast = parser.parse(input)

  if cli.ast
    process.stdout.write JSON.stringify(ast)

    return

  program = compile ast,
    runtime: cli.runtime

  process.stdout.write program
