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
    end

  end
end
