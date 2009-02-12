require 'lib/acts-as-taggable-on/init'

module Watchlist::Models
  include ActsAsTaggableModels
  Base.send :include, ActiveRecord::Acts::TaggableOn
  Base.send :include, ActiveRecord::Acts::Tagger
=begin
  EmailAddress = begin
    qtext = '[^\\x0d\\x22\\x5c\\x80-\\xff]'
    dtext = '[^\\x0d\\x5b-\\x5d\\x80-\\xff]'
    atom = '[^\\x00-\\x20\\x22\\x28\\x29\\x2c\\x2e\\x3a-' +
      '\\x3c\\x3e\\x40\\x5b-\\x5d\\x7f-\\xff]+'
    quoted_pair = '\\x5c[\\x00-\\x7f]'
    domain_literal = "\\x5b(?:#{dtext}|#{quoted_pair})*\\x5d"
    quoted_string = "\\x22(?:#{qtext}|#{quoted_pair})*\\x22"
    domain_ref = atom
    sub_domain = "(?:#{domain_ref}|#{domain_literal})"
    word = "(?:#{atom}|#{quoted_string})"
    domain = "#{sub_domain}(?:\\x2e#{sub_domain})*"
    local_part = "#{word}(?:\\x2e#{word})*"
    addr_spec = "#{local_part}\\x40#{domain}"
    pattern = /\A#{addr_spec}\z/
  end
=end
  class User < Base
    has_many :items
    has_many :titles, :through => :items
    validates_uniqueness_of :name
    validates_length_of :password, :minimum => 5
#    validates_format_of :email, :with => Watchlist::Models::EmailAddress

    has_many :messages_recieved, :class_name => 'Message', :foreign_key => 'recipient_id'
    has_many :messages_sent, :class_name => 'Message', :foreign_key => 'sender_id'

    def find_users_who_like_same_titles
      self.class.find_by_sql("SELECT watchlist_users.*, subq.n_common_titles FROM (SELECT wi2.user_id, COUNT(wi2.title_id) AS n_common_titles FROM watchlist_items wi2, (SELECT title_id FROM watchlist_items wi1, watchlist_users wu WHERE wu.id = #{id} AND wu.id = wi1.user_id) s WHERE wi2.title_id = s.title_id AND wi2.user_id != #{id} GROUP BY wi2.user_id ORDER BY COUNT(wi2.title_id) DESC) AS subq LEFT JOIN watchlist_users ON watchlist_users.id=subq.user_id")
