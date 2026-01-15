module Api
  module V1
    class PaoNumbersController < BaseController
      def index
        # Ensure 00-99 exists
        existing_numbers = current_user.pao_numbers.pluck(:number)
        missing_numbers = (0..99).to_a - existing_numbers
        
        if missing_numbers.any?
          pao_data = missing_numbers.map do |n|
            { user_id: current_user.id, number: n, created_at: Time.current, updated_at: Time.current }
          end
          PaoNumber.insert_all(pao_data)
        end

        @pao_numbers = current_user.pao_numbers.order(:number)
        render json: @pao_numbers
      end

      def digits
        # Ensure 0-9 exists
        existing_digits = current_user.pao_digits.pluck(:number)
        missing_digits = (0..9).to_a - existing_digits

        if missing_digits.any?
          digit_data = missing_digits.map do |n|
            { user_id: current_user.id, number: n, created_at: Time.current, updated_at: Time.current }
          end
          PaoDigit.insert_all(digit_data)
        end

        @pao_digits = current_user.pao_digits.order(:number)
        render json: @pao_digits
      end

      def bulk_update
        update_count = 0
        pao_params.each do |id, attributes|
          pao = current_user.pao_numbers.find_by(id: id)
          if pao && pao.update(attributes)
            update_count += 1
          end
        end
        
        render json: { message: "Updated #{update_count} entries" }, status: :ok
      end

      def bulk_update_digits
        update_count = 0
        digit_params.each do |id, attributes|
          digit = current_user.pao_digits.find_by(id: id)
          if digit && digit.update(attributes)
            update_count += 1
          end
        end
        
        render json: { message: "Updated #{update_count} digits" }, status: :ok
      end

      private

      def pao_params
        params.require(:pao_numbers).permit!
      end

      def digit_params
        params.require(:pao_digits).permit!
      end
    end
  end
end
