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
        payload  = request.env["CONTENT_TYPE"] == "application/json" ? JSON.parse(request.body.read) : JSON.parse(params["payload"])
        channels = ENV["BISHOP_GITHUB_PSHB_CHANNELS"].split(",")
        user     = false
        nick     = false
        msg      = []

        case request.env["HTTP_X_GITHUB_EVENT"]
        when "push"
          payload["commits"].each do |commit|
            msg << sprintf("[%s/%s] %s pushed a commit: \"%s\" - %s", 
              payload["repository"]["owner"]["name"],
              payload["repository"]["name"],
              commit["author"]["username"],
              commit["message"],
              git_io(commit["url"])
            )
          end

        when "issues"
          nick = payload["issue"]["assignee"]["login"] if payload["issue"]["assignee"]
          user = payload["issue"]["user"]["login"]
          msg << sprintf("[%s] %s %s issue: \"%s\" - %s",
            payload["issue"]["html_url"].match(/^https:\/\/github.com\/(.+)\/issues/)[1],
            user,
            payload["action"],
            payload["issue"]["title"],
            git_io(payload["issue"]["html_url"])
          )

        when "issue_comment"
          nick = payload["issue"]["assignee"]["login"] if payload["issue"]["assignee"]
          user = payload["comment"]["user"]["login"]
          msg << sprintf("[%s] %s commented on issue: \"%s\" - %s",
            payload["issue"]["html_url"].match(/^https:\/\/github.com\/(.+)\/issues/)[1],
            user,
            payload["issue"]["title"],
            git_io(payload["issue"]["html_url"])
          )

        when "commit_comment"
          user = payload["sender"]["login"]
          msg << sprintf("[%s] %s commented on committed file: \"%s:%s\" - %s",
            payload["repository"]["name"],
            user,
            payload["comment"]["path"],
            payload["comment"]["line"],
            git_io(payload["comment"]["html_url"])
          )

        when "pull_request"
          msg << sprintf("[%s] %s %s pull request %s - %s",
            payload["base"]["repo"]["full_name"],
            payload["head"]["user"]["login"],
            payload["action"],
            payload["number"],
            git_io(payload["url"])
          )

        when "gollum"
          user = payload["sender"]["login"]
          payload["pages"].each do |page|
            repo_full_name = page["html_url"].match(/^https:\/\/github.com\/(.+)\/wiki/)[1]
            diff_url = "https://github.com/#{repo_full_name}/wiki/_compare/#{page["sha"]}"
            msg << sprintf("[%s] %s %s wikipage: \"%s\" - %s (diff: %s)",
              repo_full_name,
              user,
              page["action"],
              page["title"],
              git_io(page["html_url"]),
              git_io(diff_url)
            )
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
