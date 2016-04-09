#Implement all parts of this assignment within (this) module2_assignment2.rb file

class LineAnalyzer
  attr_reader :highest_wf_count, # a number with maximum number of occurrences for a single word (calculated)
              :highest_wf_words, # an array of words with the maximum number of occurrences (calculated)
              :content,          # the string analyzed (provided)
              :line_number       # the line number analyzed (provided)

  def initialize(line, line_number)
    @content = line
    @line_number = line_number
    calculate_word_frequency
  end
  
  def calculate_word_frequency
    content_array = content.split
    count_hash = Hash.new(0)
    content_array.each { |word| count_hash[word.downcase] += 1 }
    @highest_wf_count = count_hash.values.max
    @highest_wf_words = count_hash.select { |k, v| v == highest_wf_count}.keys
  end
end

class Solution

  attr_reader :analyzers, # an array of LineAnalyzer objects for each line in the file
              :highest_count_across_lines, # a number with the maximum value for highest_wf_words attribute in the analyzers array.
              :highest_count_words_across_lines # a filtered array of LineAnalyzer objects with the highest_wf_words attribute 
                                                # equal to the highest_count_across_lines determined previously.
  def initialize
    @analyzers = []
  end

  # processes 'test.txt' intro an array of LineAnalyzers and stores them in analyzers.
  def analyze_file
    @analyzers = [];
    File.foreach('test.txt') { |line, idx| @analyzers << LineAnalyzer.new(line, idx) }
  end

  # determines the highest_count_across_lines and highest_count_words_across_lines attribute values
  def calculate_line_with_highest_frequency
    @highest_count_across_lines = analyzers.max { |a, b| a.highest_wf_count - b.highest_wf_count }.highest_wf_count
    @highest_count_words_across_lines = analyzers.select { |a| a.highest_wf_count == highest_count_across_lines }
  end

  # prints the values of LineAnalyzer objects in highest_count_words_across_lines in the specified format
  def print_highest_word_frequency_across_lines(format)
    puts format
  end
  
end
