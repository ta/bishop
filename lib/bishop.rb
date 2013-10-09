# -*- mode: ruby; tab-width: 2; indent-tabs-mode: nil; -*-
require "sinatra/base"
require "lib/bishop/bot"

module Bishop 
  class Base < Sinatra::Base

    configure do
      disable :show_exceptions
      enable :logging, :dump_errors, :clean_trace
    end

    before do
      halt 400, "Only HTTPS is allowed!" if !request.secure? && ENV["RACK_ENV"] == "production"
      # Dump request body for debugging purposes
      if ENV["DEBUG"]
        STDERR.puts request.env["Content-Type"]
        STDERR.puts request.body.read 
        request.body.rewind
      end
    end

  end
end
