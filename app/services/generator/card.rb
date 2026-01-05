module Generator
  class Card
    SUITS = %w[S H D C]
    RANKS = %w[2 3 4 5 6 7 8 9 10 J Q K A]
    
    def self.call(decks: 1)
      cards = []
      decks.times do
        SUITS.each do |s|
          RANKS.each do |r|
            cards << "#{r}#{s}"
          end
        end
      end
      cards.shuffle.join(',')
    end
  end
end
