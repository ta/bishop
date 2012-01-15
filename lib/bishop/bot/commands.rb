# -*- mode: ruby; tab-width: 2; indent-tabs-mode: nil; -*-
class Commands
  include Cinch::Plugin

  match "!about", :method => :about
  def about(m)
    m.reply "#{m.user.nick}: I'm Bishop - an android build and designed to give you some (ir)relevant information."
  end
  
  match "!process", :method => :process
  def process(m)
    `ps vp #{Process.pid}`.chomp.split("\n").each { |x| m.reply "#{m.user.nick}: #{x}" }
  end
  
  match "!uname", :method => :uname
  def uname(m)
    m.reply "#{m.user.nick}: #{`uname -a`}"
  end
  
  match "!uptime", :method => :uptime
  def uptime(m)
    m.reply "#{m.user.nick}: #{`uptime`}"
  end
  
  match "!help", :method => :help
  def help(m)
    m.reply "#{m.user.nick}: Available commands: !about, !help, !process, !uname, !uptime, "
  end
  
end
