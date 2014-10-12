fs = require "fs"
stdin = require "stdin"
{compile} = require 'hamlet-compiler'
wrench = require "wrench"
CoffeeScript = require "coffee-script"

cli = require("commander")
  .version(require('../package.json').version)
  .option("-a, --ast", "Output AST")
  .option("-d, --dir [directory]", "Compile all haml files in the given directory")
  .option("--encoding [encoding]", "Encoding of files being read from --dir (default 'utf-8')")
  .option("-e, --exports [name]", "Export compiled template as (default 'module.exports'")
  .option("-m, --mode [mode]", "Parsing mode 'haml' or 'jade' (default 'haml')")
  .option("-r, --runtime [provider]", "Runtime provider")
  .parse(process.argv)

encoding = cli.encoding or "utf-8"

extensions =
  haml: /\.haml$/
  jade: /\.jade$/

modeForPath = (path) ->
  Object.keys(extensions).reduce (mode, key) ->
    mode or (path.match(extensions[key]) and key)
  , undefined

if (dir = cli.dir)
  # Ensure exactly one trailing slash
  dir = dir.replace /\/*$/, "/"

  files = wrench.readdirSyncRecursive(dir)

  files.forEach (path) ->
    inPath = "#{dir}#{path}"

    if fs.lstatSync(inPath).isFile()
      if mode = modeForPath(inPath)
        basePath = inPath.replace extensions[mode], ""
        outPath = "#{basePath}.js"

        console.log "Compiling #{inPath} to #{outPath}"

        input = fs.readFileSync inPath,
          encoding: encoding

        # Replace $file in exports with path
        if cli.exports
          exports = cli.exports.replace("$file", basePath)

        program = compile input,
          runtime: cli.runtime
          exports: exports
          compiler: CoffeeScript
          mode: mode

        fs.writeFileSync(outPath, program)

else
  stdin (input) ->

    if cli.ast
      process.stdout.write JSON.stringify(ast)

      return

    else
      process.stdout.write compile input,
        mode: cli.mode
        runtime: cli.runtime
        exports: cli.exports
        compiler: CoffeeScript
