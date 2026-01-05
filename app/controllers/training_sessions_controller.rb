class TrainingSessionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_session, only: [:show, :update]

  def index
    @sessions = current_user.training_sessions.order(created_at: :desc)
  end

  def new
    @session = TrainingSession.new
  end

  def create
    type = params[:training_session][:training_type]
    
    # Logic for Count/Length
    count = params[:training_session][:item_count].to_i
    count = 20 if count <= 0

    # Logic for Batch Size (How many to show at once)
    batch_size = params[:training_session][:batch_size].to_i
    batch_size = 1 if batch_size <= 0

    data = if type == 'number'
      Generator::Number.call(length: count)
    else
      # For cards, item_count is treated as "Number of Cards" approx (or decks)
      # Let's simplify: if user asks for 52 cards, that's 1 deck. 
      # The generator takes 'decks'.
      decks = (count / 52.0).ceil
      decks = 1 if decks < 1
      Generator::Card.call(decks: decks).split(',').first(count).join(',')
    end

    @session = current_user.training_sessions.build(
      training_type: type,
      item_count: count,
      batch_size: batch_size,
      training_data: data,
      status: :memorizing
    )

    if @session.save
      redirect_to @session
    else
      render :new
    end
  end

  def show
  end

  def update
    if @session.memorizing?
      duration = params[:duration].to_i
      @session.update(status: :recalling, duration_seconds: duration)
      redirect_to @session
    elsif @session.recalling?
      recall = params[:training_session][:recall_data]
      score = Scorer::Standard.call(@session.training_data, recall, @session.training_type)
      
      @session.update(
        status: :completed,
        recall_data: recall,
        accuracy_percentage: score,
        completed_at: Time.current
      )
      redirect_to @session
    end
  end

  private
  def set_session
    @session = current_user.training_sessions.find(params[:id])
  end
end
