class Foo
  include Mongoid::Document
  embeds_many :bars
end

class Bar
  include Mongoid::Document
  embedded_in :foo
  embeds_one  :baz
end

class Baz
  include Mongoid::Document
  embedded_in :bar
end
