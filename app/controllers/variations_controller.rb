class VariationsController < ApplicationController
  before_action :redirect_to_default_range, only: [:index]

  def index
    @date = params[:date] ? Time.zone.parse(params[:date]) : Time.zone.now
    @variations =
      if params[:range] == 'this-month'
        @current_user.variations.from_this_month(@date)
      else
        @current_user.variations.from_today(@date)
      end
  end

  def new
  end

  def create
    variation = Variation.new(params.require(:variation).permit(:value, :user_id, :base, :recurring, :label))
    authorize variation

    if variation.save
      redirect_to(variation.recurring || variation.base ? variations_range_url(range: 'this-month') : variations_range_url(range: 'today'))
    else
      redirect_back fallback_location: root_url, flash: { error: "An unexpected error occured."}
    end
  end

  def edit
    @variation = Variation.find(params[:id])
    authorize @variation
  end

  def update
    variation = Variation.find(params[:id])
    variation.assign_attributes(params.require(:variation).permit(:value, :user_id, :base, :recurring, :label))
    authorize variation

    if variation.save
      redirect_to(variation.recurring || variation.base ? variations_range_url(range: 'this-month') : variations_range_url(range: 'today'))
    else
      redirect_back fallback_location: root_url, flash: { error: "An unexpected error occured."}
    end
  end

  def destroy
    variation = Variation.find(params[:id])
    authorize variation
    variation.destroy

    redirect_to(variation.recurring || variation.base ? variations_range_url(range: 'this-month') : variations_range_url(range: 'today'))
  end

  protected

  def redirect_to_default_range
    redirect_to variations_range_url(range: "today") if params[:range].blank?
  end
end
