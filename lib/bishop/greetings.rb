# -*- mode: ruby; tab-width: 2; indent-tabs-mode: nil; -*-
class Greetings
  include Cinch::Plugin
  
  prefix ""
  match "bishop!", :method => :greet
  def greet(m)
    m.reply "#{m.user.nick}!"
  end
  
end
