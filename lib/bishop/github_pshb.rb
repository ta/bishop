# -*- mode: ruby; tab-width: 2; indent-tabs-mode: nil; -*-
require "uri"
require "json"
require 'net/http'

module Bishop
  # see http://developer.github.com/v3/repos/hooks/#pubsubhubbub
  class GithubPSHB < Bishop::Base

    post "/#{ENV["BISHOP_API_KEY"]}" do

      if ENV["BISHOP_GITHUB_PSHB_CHANNELS"]
        payload  = JSON.parse(URI.unescape(params["payload"]))
        channels = ENV["BISHOP_GITHUB_PSHB_CHANNELS"].split(",")
        user     = false
        nick     = false
        msg      = []

        case request.env["HTTP_X_GITHUB_EVENT"]
        when "push"
          msg = []
          payload["commits"].each do |commit|
            msg << "[#{payload["repository"]["name"]}] #{commit["url"]} committed by #{commit["author"]["email"]} with message: #{commit["message"]}"
          end
        when "issues"
          nick = payload["issue"]["assignee"]
          user = payload["issue"]["user"]["login"]
          msg << "[#{payload["repository"]["full_name"]}] #{user} #{payload["action"]} issue: \"#{payload["issue"]["title"]}\" - #{payload["issue"]["html_url"]}"
        when "issue_comment"
          nick = payload["issue"]["assignee"]
          user = payload["issue"]["user"]["login"]
          msg << "[#{payload["repository"]["full_name"]}] #{user} commented on issue: \"#{payload["issue"]["title"]}\" - #{payload["issue"]["html_url"]}"
        when pull_request
          msg << "[#{payload["base"]["repo"]["full_name"]}] #{payload["head"]["user"]["login"]} #{payload["action"]} pull request #{payload["number"]}- #{payload["url"]}"
        else
          # TODO: commit_comment, pull_request_review_comment, gollum
          msg << "[Github PubSubHubbub hook] Unhandled event: #{request.env["HTTP_X_GITHUB_EVENT"]}"
        end

        # FIXME: This hack is nessecary for a heroku hosted app to work
        # as .channels.each will throw a DRb::DRbConnError / Connection refused
        # The .join(",").split(",") give us a simple array to work with
        Bishop::Bot.instance.channels.join(",").split(",").each do |channel|
          if (channels.index(channel))
            msg.each do |m|
              if nick and nick != user
                Bishop::Bot.instance.Channel(channel).safe_msg("#{nick}: #{m}")
              else
                Bishop::Bot.instance.Channel(channel).safe_notice(m)
              end
            end
          end
        end
      end

      "OK"
    end
  end
end
