module Blog::Models
  class CreateTheBasics < V 1.0
    def self.up
      create_table :blog_admins, :force => true do |table|
        table.string :name, :password
      end
      print "Password for #{user = ENV['USER']}? "
      Admin.create :name => user, :password => $stdin.gets.chomp
      
      create_table :blog_posts, :force => true do |table|
        table.string :title, :tags, :nickname
        table.text :body
        table.timestamps
      end
      
      create_table :blog_comments, :force => true do |table|
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
  end
  
  class Comment < Base
    validates_presence_of :username
    validates_length_of :body, :within => 1..3000
    validates_inclusion_of :bot, :in => %w(K)
    validates_associated :post
    belongs_to :post
    attr_accessor :bot
  end
end