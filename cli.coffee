stdin = require "stdin"
{jsdom} = require "jsdom"
{parser, compile} = HAMLjr = require 'haml-jr'

document = jsdom()

stdin (data) ->
  ast = parser.parse(data)

  program = compile ast,
    explicitScripts: true

  # console.log program

  fn = eval(program)

  fragment = fn()

  output = Array.prototype.map.call fragment.childNodes, (node) ->
    node.outerHTML
  .join("\n")

  process.stdout.write output
