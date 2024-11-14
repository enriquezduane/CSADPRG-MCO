#********************
#Last names: Chua
#Language: Ruby
#Paradigm(s): Procedural Programming
#********************

require 'csv'
require 'date'
require 'gruff'  # For visualization
require 'magic_cloud' # for word cloud

class TweetAnalyzer
  def initialize(file_path)
    @tweets = load_data(file_path)
    @word_frequencies = {}
    @char_frequencies = Hash.new(0)  
    @stop_words = Set.new(["although", "happen", "new", "none", "form", "something", "where", "try", "out", "medical"])
    calculate_char_frequencies  
  end

  def load_data(file_path)
    CSV.read(file_path, headers: true)
  end

  def word_count
    return @total_word_count if @total_word_count
    @total_word_count = @tweets.sum do |tweet|
      clean_and_split_text(tweet['text']).size
    end
  end

  def vocabulary_size
    @tweets.flat_map do |tweet|
      clean_and_split_text(tweet['text'])
    end.uniq.size
  end

  def clean_text(text)
    text.downcase.squeeze(' ').strip
  end

  def clean_and_split_text(text)
    return [] unless text  # Handle nil text
    text.split.map do |word|
      # Remove hashtag symbol if present
      word = word.start_with?('#') ? word[1..-1] : word
      # Additional cleaning
      word.downcase.gsub(/[^a-z0-9\s]/, '')
    end.reject(&:empty?)
  end

  def calculate_word_frequencies
    @word_frequencies = Hash.new(0)
    @tweets.each do |tweet|
      words = clean_and_split_text(tweet['text'])
      words.each { |word| @word_frequencies[word] += 1 }
    end
    @word_frequencies.sort_by { |_, count| -count }.to_h
  end

  def calculate_char_frequencies
    @char_frequencies.clear  
    @tweets.each do |tweet|
      next unless tweet['text']  
      tweet['text'].each_char do |char|
        @char_frequencies[char] += 1
      end
    end
    
    # Sort by frequency in descending order
    @char_frequencies = @char_frequencies.sort_by { |_, count| -count }.to_h
  end

  def top_20_words
    calculate_word_frequencies.first(20)
  end

  def common_stop_words
    calculate_word_frequencies
      .select { |word, _| @stop_words.include?(word) }
      .first(10)
      .map { |word, count| { word: word, count: count } }
  end

  def posts_by_month
    monthly_counts = Hash.new(0)
    @tweets.each do |tweet|
      date = DateTime.parse(tweet['date_created'])
      month_key = "#{date.year}-#{date.month.to_s.rjust(2, '0')}"
      monthly_counts[month_key] += 1
    end
    monthly_counts.sort.to_h
  end

  def symbols_distribution
    symbols = @char_frequencies.select do |char, _|
      char.match?(/[[:space:]]/) ||
      char.match?(/[[:punct:]]/) || 
      char.match?(/[^\x00-\x7F]/) || 
      char.match?(/[^[:alnum:]]/)    
    end
 
    symbols.sort_by { |_, count| -count }.to_h
  end

  def generate_monthly_posts_chart
    g = Gruff::Bar.new(800)
    g.title = 'Posts per Month'
    
    monthly_data = posts_by_month
    g.labels = monthly_data.keys.each_with_index.to_h
    g.data('Posts', monthly_data.values)
    
    g.write('monthly_posts.png')
  end

  def generate_symbols_chart
    g = Gruff::Pie.new(800)
    g.title = 'Symbol Distribution'
    
    # Take top 10 symbols for better readability
    symbols_distribution.first(10).each do |symbol, count|
      label = symbol.match?(/[[:space:]]/) ? "SPACE" : symbol.inspect
      g.data(label, count)
    end
    
    g.write('symbols_distribution.png')
  end

  def generate_word_cloud
    # Convert word frequencies to the expected format [word, count]
    word_data = top_20_words.map { |word, count| [word, count] }
    
    cloud = MagicCloud::Cloud.new(
      word_data,
      rotate: :free,
      scale: :log  
    )
    
    img = cloud.draw(800, 600) 
    img.write('word_cloud.png')
  end

  def print_char_frequencies
    puts "\nCharacter Frequency Distribution:"
    puts "--------------------------------"
    @char_frequencies.first(20).each do |char, count|
      if char.match?(/[[:space:]]/)
        puts "SPACE: #{count}"
      else
        puts "#{char.inspect}: #{count}"
      end
    end
  end

  def analyze_corpus
    puts "Corpus Analysis Results:"
    puts "----------------------"
    puts "Total Word Count: #{word_count}"
    puts "Vocabulary Size: #{vocabulary_size}"
    puts "\nTop 20 Most Frequent Words:"
    top_20_words.each { |word, count| puts "#{word}: #{count}" }
    print_char_frequencies
    puts "\nMost Common Symbols:"
    symbols_distribution.first(20).each { |symbol, count| 
      if symbol.match?(/[[:space:]]/)
        puts "SPACE: #{count}"
      else
        puts "#{symbol.inspect}: #{count}"
      end
    }
    
    puts "\nCommon Stop Words Identified:"
    common_stop_words.each { |item| puts "#{item[:word]}: #{item[:count]}" }
    
    # Generate visualizations
    generate_word_cloud
    generate_monthly_posts_chart
    generate_symbols_chart
    
    puts "\nVisualizations have been generated:"
    puts "- word_cloud.png"
    puts "- monthly_posts.png"
    puts "- symbols_distribution.png"
  end
end

if __FILE__ == $0
  analyzer = TweetAnalyzer.new('Fake Tweets.csv')
  analyzer.analyze_corpus
end
