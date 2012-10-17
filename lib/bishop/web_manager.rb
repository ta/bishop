# -*- mode: ruby; tab-width: 2; indent-tabs-mode: nil; -*-

module Bishop
  class WebManager < Bishop::Base

    before do
      unless request.path_info == "/ping"
        halt 400, "Missing/invalid api key" if ENV["BISHOP_API_KEY"] != params["apikey"]
      end
    end

    # Message format
    # apikey=<apikey>&server=<server>
    post "/start" do
      ENV["BISHOP_SERVER"] = params["server"]
      Bishop::Bot.start
    end

    # Message format
    # apikey=<apikey>
    post "/stop" do
      Bishop::Bot.stop
    end

    # Message format
    # apikey=<apikey>&channel=<channel>&password=<password>
    post "/join" do
      Bishop::Bot.instance.join(params["channel"], params["password"])
    end

    # Message format
    # apikey=<apikey>&channel=<channel>&reason=<reason>
    post "/part" do
      Bishop::Bot.instance.part(params["channel"], params["reason"])
    end

    # Message format
    # apikey=<apikey>&recipient=<channel_or_user>&text=<text>
    post "/action" do
      Bishop::Bot.instance.Channel(params["recipient"]).safe_action(params["text"])
    end

    post "/notice" do
      #Bishop::Bot.instance.safe_notice(params["recipient"], params["text"])
      Bishop::Bot.instance.Channel(params["recipient"]).safe_notice(params["text"])
    end

    # Message format
    # apikey=<apikey>&recipient=<channel_or_user>&text=<text>&nick=<nick>
    post "/message" do
      params["text"] = "#{params["nick"]}: #{params["text"]}" unless params["nick"].nil?
      Bishop::Bot.instance.Channel(params["recipient"]).safe_msg(params["text"])
    end

    get "/ping" do
      "pong"
    end

  end
end
