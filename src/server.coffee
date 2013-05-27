# Set the current working directory.
process.chdir __dirname

# Require built-in modules
path = require "path"
format = require("util").format

# Require 3rd party modules
cfg = require "config"
chokidar = require "chokidar"
email = require "emailjs"
express = require "express"
nib = require "nib"
stylus = require "stylus"

# Require own modules
Enrich = require "./lib/Enrich"

# Server class definition.
class Server
  constructor: ->
    # Initialize
    @app = express()
    @fsx = require "./lib/filehelpers"
    @cfg = cfg
    @procs = {}

    # Paths
    if !cfg.app.path
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
      # @app.use tus()
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
    @app.get "/job", @routes.getJob.bind(this)
    @app.get "/job/*", @routes.getJob.bind(this)

    # Setup directory watchers
    cfg.ocr.watchPaths.forEach (wpath) =>
      watcher = chokidar.watch wpath.in, persistent: true
      watcher.on "add", (filepath) =>
        if path.extname(filepath) == ".pdf"
          console.log "File added: ", filepath
          @createProcess filepath, path.join(wpath.out, path.basename(filepath))
      console.log "Watching path: " + path.resolve wpath.in

    # Setup e-mail
    @email = email.server.connect cfg.email

    # Start the web server.
    @app.listen @app.get("port"), =>
      console.log "Webserver listening in " + @app.settings.env + " mode on port " + @app.get("port") + "."


  # Compile stylus with nib
  compileStylus: (str, path) ->
    stylus(str).set("filename", path).use(nib())["import"]("nib")


  # Create a new process
  createProcess: (fin, fout) ->
    pid = Enrich.generateUniqueID()
    fout = path.join(process.env["TMP"], pid + ".pdf") unless fout
    (new Enrich(@, pid, path.resolve(fin), path.resolve(fout))).save().convert()


  # Get process by ID
  getProc: (eid, callback) ->
    (new Enrich(@, eid)).load(callback)


  # Send an email
  sendMail: (options, callback) ->
    @email.send options, callback


new Server()