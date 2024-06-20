class EventsController < ApplicationController
  before_action :authenticate_request
  before_action :set_event, only: %i[ show update destroy ]

  # GET /events/events
  def index
    @events = @current_user.events
    render json: @events
  end

  # GET /events/event/:id
  def show
    render json: @event
  end

  # POST /events/create
  def create
    @event = @current_user.events.build(event_params)
    @event.user_id = @current_user.id 

    if @event.save
      render json: @event, status: :created
    else
      render json: @event.errors, status: :unprocessable_entity
    end
  end

  # PUT /events/update/:id
  def update
    if @event.user_id == @current_user.id
      if @event.update(event_params)
        render json: @event
      else
        render json: @event.errors, status: :unprocessable_entity
      end
    else
      render json: { errors: 'No Autorizado' }, status: :forbidden  
    end  
  end

  # DELETE /events/delete/:id
  def destroy
    if @event.user_id == @current_user.id 
      @event.destroy!
      head :no_content
    else
      render json: { errors: 'No Autorizado' }, status: :forbidden
    end  
  end

  private
    def set_event
      @event = Event.find(params[:id])
    end

    def event_params
      params.require(:event).permit(:name, :description, :event_date, :location, :capacity)
    end
end
