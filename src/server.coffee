# Initialize
process.chdir __dirname

# Require built-in modules
path = require "path"
format = require("util").format

# Require 3rd party modules
cfg = require "config"
chokidar = require "chokidar"
express = require "express"
MongoDB = require("mongodb").Db
nib = require "nib"
stylus = require "stylus"

# Server class
class Server
  constructor: ->
    # Initialize
    @app = express()
    @db = null
    @fsx = require "./lib/filehelpers"

    # Paths
    cfg.app.path = __dirname
    @viewsPath = path.join cfg.app.path, "views"
    @webRoot = path.join cfg.app.path, "web"

    # Basic config
    @app.configure =>
      @app.set "port", cfg.web.port
      @app.set "views", @viewsPath
      @app.set "view engine", "jade"
      @app.use express.bodyParser()
      @app.use express.methodOverride()
      @app.use stylus.middleware(src: @webRoot, compile:@compileStylus)

    # Dev config
    @app.configure "development", =>
      @app.use express.logger "dev"
      @app.use express.errorHandler()
      @app.locals.pretty = true
      @app.use @app.router
      @app.use express["static"] @webRoot

    # Setup routes
    @routes = require "./routes"
    @app.get "/", @routes.index.bind(this)
    @app.get "/jobs", @routes.jobs.bind(this)
    @app.get "/test", @routes.test.bind(this)
    @app.post "/job", @routes.createJob.bind(this)

    # Setup directory watcher
    @watcher = chokidar.watch cfg.ocr.path,
      ignoreInitial: true
      persistent: true
    @watcher.on "add", (filepath) ->
      console.log "File added: ", filepath
    @watcher.on "change", (filepath) ->
      console.log "File changed: ", filepath
    @watcher.on "unlink", (filepath) ->
      console.log "File removed: ", filepath
    console.log "Watching path: " + path.resolve cfg.ocr.path

    # Run
    MongoDB.connect format("mongodb://%s:%s/%s?w=1", cfg.mongo.host, cfg.mongo.port, cfg.mongo.db), (err, db) =>
      if !err
        @db = db.collection "watchocrweb"
        console.log "Connected to database."
        @app.listen @app.get("port"), =>
          console.log "Webserver listening on port " + @app.get("port") + "."
      else
        console.log err

  # Compile stylus with nib
  compileStylus: (str, path) ->
    stylus(str).set("filename", path).use(nib())["import"]("nib")


new Server()