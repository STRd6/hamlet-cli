stdin = require "stdin"
{parser, compile} = HAMLjr = require 'haml-jr'

cli = require("commander")
  .version(require('../package.json').version)
  .option("-a, --ast", "Output AST")
  .option("-H, --html", "Render output as HTML rather than JavaScript")
  .option("-n, --name <name>", "Specify the template name")
  .parse(process.argv)

stdin (input) ->
  ast = parser.parse(input)

  if cli.ast
    process.stdout.write JSON.stringify(ast)

    return

  if cli.html
    {jsdom} = require "jsdom"
    document = jsdom()

    program = compile ast,
      name: cli.name

    fn = eval(program)

    fragment = fn()

    output = Array.prototype.map.call fragment.childNodes, (node) ->
      node.outerHTML
    .join("\n")

    process.stdout.write output
  else
    program = compile ast,
      name: cli.name

    process.stdout.write program
