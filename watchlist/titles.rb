require 'hpricot'

module TitlesCommon
  module_function
  def multiple_titles_picker(from_title, from_type, from_url, existing_titles)
    puts "For #{from_title} (#{from_type}), #{from_url}, more than one existing title matches:"
    existing_titles.each_with_index { |et, i| puts "#{i + 1}. #{et.title}" }
    loop do
      puts "Do [i]nfo num, [p]ick num, [a]dd as new item, i[g]nore. ?"
      cmd, *args = gets.split(' ')
      case cmd
      when "i"
        next if args.nil? or args.empty?
        title_infoed = existing_titles[args.first.to_i - 1]
        sections = ["Info for ##{args.first}:\nAll titles: #{title_infoed.titles}"]
        sections << "AniDB url: http://anidb.net/perl-bin/animedb.pl?show=anime&aid=#{title_infoed.anidb_id}" unless title_infoed.anidb_id.nil?
        sections << "ANN url: http://www.animenewsnetwork.com/encyclopedia/anime.php?id=#{title_infoed.ann_id}" unless title_infoed.ann_id.nil?
        sections << "First source: #{title_infoed.first_source}"
        puts sections.join("\n")
      when "p"
        next if args.nil? or args.empty?
        return existing_titles[args.first.to_i - 1]
      when "a"
        puts "Adding as new item"
        return :add
      when "g"
        puts "Ignoring"
        return nil
      end
    end
  end

  def massage_title(title)
    title.gsub('`', "'").gsub(/^\(The\)/, "The").gsub(/$^(.*?), The$/, "The \\1")
  end
end

require 'watchlist/ann'
require 'watchlist/anidb'
require 'levenshtein'

puts "Starting import..."

#ActiveRecord::Base.logger = Logger.new(STDOUT)

%w(AniDb ANN).each do |mod|
  puts "Importing from #{mod}"
  mod.constantize.pull_in_titles
  puts "Imported #{mod}"
end

postponed = []
titles = Watchlist::Models::Title.find(:all, :conditions => "title_english_main IS NOT NULL OR title_romaji_main IS NOT NULL")
titles.each do |t|
  similars = titles.select { |t2| (t.id != t2.id) && (t.medium_id == t2.medium_id) &&
   ((t.title_romaji_main.blank? || t2.title_romaji_main.blank? ? false : ((t.title_romaji_main != t2.title_romaji_main) && (Levenshtein.normalized_distance(t.title_romaji_main, t2.title_romaji_main) <= 0.1))) ||
    (t.title_english_main.blank? || t2.title_english_main.blank? ? false : ((t.title_english_main != t2.title_english_main) && (Levenshtein.normalized_distance(t.title_english_main, t2.title_english_main) <= 0.1)))) }
  unless similars.empty?
    puts "These titles are similar:"
    all_titles = ([t] + similars)
    all_titles.each_with_index { |t, i| puts "#{i + 1}. #{t.titles}" }
    loop do
      puts "Do [i]nfo num, [m]erge fromnum intonum, [p]ostpone, i[g]nore. ?"
      cmd, *args = gets.split(' ')
      next if cmd.nil? or cmd.empty?
      case cmd
      when "i"
        next if args.nil? or args.empty? or args.first.to_i < 1 or args.first.to_i > all_titles.length
        title_infoed = all_titles[args.first.to_i - 1]
        sections = ["Info for ##{args.first}:\nAll titles: #{title_infoed.titles}"]
        sections << "AniDB url: http://anidb.net/perl-bin/animedb.pl?show=anime&aid=#{title_infoed.anidb_id}" unless title_infoed.anidb_id.nil?
        sections << "ANN url: http://www.animenewsnetwork.com/encyclopedia/anime.php?id=#{title_infoed.ann_id}" unless title_infoed.ann_id.nil?
        sections << "First source: #{title_infoed.first_source}"
        puts sections.join("\n")
      when "m"
        next if args.nil? or args.length != 2 or !(1..all_titles.length).include?(args.first.to_i) or !(1..all_titles.length).include?(args.last.to_i)
        from = all_titles[args.first.to_i - 1]
        to = all_titles[args.second.to_i - 1]
        to.title_romaji_main = [to.title_romaji_main, from.title_romaji_main].detect { |t| !t.blank? }
        to.title_english_main = [to.title_english_main, from.title_english_main].detect { |t| !t.blank? }
        to.title_japanese_main = [to.title_japanese_main, from.title_japanese_main].detect { |t| !t.blank? }
        to.anidb_id = [to.anidb_id, from.anidb_id].detect { |id| !id.nil? and id != 0 }
        to.ann_id = [to.ann_id, from.ann_id].detect { |id| !id.nil? and id != 0 }
        to.title_romaji_suffix = (to.title_romaji_suffix != (to.medium_id == 1 ? 'anime' : 'manga') ? to.title_romaji_suffix : from.title_romaji_suffix)
        to.title_english_suffix = (to.title_english_suffix != (to.medium_id == 1 ? 'anime' : 'manga') ? to.title_english_suffix : from.title_english_suffix)
        to.title_japanese_suffix = (to.title_japanese_suffix != (to.medium_id == 1 ? 'anime' : 'manga') ? to.title_japanese_suffix : from.title_japanese_suffix)
        to.save!
        Watchlist::Models::Base.connection.execute("UPDATE watchlist_items SET title_id=#{to.id} WHERE title_id=#{from.id}")
        puts "Merged #{from.title} -> #{to.title}"
        from.destroy
        break
      when "p"
        postponed << all_titles
        puts "Postponed"
        break
      when "g"
        puts "Ignoring"
        break
      end
    end   
  end
end