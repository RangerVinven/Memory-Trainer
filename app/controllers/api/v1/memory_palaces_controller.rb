module Api
  module V1
    class MemoryPalacesController < BaseController
      before_action :set_memory_palace, only: [:show, :update, :destroy]

      def index
        @memory_palaces = current_user.memory_palaces.order(created_at: :desc)
        render json: @memory_palaces.as_json(include: :loci)
      end

      def show
        render json: @memory_palace.as_json(include: :loci)
      end

      def create
        @memory_palace = current_user.memory_palaces.build(memory_palace_params)
        if @memory_palace.save
          render json: @memory_palace, status: :created
        else
          render json: { error: @memory_palace.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @memory_palace.update(memory_palace_params)
          render json: @memory_palace
        else
          render json: { error: @memory_palace.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @memory_palace.destroy
        head :no_content
      end

      private

      def set_memory_palace
        @memory_palace = current_user.memory_palaces.find(params[:id])
      end

      def memory_palace_params
        params.require(:memory_palace).permit(:name, :description)
      end
    end
  end
end
