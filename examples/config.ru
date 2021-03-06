require "../lib/Goofy"
require "goofy/contrib"

Goofy.plugin Goofy::Mote

ITEMS = ("A".."Z").to_a

Goofy.define do
  def mote_vars(content)
    { content: content }
  end

  on default do
    res.write view("home", list: ITEMS)
  end
end

run Goofy
