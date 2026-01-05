module CardHelper
  def render_card(card_code)
    # card_code is like "KH" (King of Hearts), "10S" (10 of Spades)
    rank = card_code[0..-2]
    suit = card_code[-1]

    suit_icon = case suit
                when 'H' then '♥'
                when 'D' then '♦'
                when 'S' then '♠'
                when 'C' then '♣'
                end

    color = (suit == 'H' || suit == 'D') ? '#d9534f' : '#292b2c'
    
    # SVG Representation
    svg = <<~SVG
      <svg width="100" height="140" viewBox="0 0 100 140" xmlns="http://www.w3.org/2000/svg" style="background: white; border-radius: 8px; box-shadow: 2px 2px 5px rgba(0,0,0,0.2); border: 1px solid #ccc; display: inline-block; margin: 5px;">
        <!-- Border -->
        <rect x="2" y="2" width="96" height="136" rx="6" fill="none" stroke="#{color}" stroke-width="2"/>
        
        <!-- Top Left -->
        <text x="8" y="20" font-family="Arial, sans-serif" font-size="16" font-weight="bold" fill="#{color}">#{rank}</text>
        <text x="8" y="38" font-family="Arial, sans-serif" font-size="16" fill="#{color}">#{suit_icon}</text>

        <!-- Center -->
        <text x="50" y="80" font-family="Arial, sans-serif" font-size="40" text-anchor="middle" dominant-baseline="central" fill="#{color}">#{suit_icon}</text>

        <!-- Bottom Right (Rotated) -->
        <g transform="rotate(180, 92, 120)">
          <text x="92" y="120" font-family="Arial, sans-serif" font-size="16" font-weight="bold" fill="#{color}">#{rank}</text>
          <text x="92" y="138" font-family="Arial, sans-serif" font-size="16" fill="#{color}">#{suit_icon}</text>
        </g>
      </svg>
    SVG

    svg.html_safe
  end
end
