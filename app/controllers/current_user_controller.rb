class CurrentUserController < ApplicationController
  before_action :authenticate_user!
  def index
    users = User.all
    render json: users, status: :ok
  end

  def show
    user = User.find_by(id: params[:id])
    if user
      render json: user, status: :ok
    else
      render json: { error: "User not found" }, status: :not_found
    end
  end

  def index_current_user
    render json: current_user, status: :ok
  end
end
