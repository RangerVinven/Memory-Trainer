module Scorer
  class Standard
    def self.call(original, recall, type)
      return 0.0 if original.blank? || recall.blank?

      if type == 'number'
        score_numbers(original, recall)
      elsif type == 'card'
        score_cards(original, recall)
      else
        0.0
      end
    end

    def self.score_numbers(original, recall)
      # Sanitize
      orig = original.gsub(/[^0-9]/, '').chars
      rec = recall.gsub(/[^0-9]/, '').chars
      
      matches = 0
      orig.each_with_index do |char, i|
        matches += 1 if rec[i] == char
      end
      
      (matches.to_f / orig.length) * 100
    end

    def self.score_cards(original, recall)
      # format: "AS,KH,..."
      orig = original.split(',')
      # Users might separate by space or comma
      rec = recall.gsub(/[^a-zA-Z0-9]/, ' ').split
      
      matches = 0
      orig.each_with_index do |card, i|
        # Case insensitive compare
        matches += 1 if rec[i]&.upcase == card.upcase
      end
      
      (matches.to_f / orig.length) * 100
    end
  end
end
