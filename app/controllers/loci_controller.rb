class LociController < ApplicationController
  before_action :authenticate_user!
  before_action :set_memory_palace

  def create
    @locus = @memory_palace.loci.build(locus_params)
    if @locus.save
      redirect_to @memory_palace, notice: 'Locus added.'
    else
      redirect_to @memory_palace, alert: 'Could not add locus.'
    end
  end

  def destroy
    @locus = @memory_palace.loci.find(params[:id])
    @locus.destroy
    redirect_to @memory_palace, notice: 'Locus removed.'
  end

  def move
    @locus = @memory_palace.loci.find(params[:id])
    @locus.insert_at(params[:position].to_i)
    head :ok
  end

  private

  def set_memory_palace
    @memory_palace = current_user.memory_palaces.find(params[:memory_palace_id])
  end

  def locus_params
    params.require(:locus).permit(:name, :description)
  end
end