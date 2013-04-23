# -*- mode: ruby; tab-width: 2; indent-tabs-mode: nil; -*-
require "uri"
require "json"
require 'net/http'

module Bishop
  # see http://developer.github.com/v3/repos/hooks/#pubsubhubbub
  class GithubPSHB < Bishop::Base

    helpers do
      def git_io url
        response = Net::HTTP.post_form(URI.parse("http://git.io/"), "url" => url)
        Net::HTTPSuccess === response  ? response["Location"] : url
      end
    end

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
            msg << "[#{payload["repository"]["owner"]["name"]}/#{payload["repository"]["name"]}] #{commit["author"]["username"]} pushed a commit with message: \"#{commit["message"]}\" - #{git_io(commit["url"])}"
          end
        when "issues"
          nick = payload["issue"]["assignee"]["login"] if payload["issue"]["assignee"]
          user = payload["issue"]["user"]["login"]
          msg << "[#{payload["issue"]["html_url"].match(/^https:\/\/github.com\/(.+)\/issues/)[1]}] #{user} #{payload["action"]} issue: \"#{payload["issue"]["title"]}\" - #{git_io(payload["issue"]["html_url"])}"
        when "issue_comment"
          nick = payload["issue"]["assignee"]["login"] if payload["issue"]["assignee"]
          user = payload["comment"]["user"]["login"]
          msg << "[#{payload["issue"]["html_url"].match(/^https:\/\/github.com\/(.+)\/issues/)[1]}] #{user} commented on issue: \"#{payload["issue"]["title"]}\" - #{git_io(payload["issue"]["html_url"])}"
        when "pull_request"
          msg << "[#{payload["base"]["repo"]["full_name"]}] #{payload["head"]["user"]["login"]} #{payload["action"]} pull request #{payload["number"]} - #{git_io(payload["url"])}"
        when "gollum"
          payload["pages"].each do |page|
            repo_full_name = page["html_url"].match(/^https:\/\/github.com\/(.+)\/wiki/)[1]
            diff_url = "https://github.com/#{}/wiki/_compare/#{page["sha"]}"
            msg << "[#{repo_full_name}] someone updated wikipage: \"#{page["title"]}\" - #{git_io(page["html_url"])} (diff: #{git_io(diff_url)})"
          end
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
