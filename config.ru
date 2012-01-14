# -*- mode: ruby; tab-width: 2; indent-tabs-mode: nil; -*-
$LOAD_PATH.push File.realdirpath(File.dirname(__FILE__))
require "bundler/setup"
require "thread"
require "net/http"
require "net/https"
require "sinatra"
require "lib/bishop"

# Configuration by environment variables
# BISHOP_SERVER
# BISHOP_CHANNELS
# BISHOP_PORT
# BISHOP_SSL_USE
# BISHOP_SSL_VERIFY
# BISHOP_LOG_VERBOSE
# BISHOP_API_KEY

configure do
  disable :show_exceptions
  enable :logging, :dump_errors, :clean_trace
end

before do
  halt 400, "Only HTTPS is allowed!" if !request.secure? && ENV["RACK_ENV"] == "production"
  unless request.path_info == "/ping"
    halt 400, "Missing/invalid api key" if ENV["BISHOP_API_KEY"] != params["apikey"]
  end
end


# Message format
# apikey=<apikey>&server=<server>

post "/start" do
  ENV["BISHOP_SERVER"] = params["server"]
  Bishop.bot
end


# Message format
# apikey=<apikey>

post "/stop" do
  Bishop.bot.stop
end


# Message format
# apikey=<apikey>&channel=<channel>&password=<password>

post "/join" do
  Bishop.bot.join(params["channel"], params["password"])
end


# Message format
# apikey=<apikey>&channel=<channel>&reason=<reason>

post "/part" do
  Bishop.bot.part(params["channel"], params["reason"])
end


# Message format
# apikey=<apikey>&recipient=<channel_or_user>&text=<text>

post "/action" do
  Bishop.bot.safe_action(params["recipient"], params["text"])
end

post "/notice" do
  Bishop.bot.safe_notice(params["recipient"], params["text"])
end


# Message format
# apikey=<apikey>&recipient=<channel_or_user>&text=<text>&nick=<nick>

post "/message" do
  params["text"] = "#{params["nick"]}: #{params["text"]}" unless params["nick"].nil?
  Bishop.bot.safe_msg(params["recipient"], params["text"])
end


get "/ping" do
  "pong"
end

run Sinatra::Application
