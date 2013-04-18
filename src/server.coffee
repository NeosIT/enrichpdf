# Initialize
process.chdir __dirname
require "coffee-script"

# Require built-in modules
path = require "path"

# Require 3rd party modules
cfg = require "config"
express = require "express"

# Server class
class Server
  constructor: ->
    # Setup express and socket.io
    @app = express()
    # @httpserver = http.createServer @app

    # Paths
    cfg.app.path = __dirname
    @viewsPath = path.join cfg.app.path, "views"
    @webRoot = path.join cfg.app.path, "web"

    # Basic config
    @app.configure =>
      @app.set "port", cfg.web.port
      @app.use express.methodOverride()

    # Dev config
    @app.configure "development", =>
      @app.use express.logger "dev"
      @app.use express.errorHandler()

    # Setup routes
    @routes = require "./routes"
    @app.get "/", @routes.index.bind(this)

    # Run
    @app.listen @app.get "port"


new Server()