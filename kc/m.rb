module Kc::Models
  class Score < Base
    belongs_to :user

    after_save :update_high_scores

    def update_high_scores
      hs = user.scores.find(:all, :order => "kc_scores.when DESC", :limit => 100)

      user.update_attributes(:high_score => hs.empty? ? 0 : ((hs.inject(0) { |sum, val| sum + val.score }) / hs.length.to_f).round, :latest_score => self, :top_score => user.scores.find(:first, :order => 'score DESC'), :total_scores => user.scores.count)
    end
  end
  class Shout < Base
    validates_presence_of :username
    validates_presence_of :text

    attr_accessor :captcha

    def validate
      errors.add(:captcha, 'was entered incorrectly') unless captcha.downcase == 'captcha'
    end
  end
  class User < Base
    has_many :scores
    belongs_to :top_score, :class_name => 'Score'
    belongs_to :latest_score, :class_name => 'Score'
#    has_many :users, :as => 'friends'

    has_image(false, 'avatar')

    def highest_score
      scores.find(:first, :order => 'score DESC')
    end

    def lowest_score
      scores.find(:first, :order => 'score ASC')
    end

    def most_recent_score
      scores.find(:first, :order => 'kc_scores.when DESC')
    end
  end

  class CreateKc < V 6
    def self.up
      create_table "kc_scores", :force => false do |t|
        t.integer  "version", "user_id", "score"
        t.datetime "when"
        t.string   "source"
      end

      create_table "kc_shouts", :force => false do |t|
        t.string   "username", "text"
        t.datetime "posted"
      end

      create_table "kc_users", :force => false do |t|
        t.string  "name", "crypt"
        t.integer "high_score"
        t.integer :view_count, :default => 0
        t.boolean :seen_site_changes_12_2008, :default => false
        t.datetime :scores_when, :default => nil
        t.integer :top_score_id
        t.integer :latest_score_id
        t.integer :total_scores
        t.boolean "has_avatar", :default => false
      end
    end
  end

  class AddSeenOzQuizReleased < V 7
    def self.up
      add_column :kc_users, :seen_oz_quiz_released, :boolean, :default => false
    end
  end

  class FixUrlEscaping < V 8
    def self.up
      require 'cgi'

      Kc::Models::User.find(:all).each do |u|
        next if u.name.nil? || u.crypt.nil?
        u.name = CGI.unescape(u.name).gsub(/ +/, ' ')
        u.crypt = CGI.unescape(u.crypt).gsub(/ +/, ' ')
        u.save!
      end
    end
  end
end