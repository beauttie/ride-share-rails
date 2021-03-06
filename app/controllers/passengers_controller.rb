class PassengersController < ApplicationController
  def index
    @passengers = Passenger.all
  end

  def show
    @passenger = Passenger.find_by(id: params[:id])

    if @passenger.nil?
      redirect_to passengers_path
      return
    end
  end

  def new
    @passenger = Passenger.new
  end

  def create
    @passenger = Passenger.new(passenger_params)

    if @passenger.save
      redirect_to passenger_path(@passenger.id)
      return
    else
      render :new, status: :bad_request
      return
    end
  end

  def edit
    @passenger = Passenger.find_by(id: params[:id])

    if @passenger.nil?
      redirect_to passengers_path
      return
    end
  end

  def update
    @passenger = Passenger.find_by(id: params[:id])

    if @passenger.nil?
      head :not_found
      return
    elsif @passenger.update(passenger_params)
      redirect_to passenger_path(@passenger.id)
      return
    else # save failed :(
      render :edit, status: :bad_request
      return
    end
  end

  def destroy
    @passenger = Passenger.find_by(id: params[:id])

    if @passenger.nil?
      head :not_found
      return
    elsif @passenger.trips.empty?
      @passenger.destroy
      redirect_to passengers_path
      return
    else
      redirect_to passenger_path(@passenger.id)
      return
    end
  end

  private
  def passenger_params
    return params.require(:passenger).permit(:name, :phone_num)
  end
end
