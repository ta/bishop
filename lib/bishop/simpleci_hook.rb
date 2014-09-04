# -*- encoding: utf-8; mode: ruby; tab-width: 2; indent-tabs-mode: nil -*-
# -*- mode: ruby; tab-width: 2; indent-tabs-mode: nil; -*-
require "uri"
require "json"

module Bishop
  # see http://help.github.com/post-receive-hooks/
  class SimpleCIHook < Bishop::Base

    post "/#{ENV["BISHOP_API_KEY"]}" do

      if ENV["BISHOP_SIMPLECI_HOOK_CHANNELS"]
        payload  = JSON.parse(URI.unescape(params["payload"]))
        channels = ENV["BISHOP_SIMPLECI_HOOK_CHANNELS"].split(",")
        
        # FIXME: This hack is nessecary for a heroku hosted app to work
        # as .channels.each will throw a DRb::DRbConnError / Connection refused
        # The .join(",").split(",") give us a simple array to work with
        Bishop::Bot.instance.channels.join(",").split(",").each do |channel|
          if (channels.index(channel))
            #response      = Net::HTTP.post_form(URI.parse("http://git.io/"), "url" => commit["url"])
            #commit["url"] = Net::HTTPSuccess === response  ? response["Location"] : commit["url"]
            Bishop::Bot.instance.Channel(channel).notice("[#{payload["project"]}] Build #{payload["commit_version"][0..9]} committet by #{payload["commit_author"]} #{payload["status"] ? "\x0309passed\x0F" : "\x0304failed\x0F"} at #{payload["built_at"]} - #{payload["url"]}")
          end
        end
      end

      "OK"
    end

  end
end
