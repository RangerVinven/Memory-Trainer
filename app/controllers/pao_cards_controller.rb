class PaoCardsController < ApplicationController
  before_action :authenticate_user!

  def index
    # Ensure 52 cards exist
    if current_user.pao_cards.count < 52
      required_cards = []
      PaoCard.suits.each do |suit_name, suit_val|
        PaoCard.ranks.each do |rank_name, rank_val|
          required_cards << [suit_val, rank_val]
        end
      end

      existing_cards = current_user.pao_cards.pluck(:suit, :rank)
      missing_cards = required_cards - existing_cards

      if missing_cards.any?
        pao_data = missing_cards.map do |suit, rank|
          { user_id: current_user.id, suit: suit, rank: rank, created_at: Time.current, updated_at: Time.current }
        end
        PaoCard.insert_all(pao_data)
      end
    end

    @pao_cards = current_user.pao_cards.order(:suit, :rank)
  end

  def bulk_update
    update_count = 0
    pao_params.each do |id, attributes|
      pao = current_user.pao_cards.find_by(id: id)
      if pao && pao.update(attributes)
        update_count += 1
      end
    end
    
    redirect_to pao_cards_path, notice: "Updated #{update_count} entries."
  end

  private

  def pao_params
    params.require(:pao_cards).permit!
  end
end