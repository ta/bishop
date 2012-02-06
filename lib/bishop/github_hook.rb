# -*- mode: ruby; tab-width: 2; indent-tabs-mode: nil; -*-
require "uri"
require "json"
require 'net/http'

module Bishop
  # see http://help.github.com/post-receive-hooks/
  class GithubHook < Bishop::Base

    post "/#{ENV["BISHOP_API_KEY"]}" do

      if ENV["BISHOP_GITHUB_HOOK_CHANNELS"]
        payload   = JSON.parse(URI.unescape(params["payload"]))
        channels = ENV["BISHOP_GITHUB_HOOK_CHANNELS"].split(",")
        
        payload["commits"].each do |commit|
          # FIXME: This hack is nessecary for a heroku hosted app to work
          # as .channels.each will throw a DRb::DRbConnError / Connection refused
          # The .join(",").split(",") give us a simple array to work with
          Bishop::Bot.instance.channels.join(",").split(",").each do |channel|
            if (channels.index(channel))
              response = Net::HTTP.post_form(URI.parse("http://git.io/"), "url" => commit["url"])
              commit["url"] = Net::HTTPSuccess === response  ? response["Location"] : commit["url"]
              Bishop::Bot.instance.safe_notice channel, "[#{payload["repository"]["name"]}] #{commit["url"]} committed by #{commit["author"]["email"]} with message: #{commit["message"]}"
            end
          end
        end
      end

      "OK"
    end

  end
end
