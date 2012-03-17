require 'easy_diff'

Dir["#{File.dirname(__FILE__)}/mongoid/**/*.rb"].sort.each { |f| require f }

Mongoid::History.modifier_class_name = "User"
Mongoid::History.current_user_method ||= :current_user
