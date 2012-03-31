class Car
  include Mongoid::Document
  embeds_many :doors
end

class Door
  include Mongoid::Document
  embedded_in :car
  embeds_one  :window
end

class Window
  include Mongoid::Document
  embedded_in :door
end
