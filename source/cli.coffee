fs = require "fs"
stdin = require "stdin"
{parser, compile} = require 'hamlet-compiler'
wrench = require "wrench"

cli = require("commander")
  .version(require('../package.json').version)
  .option("-a, --ast", "Output AST")
  .option("-d, --dir [directory]", "Compile all haml files in the given directory")
  .option("--encoding [encoding]", "Encoding of files being read from --dir (default 'utf-8')")
  .option("-e, --exports [name]", "Export compiled template as (default 'module.exports'")
  .option("-r, --runtime [provider]", "Runtime provider")
  .parse(process.argv)

encoding = cli.encoding or "utf-8"
hamlExtension = /\.haml$/

if (dir = cli.dir)
  # Ensure exactly one trailing slash
  dir = dir.replace /\/*$/, "/"

  files = wrench.readdirSyncRecursive(dir)

  files.forEach (path) ->
    inPath = "#{dir}#{path}"

    if fs.lstatSync(inPath).isFile()
      if inPath.match(hamlExtension)
        outPath = inPath.replace hamlExtension, ".js"

        console.log "Compiling #{inPath} to #{outPath}"

        input = fs.readFileSync inPath,
          encoding: encoding

        # Replace $file in exports with path
        if cli.exports
          exports = cli.exports.replace("$file", path.replace hamlExtension, "")

        program = compile parser.parse(input),
          runtime: cli.runtime
          exports: exports

        fs.writeFileSync(outPath, program)

else
  stdin (input) ->

    if cli.ast
      process.stdout.write JSON.stringify(ast)

      return

    else
      process.stdout.write compile parser.parse(input),
        runtime: cli.runtime
        exports: cli.exports
