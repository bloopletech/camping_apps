# encoding: utf-8

require 'camping/session'
require 'htmlentities/string'
require 'gruff'
require 'lib/has_image'
require 'lib/common'
require 'lib/linear_regression'
require 'kc/models'

Camping.goes :Kc

module Kc
  include Camping::Session
  PATH = File.expand_path(File.dirname(__FILE__)) + '/kc'
end

require 'kc/m'
require 'kc/c'
require 'kc/h'
require 'kc/v'

def Kc.create
  Kc::Models.create_schema
  ActiveRecord::Base.default_timezone = :utc

=begin
  ActiveRecord::Base.connection.execute("ALTER TABLE kc_users ADD COLUMN top_score_id INT")
  ActiveRecord::Base.connection.execute("ALTER TABLE kc_users ADD COLUMN latest_score_id INT")
  Kc::Models::User.find(:all).each do |u|
    u.top_score_id = u.scores.find(:first, :order => 'score DESC').id
    u.latest_score_id = u.scores.find(:first, :order => 'kc_scores.when DESC').id
    u.save
  end
=end
end

