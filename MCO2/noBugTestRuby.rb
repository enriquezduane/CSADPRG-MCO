#********************
#Last names: Chua
#Language: Ruby
#Paradigm(s): Procedural Programming
#********************


require 'csv'
require 'date'
require 'gruff'  # For visualization

class TweetAnalyzer
  def initialize(file_path)
    @tweets = load_data(file_path)
    @word_frequencies = {}
    @char_frequencies = {}
    @stop_words = Set.new(["although", "happen", "new", "none", "form", "something", "where", "try", "out", "medical"])
  end

  def load_data(file_path)
    CSV.read(file_path, headers: true)
  end

  def word_count
    return @total_word_count if @total_word_count
    @total_word_count = @tweets.sum do |tweet| 
      clean_text(tweet['text']).split.size 
    end
  end

  def vocabulary_size
    @tweets.flat_map do |tweet| 
      clean_text(tweet['text']).split  
    end.uniq.size
  end

  def clean_text(text)
    text = text.downcase
    text = text.gsub(/http\S+\s*/, '')
    text = text.gsub(/@user\d+/, '')
    text = text.gsub(/#\w+/, '')
    text = text.gsub(/[\u{1F300}-\u{1F9FF}]/, '')
    text = text.gsub(/[[:punct:]]/, ' ')
    text = text.gsub(/[[:digit:]]/, ' ')
    text = text.squeeze(' ').strip

    text
  end

  def calculate_word_frequencies
    @word_frequencies = Hash.new(0)
    @tweets.each do |tweet|
      words = clean_text(tweet['text']).split
      words.each { |word| @word_frequencies[word] += 1 }
    end
    @word_frequencies.sort_by { |_, count| -count }.to_h
  end

  def calculate_char_frequencies
    @char_frequencies = Hash.new(0)
    @tweets.each do |tweet|
      tweet['text'].each_char { |char| @char_frequencies[char] += 1 }
    end
    @char_frequencies.sort_by { |_, count| -count }.to_h
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
    @char_frequencies = calculate_char_frequencies if @char_frequencies.empty?
    symbols = @char_frequencies.select do |char, _| 
      char.match?(/[[:space:]]/) || # spaces and whitespace
      char.match?(/[[:punct:]]/) || # punctuation
      char.match?(/[^\x00-\x7F]/) || # emojis and other non-ASCII characters
      (!char.match?(/[[:alnum:]]/)) # anything that's not alphanumeric
    end
    symbols.sort_by { |_, count| -count }.to_h
  end

  def generate_word_cloud
    g = Gruff::Pie.new(800)
    g.title = 'Top 20 Words Word Cloud'
    
    top_20_words.each do |word, count|
      g.data(word, count)
    end
    
    g.write('word_cloud.png')
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
    
    symbols_distribution.each do |symbol, count|
      g.data(symbol, count)
    end
    
    g.write('symbols_distribution.png')
  end

  def analyze_corpus
    puts "Corpus Analysis Results:"
    puts "----------------------"
    puts "Total Word Count: #{word_count}"
    puts "Vocabulary Size: #{vocabulary_size}"
    puts "\nTop 20 Most Frequent Words:"
    top_20_words.each { |word, count| puts "#{word}: #{count}" }
    puts "\nMost Common Symbols:"
    symbols_distribution.first(20).each { |symbol, count| puts "#{symbol.inspect}: #{count}" }
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
