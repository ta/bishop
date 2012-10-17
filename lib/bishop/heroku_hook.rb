# -*- mode: ruby; tab-width: 2; indent-tabs-mode: nil; -*-
require "uri"
require "json"

module Bishop
  # see http://devcenter.heroku.com/articles/deploy-hooks#http_post_hook
  class HerokuHook < Bishop::Base

    post "/#{ENV["BISHOP_API_KEY"]}" do

      if ENV["BISHOP_HEROKU_HOOK_CHANNELS"]
        channels = ENV["BISHOP_HEROKU_HOOK_CHANNELS"].split(",")
        # FIXME: This hack is nessecary for a heroku hosted app to work
        # as .channels.each will throw a DRb::DRbConnError / Connection refused
        # The .join(",").split(",") give us a simple array to work with
        Bishop::Bot.instance.channels.join(",").split(",").each do |channel|
          if (channels.index(channel))
            Bishop::Bot.instance.Channel(channel).safe_notice("[#{params["app"]}] Rev. #{params["head"]} deployed by #{params["user"]}")
          end
        end        
      end

      "OK"
    end
  end
end
