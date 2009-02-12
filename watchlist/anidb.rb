require 'zlib'

module AniDb
  module_function
  def pull_in_titles
    #doc = Hpricot(Zlib::GzipReader.new(StringIO.new(Net::HTTP.get(URI.parse("http://anidb.net/api/animetitles.xml.gz")))).read)
    doc = Hpricot(File.new('watchlist/anidb.xml').read)
    
    (doc/:animetitles/:anime).each do |anime|
      title_japanese_main = title_romaji_main = title_english_main = ""
      aid = anime.attributes['aid']

      (anime/:title).each do |title|
        if title.attributes['type'] == 'official' and title.attributes['xml:lang'] == 'ja'
          title_japanese_main = title.inner_text.strip
        elsif title.attributes['type'] == 'official' and title.attributes['xml:lang'] == 'en'
          title_english_main = title.inner_text
        elsif title.attributes['type'] == 'main' and title.attributes['xml:lang'] == 'x-jat'
          title_romaji_main = title.inner_text
        end
      end

      next unless [title_japanese_main, title_english_main, title_romaji_main].detect { |t| !t.blank? }

      existing_title = Watchlist::Models::Title.find_by_anidb_id(aid)
      if existing_title.nil?
        [title_romaji_main, title_japanese_main, title_english_main].select { |t| !t.blank? }.each do |title|
          existing_titles = Watchlist::Models::Title.find_all_by_title(title).select { |t| t.medium_id == 1 }
          if !existing_titles.empty?
            if existing_titles.length > 1
              t = [title_romaji_main, title_english_main, title_japanese_main].detect { |t| !t.nil? and !t.blank? }
              existing_title = TitlesCommon.multiple_titles_picker(title, 'anime', "http://anidb.net/perl-bin/animedb.pl?show=anime&aid=#{aid}", existing_titles)
              next if existing_titles.nil?
              existing_title = nil if existing_title == :add
            else
              existing_title = existing_titles.first
            end
            break
          end
        end
      end
      
      if !existing_title.nil?
        existing_title.anidb_id = aid
        ['romaji', 'english', 'japanese'].each do |t|
          t_value = eval("title_#{t}_main")
          existing_title.send("title_#{t}_main=", t_value) unless t_value.blank? or !existing_title.send("title_#{t}_main").blank?
        end
        #puts "Updating existing title #{existing_title.title}"
        existing_title.save!
      else
        title = Watchlist::Models::Title.create(:title_english_main => title_english_main, :title_english_suffix => "anime",
         :title_romaji_main => title_romaji_main, :title_romaji_suffix => "anime", :title_japanese_main => title_japanese_main,
          :title_japanese_suffix => "アニメ", :anidb_id => aid, :medium_id => 1, :first_source => "AniDB")
        #puts "Creating #{title.title}"
      end
    end
  end
end