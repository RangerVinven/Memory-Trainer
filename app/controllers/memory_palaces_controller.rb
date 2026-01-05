class MemoryPalacesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_memory_palace, only: [:show, :edit, :update, :destroy]

  def index
    @memory_palaces = current_user.memory_palaces
  end

  def show
    @locus = Locus.new
  end

  def new
    @memory_palace = current_user.memory_palaces.build
  end

  def create
    @memory_palace = current_user.memory_palaces.build(memory_palace_params)
    if @memory_palace.save
      redirect_to @memory_palace, notice: 'Memory palace was successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @memory_palace.update(memory_palace_params)
      redirect_to @memory_palace, notice: 'Memory palace was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @memory_palace.destroy
    redirect_to memory_palaces_url, notice: 'Memory palace was successfully destroyed.'
  end

  private

  def set_memory_palace
    @memory_palace = current_user.memory_palaces.find(params[:id])
  end

  def memory_palace_params
    params.require(:memory_palace).permit(:name, :description)
  end
end