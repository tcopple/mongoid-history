require 'easy_diff'

Dir["#{File.dirname(__FILE__)}/mongoid/**/*.rb"].sort.each { |f| require f }
