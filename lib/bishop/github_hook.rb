# -*- mode: ruby; tab-width: 2; indent-tabs-mode: nil; -*-
require "uri"
require "json"

module Bishop
  # see http://help.github.com/post-receive-hooks/
  class GithubHook < Bishop::Base
    post "/#{ENV["BISHOP_API_KEY"]}" do
      payload  = JSON.parse(URI.unescape(params["payload"]))
      channels = ENV["BISHOP_GITHUB_HOOK_CHANNELS"].split(",")
      
      payload["commits"].each do |commit|
        Bishop::Bot.instance.channels.each do |channel|
          if (channels.index(channel.name))
            Bishop::Bot.instance.safe_notice "#test", "[#{payload["repository"]["name"]}] #{commit["url"]} committed by #{commit["author"]["email"]} with message: #{commit["message"]}"
          end
        end
      end
      "OK"
    end
  end
end