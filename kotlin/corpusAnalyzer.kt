import java.io.File

fun loadCsv(filePath: String): List<String> {
    val corpus = mutableListOf<String>()
    val file = File(filePath)

    file.forEachLine { line ->
        if (!line.startsWith("tweet_id,")) {
            val columns = line.split(",(?=([^\"]*\"[^\"]*\")*[^\"]*$)".toRegex()) 
            if (columns.size > 3) { 
                val text = columns[3].trim()
                corpus.add(text.lowercase())
            }
        }
    }
    return corpus
}

fun wordCount(corpus: List<String>): Int {
    return corpus.sumOf { it.split("\\s+".toRegex()).size }
}

fun vocabularySize(corpus: List<String>): Int {
    return corpus.flatMap { it.split("\\s+".toRegex()) }
        .filter { it.isNotBlank() }
        .distinct()
        .size
}

fun wordFrequency(corpus: List<String>): Map<String, Int> {
    return corpus.flatMap { it.split("\\s+".toRegex()) }
        .filter { it.isNotBlank() } 
        .groupingBy { it }
        .eachCount()
        .toList()
        .sortedByDescending { (_, count) -> count }
        .toMap()
}

fun characterFrequency(corpus: List<String>): Map<Char, Int> {
    return corpus.flatMap { it.toList() }
        .groupingBy { it }
        .eachCount()
        .toList()
        .sortedByDescending { (_, count) -> count }
        .toMap()
}

fun identifyStopWords(wordFrequencies: Map<String, Int>, stopWords: Set<String>): Map<String, Int> {
    return wordFrequencies.filter { (word, _) -> stopWords.contains(word) }
}

fun showTopFrequentWords(wordFrequencies: Map<String, Int>, topN: Int = 20) {
    println("Top $topN Frequent Words:")
    wordFrequencies.entries.take(topN).forEach { (word, freq) ->
        println("$word: $freq")
    }
}

fun showTopFrequentCharacters(charFrequencies: Map<Char, Int>, topN: Int = 10) {
    println("Top $topN Frequent Characters:")
    charFrequencies.entries.take(topN).forEach { (char, freq) ->
        println("$char: $freq")
    }
}

fun main() {
    val csvFilePath = "fake_tweets.csv"
    val stopWordsFilePath = "stopwords.txt"

    val stopWords = setOf("although", "happen", "new", "none", "form", "something", "where", "try", "out", "medical")

    val corpus = loadCsv(csvFilePath)
    if (corpus.isEmpty()) {
        println("No data loaded from CSV. Exiting program.")
        return
    }
    println("Corpus loaded successfully. Total entries: ${corpus.size}")

    val wordFrequencies = wordFrequency(corpus)

    val wordsSortedByFrequency = wordFrequencies.entries
        .sortedByDescending { it.value } 
        .associate { it.toPair() } 

    val charFrequencies = characterFrequency(corpus)

    val charsSortedByFrequency = charFrequencies.entries
    .sortedByDescending { it.value } 
    .associate { it.toPair() }

    val totalWordCount = wordCount(corpus)
    val vocabSize = vocabularySize(corpus)
    val identifiedStopWords = identifyStopWords(wordFrequencies, stopWords)

    println("\nDescriptive Statistics:")
    println("Total Word Count: $totalWordCount")
    println("Vocabulary Size: $vocabSize")
    println("\nWord Frequency:")
    wordsSortedByFrequency.forEach { (word, count) ->
        println("$word: $count")
    }
    println("\nCharacter Frequency:")
    charsSortedByFrequency.forEach { (character, count) ->
        println("$character: $count")
    }
    
    println("\nFrequency Analysis:")
    showTopFrequentWords(wordsSortedByFrequency, 20)

    println("\nStop Word Identification:")
    identifiedStopWords.entries.take(10).forEach { (word, count) ->
        println("$word: $count")
    }

    
}
