module Api
  module V1
    class LociController < BaseController
      before_action :set_memory_palace
      before_action :set_locus, only: [:update, :destroy, :sort]

      def create
        @locus = @memory_palace.loci.build(locus_params)
        if @locus.save
          render json: @locus, status: :created
        else
          render json: { error: @locus.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @locus.update(locus_params)
          render json: @locus
        else
          render json: { error: @locus.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @locus.destroy
        head :no_content
      end

      def sort
        if params[:position]
          @locus.insert_at(params[:position].to_i)
          head :ok
        else
          render json: { error: "Position required" }, status: :unprocessable_entity
        end
      end

      private

      def set_memory_palace
        @memory_palace = current_user.memory_palaces.find(params[:memory_palace_id])
      end

      def set_locus
        @locus = @memory_palace.loci.find(params[:id])
      end

      def locus_params
        params.require(:locus).permit(:name, :description, :information)
      end
    end
  end
end
