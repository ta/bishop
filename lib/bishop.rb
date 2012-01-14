# -*- mode: ruby; tab-width: 2; indent-tabs-mode: nil; -*-
require "cinch"
require "drb"

require "lib/bishop/commands"
require "lib/bishop/greetings"
require "lib/bishop/seen"

class Bishop
  DRBURI  = "drbunix:./tmp/bishop.sock"
  @@proc  = nil
  @@bot   = nil
  
  def self.bot
    self.start unless @@bot
    @@bot
  end
  
  def self.start
    return @@bot if @@bot
    
    @@proc = fork do
      bot = Cinch::Bot.new do
        configure do |c|
          c.nick            = "bishop"
          c.user            = "bishop"
          c.realname        = "Bishop"
          c.server          = ENV["BISHOP_SERVER"]
          c.port            = ENV["BISHOP_PORT"] || !!ENV["BISHOP_SSL_USE"] ? 6697 : 6667
          c.channels        = ENV['BISHOP_CHANNELS'].to_s.split(",")
          c.ssl.use         = !!ENV["BISHOP_SSL_USE"]
          c.ssl.verify      = !!ENV["BISHOP_SSL_VERIFY"]
          c.verbose         = !!ENV["BISHOP_LOG_VERBOSE"]
          c.plugins.prefix  = /^bishop[\:,] /
          c.plugins.plugins = [Commands,Greetings,Seen]
        end
        
      end
      
      log = File.open("./tmp/bishop.log", "a")
      log.sync = true
      bot.logger = Cinch::Logger::FormattedLogger.new(log)
      
      Signal.trap("INT") do
        puts "*** bishop is shutting down (PID #{Process.pid})"
        bot.quit "I'll go! Believe me, I'd prefer not to. I may be synthetic, but I'm not stupid"
        DRb.stop_service
      end
      
      Signal.trap("TERM") do
        puts "*** bishop is shutting down (PID #{Process.pid})"
        bot.quit "I'll go! Believe me, I'd prefer not to. I may be synthetic, but I'm not stupid"
        DRb.stop_service
      end

      DRb.start_service(DRBURI, bot)
      bot.start()
    end
    sleep 2
    DRb.start_service
    @@bot = DRbObject.new_with_uri(DRBURI)
  end
  
  def self.stop
    Process.kill("INT", @@proc)
  end
  
end

Bishop.start if !!ENV["BISHOP_SERVER"] && !!ENV["BISHOP_CHANNELS"]
