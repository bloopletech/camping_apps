# encoding: utf-8
#reset scores
#s = 0; c = Akc::Models::Score.count; while s < c; Akc::Models::Score.find(:all, :limit => 100, :offset => s).each { |u| u.update_high_scores }; puts "Did from #{s} to #{s + 100}";s += 100; end

require 'camping/session'
require 'htmlentities/string'
require 'gruff'
require 'lib/has_image'
require 'lib/common'
require 'lib/linear_regression'
require 'kc/models'

Camping.goes :Akc

module Akc
  include Camping::Session
  PATH = File.expand_path(File.dirname(__FILE__)) + '/akc'
end

require 'akc/m'
require 'akc/c'
require 'akc/h'
require 'akc/v'

def Akc.create
  Akc::Models.create_schema
  ActiveRecord::Base.default_timezone = :utc
end