#        SELECT DISTINCT watchlist_users.* FROM watchlist_items LEFT JOIN watchlist_users ON watchlist_users.id=watchlist_items.user_id WHERE watchlist_users.id != #{id} AND title_id IN (SELECT watchlist_items.title_id FROM watchlist_items WHERE watchlist_items.user_id=#{id})")
#      self.class.find_by_sql("SELECT DISTINCT watchlist_users.* FROM watchlist_items LEFT JOIN watchlist_users ON watchlist_users.id=watchlist_items.user_id WHERE watchlist_users.id != #{id} AND title_id IN (SELECT watchlist_items.title_id FROM watchlist_items WHERE watchlist_items.user_id=#{id})")
    end
  end

  class Medium < Base
    has_many :items
  end

  class Title < Base
    #has_and_belongs_to_many :users
    has_many :items
    belongs_to :medium
    has_and_belongs_to_many :related_titles, :join_table => 'watchlist_related_titles', :foreign_key => 'title_id', :association_foreign_key => 'related_title_id', :class_name => 'Title'
    has_and_belongs_to_many :related_titles_reversed, :join_table => 'watchlist_related_titles', :foreign_key => 'related_title_id', :association_foreign_key => 'title_id', :class_name => 'Title'

    %w(english romaji japanese).each do |t|
      module_eval <<-EOF
        def title_#{t}
          (title_#{t}_main.nil? or title_#{t}_main.blank?) ? nil : (title_#{t}_main + ((title_#{t}_suffix.nil? or title_#{t}_suffix.blank?) ? '' : " (\#{title_#{t}_suffix})"))
        end
      EOF
    end
  
    def title
      [title_romaji, title_english, title_japanese].detect { |t| !t.nil? and !t.blank? }
    end

    def titles
      [title_romaji, title_english, title_japanese].select { |t| !t.nil? and !t.blank? }.uniq.join(" / ")
    end

    def title_main=(t)
      self[:title_romaji_main] = t
      self[:title_english_main] = t
      self[:title_japanese_main] = t
    end

    def title_suffix=(t)
      self[:title_romaji_suffix] = t
      self[:title_english_suffix] = t
      self[:title_japanese_suffix] = t
    end

    def self.find_all_by_title(t, exact = true)
      t = if exact
        ActiveRecord::Base.connection.quote(t)
      else
        ActiveRecord::Base.connection.quote("%#{t}%")
      end

      find(:all, :select => 'DISTINCT *', :conditions => "title_english_main LIKE #{t} OR title_romaji_main LIKE #{t} OR title_japanese_main LIKE #{t}", :order => 'title_romaji_main, title_english_main, title_japanese_main')
    end

    def self.has_title_any(titles)
      titles = titles.split(' / ')
      titles.detect { |t| !find_all_by_title(t).empty? }
    end

    acts_as_taggable_on :genres
  end

  class Item < Base
    belongs_to :user
    belongs_to :title
  end

  class Message < Base
    belongs_to :sender, :class_name => 'User', :foreign_key => 'sender_id'
    belongs_to :recipient, :class_name => 'User', :foreign_key => 'recipient_id'
  end

  class CreateWatchlist < V 1
    def self.up
      create_table :watchlist_media do |t|
        t.string :name
        t.datetime :created_at, :updated_at
      end

      Medium.create(:name => 'anime')
      Medium.create(:name => 'manga')
      Medium.create(:name => 'OST')

      create_table :watchlist_titles do |t|
        t.integer :medium_id
        t.string :title_english_main
        t.string :title_romaji_main
        t.string :title_japanese_main
        t.string :title_english_suffix
        t.string :title_romaji_suffix
        t.string :title_japanese_suffix
        t.integer :ann_id
        t.integer :anidb_id
        t.string :first_source
        t.datetime :created_at, :updated_at
      end

      add_index :watchlist_titles, :title_english_main
      add_index :watchlist_titles, :title_romaji_main
      add_index :watchlist_titles, :title_japanese_main

      create_table :watchlist_items do |t|
        t.integer :user_id
        t.integer :title_id
        t.string :consumed
        t.datetime :created_at, :updated_at
      end

      create_table :watchlist_users do |t|
        t.string :name
        t.string :password
        t.string :email
        t.datetime :created_at, :updated_at
      end

      create_table(:watchlist_related_titles, :id => false) do |t|
        t.integer :title_id
        t.integer :related_title_id
      end

      create_table :watchlist_messages do |t|
        t.integer :sender_id
        t.integer :recipient_id
        t.text :message
        t.datetime :created_at, :updated_at
      end


      create_table :watchlist_tags do |t|
        t.column :name, :string
      end

      create_table :watchlist_taggings do |t|
        t.column :tag_id, :integer
        t.column :taggable_id, :integer
        t.column :tagger_id, :integer
        t.column :tagger_type, :string

        # You should make sure that the column created is
        # long enough to store the required class names.
        t.column :taggable_type, :string
        t.column :context, :string

        t.column :created_at, :datetime
      end

      add_index :watchlist_taggings, :tag_id, :name => "index_wtlt_taggings_on_tag_id"
      add_index :watchlist_taggings, [:taggable_id, :taggable_type, :context], :name => "index_wtlt_taggings_on_tid_ttype_ctext"
    end
  end
end