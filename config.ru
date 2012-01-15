# -*- mode: ruby; tab-width: 2; indent-tabs-mode: nil; -*-
$LOAD_PATH.push File.realdirpath(File.dirname(__FILE__))
require "bundler/setup"
require "lib/bishop"

# Configuration by environment variables
# BISHOP_SERVER
# BISHOP_CHANNELS
# BISHOP_PORT
# BISHOP_SSL_USE
# BISHOP_SSL_VERIFY
# BISHOP_LOG_VERBOSE
# BISHOP_API_KEY

# BISHOP_GITHUB_HOOK_CHANNELS

Bishop::Bot.start if !!ENV["BISHOP_SERVER"] && !!ENV["BISHOP_CHANNELS"]

require "lib/bishop/github_hook"
map "/hooks/github" do
  run Bishop::GithubHook.new
end

require "lib/bishop/web_manager"
map "/" do
  run Bishop::WebManager.new
end
