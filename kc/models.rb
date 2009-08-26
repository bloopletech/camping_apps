module KcModels
  def self.included(other_module)
    other_module.module_eval <<-EOF
      class Score < Base
        belongs_to :user

        after_save :update_high_scores

        def update_high_scores
          hs = user.scores.find(:all, :order => "\#{self.table_name}.when DESC", :limit => 100)

          user.update_attributes(:high_score => hs.empty? ? 0 : ((hs.inject(0) { |sum, val| sum + val.score }) / hs.length.to_f).round, :latest_score_id => self.id, :top_score_id => user.scores.find(:first, :order => 'score DESC').id, :total_scores => user.scores.count)
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
          scores.find(:first, :order => '\#{self.table_name}.when DESC')
        end
      end
    EOF
  end
end