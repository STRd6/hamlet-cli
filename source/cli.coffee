stdin = require "stdin"
{parser, compile} = require 'hamlet-compiler'

cli = require("commander")
  .version(require('../package.json').version)
  .option("-a, --ast", "Output AST")
  .option("-r, --runtime [provider]", "Runtime provider")
  .option("-e, --exports [name]", "Export compiled template as (default 'module.exports'")
  .parse(process.argv)

stdin (input) ->
  ast = parser.parse(input)

  if cli.ast
    process.stdout.write JSON.stringify(ast)

    return

  program = compile ast,
    runtime: cli.runtime
    exports: cli.exports

  process.stdout.write program
