class PaoNumbersController < ApplicationController
  before_action :authenticate_user!

  def index
    # 00-99 Logic
    existing_numbers = current_user.pao_numbers.pluck(:number)
    missing_numbers = (0..99).to_a - existing_numbers
    
    if missing_numbers.any?
      pao_data = missing_numbers.map do |n|
        { user_id: current_user.id, number: n, created_at: Time.current, updated_at: Time.current }
      end
      PaoNumber.insert_all(pao_data)
    end

    @pao_numbers = current_user.pao_numbers.order(:number)

    # 0-9 Logic
    existing_digits = current_user.pao_digits.pluck(:number)
    missing_digits = (0..9).to_a - existing_digits

    if missing_digits.any?
      digit_data = missing_digits.map do |n|
        { user_id: current_user.id, number: n, created_at: Time.current, updated_at: Time.current }
      end
      PaoDigit.insert_all(digit_data)
    end

    @pao_digits = current_user.pao_digits.order(:number)
  end

  def bulk_update
    update_count = 0
    params[:pao_numbers].each do |id, attributes|
      pao = current_user.pao_numbers.find_by(id: id)
      if pao && pao.update(attributes)
        update_count += 1
      end
    end
    
    respond_to do |format|
      format.html { redirect_to pao_numbers_path, notice: "Updated #{update_count} entries." }
      format.turbo_stream { render turbo_stream: turbo_stream.replace("flash", partial: "layouts/flash") } # Naive implementation
    end
  end
end
