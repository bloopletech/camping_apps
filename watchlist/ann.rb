module ANN
  module_function
  def pull_in_titles
    doc = Hpricot(File.new('watchlist/ann.html'), :fixup_tags => true)
    animecount = mangacount = foundcount = 0
    ((doc/:table)[7]/:a).each do |a|
      a.attributes['href'] =~ /^\/encyclopedia\/(anime|manga)\.php\?id=(\d+)$/
      next unless $1
      anime_or_manga = $1
      id = $2
      a.inner_text =~ /^(.*?) \((.*?)\)$/
      title = $1
      type = $2
      name_type = (a.parent.name.downcase == 'i' ? 'romaji' : 'english')

      type = 'anime' if type == 'TV'

      next if title.blank?

      if anime_or_manga == 'anime'
        medium = 1
        animecount += 1
      elsif anime_or_manga == 'manga'
        medium = 2
        mangacount += 1
      end
      
      title = TitlesCommon.massage_title(title)

      existing_title = Watchlist::Models::Title.find_by_ann_id(id)
      if existing_title.nil?
        existing_titles = Watchlist::Models::Title.find_all_by_title(title).select { |t| t.send("title_#{name_type}_suffix") == type }
        if !existing_titles.empty?
          if existing_titles.length > 1
            existing_title = TitlesCommon.multiple_titles_picker(title, type, "http://www.animenewsnetwork.com/encyclopedia/anime.php?id=#{id}", existing_titles)
            next if existing_titles.nil?
            existing_title = nil if existing_title == :add
          else
            existing_title = existing_titles.first
          end
        else
          existing_titles = Watchlist::Models::Title.find_all_by_title(title).select { |t| t.medium_id == medium }
          if !existing_titles.empty?
            if existing_titles.length > 1
              existing_title = TitlesCommon.multiple_titles_picker(title, type, "http://www.animenewsnetwork.com/encyclopedia/anime.php?id=#{id}", existing_titles)
              next if existing_titles.nil?
              existing_title = nil if existing_title == :add
            else
              existing_title = existing_titles.first
            end
          end
        end
      end
      
      if !existing_title.nil?
        #puts "Updating existing title #{existing_title.title}"
        existing_title.ann_id = id
        existing_title.send("title_#{name_type}_main=", title) unless !existing_title.send("title_#{name_type}_main").blank?
        existing_title.send("title_#{name_type}_suffix=", type) unless existing_title.send("title_#{name_type}_suffix") != 'manga' && existing_title.send("title_#{name_type}_suffix") != 'anime'
        existing_title.save!
      else
        #puts "Creating #{title} (#{type})"
        t = Watchlist::Models::Title.new(:title_english_suffix => type, :title_romaji_suffix => type, :ann_id => id, :medium_id => medium, :first_source => "ANN")
        t.send("title_#{name_type}_main=", title)
        t.save!
      end
    end

    puts "anime count: #{animecount}, manga count: #{mangacount}, found count: #{foundcount}"
  end
end