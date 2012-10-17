# -*- mode: ruby; tab-width: 2; indent-tabs-mode: nil; -*-
class Greetings
  include Cinch::Plugin
  
  match "bishop!", :method => :greet, :prefix => ""
  def greet(m)
    m.reply "#{m.user.nick}!"
  end
  
end
