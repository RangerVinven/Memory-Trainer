class PaoNumbersController < ApplicationController
  before_action :authenticate_user!

  def index
    existing_numbers = current_user.pao_numbers.pluck(:number)
    missing_numbers = (0..99).to_a - existing_numbers
    
    if missing_numbers.any?
      pao_data = missing_numbers.map do |n|
        { user_id: current_user.id, number: n, created_at: Time.current, updated_at: Time.current }
      end
      PaoNumber.insert_all(pao_data)
    end

    @pao_numbers = current_user.pao_numbers.order(:number)
  end

  def bulk_update
    update_count = 0
    pao_params.each do |id, attributes|
      pao = current_user.pao_numbers.find_by(id: id)
      if pao && pao.update(attributes)
        update_count += 1
      end
    end
    
    redirect_to pao_numbers_path, notice: "Updated #{update_count} entries."
  end

  private

  def pao_params
    params.require(:pao_numbers).permit!
  end
end