library(tidyverse)
library(wordcloud)
library(tm)
library(stringr)
library(lubridate)
library(ggplot2)
library(scales)

# read and process tweets
read_tweets <- function() {
    tweets <- read.csv("src/data/fake_tweets.csv", stringsAsFactors = FALSE)
    tweets$date_created <- as.POSIXct(tweets$date_created, format="%Y-%m-%d %H:%M:%S")
    return(tweets)
}

clean_text <- function(text) {
    # set to lowercase
    text <- tolower(text)
    # remove extra whitespace
    text <- str_squish(text)
    # Remove multiple consecutive dots (ellipsis)
    text <- gsub("\\.{2,}", " ", text)
    # Handle single dots
    text <- gsub("\\.", " ", text)
    # Handle emojis
    text <- iconv(text, "UTF-8", "ASCII", sub="")

    return(text)
}

# corpus analysis
analyze_corpus <- function(tweets) {
    # clean all tweets
    clean_tweets <- map_chr(tweets$text, clean_text)
    
    # create a corpus
    corpus <- Corpus(VectorSource(clean_tweets))
    
    # get word frequencies (from cleaned tweets)
    tdm <- TermDocumentMatrix(corpus)
    word_freq <- rowSums(as.matrix(tdm))
    sorted_word_freq <- sort(word_freq, decreasing = TRUE)
    
    # calculate statistics
    total_words <- sum(word_freq)
    vocab_size <- length(word_freq)
    top_20_words <- head(sorted_word_freq, 20)
    
    # pre-defined stop words (as per instructions ni sir)
    common_stop_words <- c("although", "happen", "new", "none", "form", "something", "where", "try", "out", "medical")
    stop_words_freq <- word_freq[names(word_freq) %in% common_stop_words]
    stop_words_freq <- sort(stop_words_freq, decreasing = TRUE)
    
    # character frequency (including original text for symbols)
    all_text <- paste(tweets$text, collapse = " ")
    char_freq <- table(strsplit(all_text, "")[[1]])
    sorted_char_freq <- sort(char_freq, decreasing = TRUE)
    
    # get symbols
    symbols <- sorted_char_freq[!names(sorted_char_freq) %in% c(letters, LETTERS, as.character(0:9), " ")]
    
    return(list(
        total_words = total_words,
        sorted_word_freq = sorted_word_freq,
        vocab_size = vocab_size,
        top_20_words = top_20_words,
        stop_words = stop_words_freq,
        char_freq = sorted_char_freq,
        symbols = symbols
    ))
}

# function to create visualizations
create_visualizations <- function(tweets, analysis) {
    # word cloud
    png("src/wordcloud.png", width=800, height=600)
    wordcloud(words = names(analysis$top_20_words),
             freq = analysis$top_20_words,
             min.freq = 1,
             scale=c(3,0.5),
             colors=brewer.pal(8, "Dark2"))
    dev.off()
    
    # monthly posts histogram
    monthly_posts <- tweets %>%
        mutate(month = floor_date(date_created, "month")) %>%
        count(month)
    
    ggplot(monthly_posts, aes(x = month, y = n)) +
        geom_bar(stat = "identity", fill = "steelblue") +
        theme_minimal() +
        labs(title = "Posts per Month",
             x = "Month",
             y = "Number of Posts") +
        theme(axis.text.x = element_text(angle = 45, hjust = 1))
    ggsave("src/monthly_posts.png")
    
    # symbols pie chart
    symbols_df <- data.frame(
        symbol = names(analysis$symbols),
        freq = as.numeric(analysis$symbols)
    ) %>%
    filter(freq > 0)  # only include symbols that actually appear
    
    ggplot(symbols_df, aes(x = "", y = freq, fill = symbol)) +
        geom_bar(stat = "identity", width = 1) +
        coord_polar("y", start = 0) +
        theme_void() +
        labs(title = "Symbol Distribution") +
        theme(legend.position = "right")
    ggsave("src/symbols_pie.png")
}

main <- function() {
    # read data
    tweets <- read_tweets()
    
    # perform analysis
    analysis <- analyze_corpus(tweets)
    
    # print results
    cat("Total Words:", analysis$total_words, "\n")
    cat("Vocabulary Size:", analysis$vocab_size, "\n")
    cat("\nWord Frequencies:\n")
    print(analysis$sorted_word_freq)
    cat("\nCharacter Frequencies:\n")
    print(analysis$char_freq)
    cat("\nTop 20 Most Frequent Words:\n")
    print(analysis$top_20_words)
    cat("\nTop 10 Stop Words:\n")
    print(analysis$stop_words)
    
    # create visualizations
    create_visualizations(tweets, analysis)
}

main()
