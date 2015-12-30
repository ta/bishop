# -*- mode: ruby; tab-width: 2; indent-tabs-mode: nil; -*-
$LOAD_PATH.push File.realdirpath(File.dirname(__FILE__))
require "bundler/setup"
require "lib/bishop"

Signal.trap("INT") do
  Bishop::Bot.kill
end

# Configuration by environment variables
# BISHOP_SERVER
# BISHOP_CHANNELS
# BISHOP_PORT
# BISHOP_SSL_USE
# BISHOP_SSL_VERIFY
# BISHOP_LOG_VERBOSE
# BISHOP_API_KEY

# BISHOP_GITHUB_HOOK_CHANNELS
# BISHOP_HEROKU_HOOK_CHANNELS
# BISHOP_REDMINE_HOOK_CHANNELS

Bishop::Bot.start if ENV.key?("BISHOP_SERVER")

require "lib/bishop/simpleci_hook"
map "/hooks/simpleci" do
  run Bishop::SimpleCIHook.new
end

require "lib/bishop/github_hook"
map "/hooks/github" do
  run Bishop::GithubHook.new
end

require "lib/bishop/github_pshb"
map "/hooks/github-pshb" do
  run Bishop::GithubPSHB.new
end

require "lib/bishop/gitlab_hook"
map "/hooks/gitlab" do
  run Bishop::GitlabHook.new
end

require "lib/bishop/heroku_hook"
map "/hooks/heroku" do
  run Bishop::HerokuHook.new
end

require "lib/bishop/redmine_hook"
map "/hooks/redmine" do
  run Bishop::RedmineHook.new
end

require "lib/bishop/web_manager"
map "/" do
  run Bishop::WebManager.new
end
