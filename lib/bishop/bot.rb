# -*- mode: ruby; tab-width: 2; indent-tabs-mode: nil; -*-
require "cinch"
require "drb"

require "lib/bishop/bot/commands"
require "lib/bishop/bot/greetings"
require "lib/bishop/bot/seen"

module Bishop
  class Bot
    DRBURI    = "drbunix:/tmp/bishop.sock"
    @pid      = nil
    @instance = nil

    class << self
      def start
        return @instance if @instance

        @pid = fork do
          bot = Cinch::Bot.new do
            configure do |c|
              c.nick            = "bishop"
              c.user            = "bishop"
              c.realname        = "Bishop"
              c.server          = ENV["BISHOP_SERVER"]
              c.port            = (ENV["BISHOP_PORT"] || ENV.key?("BISHOP_SSL_USE")) ? 6697 : 6667
              c.channels        = ENV['BISHOP_CHANNELS'].to_s.split(",")
              c.ssl.use         = ENV.key?("BISHOP_SSL_USE")
              c.ssl.verify      = ENV.key?("BISHOP_SSL_VERIFY")
              c.verbose         = ENV.key?("BISHOP_LOG_VERBOSE")
              c.plugins.prefix  = /^bishop[\:,] /
              c.plugins.plugins = [Commands, Greetings, Seen]
            end

            Signal.trap("INT") do
              bot.quit
              DRb.stop_service
            end

            Signal.trap("TERM") do
              bot.quit
              DRb.stop_service
            end
          end

          log = File.open("./tmp/bishop.log", "a")
          log.sync = true
          bot.loggers << Cinch::Logger::FormattedLogger.new(log)

          DRb.start_service(DRBURI, bot)
          bot.start
        end

        sleep 2
        DRb.start_service
        @instance = DRbObject.new_with_uri(DRBURI)
      end

      def stop
        puts "*** bishop is shutting down (PID #{Process.pid})"
        @instance.quit "I'll go! Believe me, I'd prefer not to. I may be synthetic, but I'm not stupid"
        @instance = nil
        DRb.stop_service
        Process.kill("INT", @pid)
      end
    end
  end
end
