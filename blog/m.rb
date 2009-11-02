module Blog::Models
  class CreateTheBasics < V 1.0
    def self.up
      create_table :blog_admins do |table|
        table.string :name, :password
      end
      print "Password for #{user = ENV['USER']}? "
      Admin.create :name => user, :password => $stdin.gets.chomp
      
      create_table :blog_posts do |table|
        table.string :title, :tags, :nickname
        table.text :body
        table.timestamps
      end
      
      create_table :blog_comments do |table|
        table.integer :post_id
        table.string :username
        table.text :body
        table.datetime :created_at
      end
    end
  end
  
  class Admin < Base; end
  
  class Post < Base
    has_many :comments, :order => 'created_at ASC', :dependent => :destroy
    validates_presence_of :title, :nickname
    validates_uniqueness_of :nickname
    named_scope :published, :conditions => "published_at <= NOW()"
  end
  
  class Comment < Base
    validates_presence_of :username
    validates_length_of :body, :within => 1..3000
    validates_inclusion_of :bot, :in => %w(K)
    validates_associated :post
    belongs_to :post
    attr_accessor :bot
  end

  class AddPublishedAt < V 1.1
    def self.up
      add_column :blog_posts, :published_at, :datetime
      Blog::Models::Post.all.each { |p| p.update_attribute(:published_at, p.created_at) }
    end
  end
end