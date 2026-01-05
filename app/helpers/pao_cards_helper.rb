module PaoCardsHelper
  def format_pao_card(pao)
    rank_map = {
      "ace" => "A", "two" => "2", "three" => "3", "four" => "4", "five" => "5",
      "six" => "6", "seven" => "7", "eight" => "8", "nine" => "9", "ten" => "10",
      "jack" => "J", "queen" => "Q", "king" => "K"
    }
    
    suit_map = {
      "spades" => "♠", "hearts" => "♥", "diamonds" => "♦", "clubs" => "♣"
    }
    
    r = rank_map[pao.rank] || pao.rank.titleize
    s = suit_map[pao.suit] || pao.suit.titleize
    
    color = (pao.suit == "hearts" || pao.suit == "diamonds") ? "#dc2626" : "#1e293b"
    
    tag.span("#{r}#{s}", style: "font-weight: bold; color: #{color}; font-size: 1.1rem;")
  end
end