class PaoDigitsController < ApplicationController
  before_action :authenticate_user!

  def bulk_update
    update_count = 0
    pao_params = params.require(:pao_digits).permit!
    
    pao_params.each do |id, attributes|
      pao = current_user.pao_digits.find_by(id: id)
      if pao && pao.update(attributes)
        update_count += 1
      end
    end
    
    respond_to do |format|
      format.html { redirect_to pao_numbers_path, notice: "Digits updated." }
      format.turbo_stream { render turbo_stream: turbo_stream.replace("flash", partial: "layouts/flash") }
    end
  end
end