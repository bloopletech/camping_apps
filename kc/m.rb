module Kc::Models
  include KcModels

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
end