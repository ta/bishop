# -*- mode: ruby; tab-width: 2; indent-tabs-mode: nil; -*-
require "uri"
require "json"
require 'net/http'

module Bishop
  # see https://github.com/ta/redmine_post_action_hooks
  class RedmineHook < Bishop::Base

    post "/#{ENV["BISHOP_API_KEY"]}" do

      if ENV["BISHOP_REDMINE_HOOK_CHANNELS"]
        payload  = JSON.parse(URI.unescape(params["payload"]))
        channels = ENV["BISHOP_REDMINE_HOOK_CHANNELS"].split(",")
        
        # FIXME: This hack is nessecary for a heroku hosted app to work
        # as .channels.each will throw a DRb::DRbConnError / Connection refused
        # The .join(",").split(",") give us a simple array to work with
        Bishop::Bot.instance.channels.join(",").split(",").each do |channel|
          if (channels.index(channel))
            msg = case payload["event"]
              when "controller_issues_new_after_save" then
                "[#{payload["project"]["name"]}] #{payload["user"]["login"]} created issue \"#{payload["issue"]["subject"]}\" - #{payload["url"]}"
              when "controller_issues_edit_after_save" then
                "[#{payload["project"]["name"]}] #{payload["user"]["login"]} updated issue \"#{payload["issue"]["subject"]}\" - #{payload["url"]}"
              else
                "/hooks/redmine received an unknown event: #{payload["event"]}"
            end

            if payload["assignee"] and payload["assignee"]["id"] != payload["user"]["id"]
              msg = "#{payload["assignee"]["login"]}: #{msg}"
              Bishop::Bot.instance.safe_msg channel, msg
            else
              Bishop::Bot.instance.safe_notice channel, msg
            end
          end
        end
      end

      "OK"
    end
  end
end
