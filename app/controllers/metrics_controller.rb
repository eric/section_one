require_dependency 'serious'

class MetricsController < ApplicationController
  before_filter :find_section, :except => :index

  def index
    @metrics = Service.all.map do |service|
      Serious.future(service) do |service|
        service.metrics
      end
    end

    @metrics = @metrics.map do |service|
      Serious.demand(service)
    end

    @metrics = @metrics.flatten.compact
    @metrics = @metrics.sort_by { |m| m.name }
  end

  def new
    @metrics = Service.all.map do |service|
      Serious.future(service) do |service|
        service.metrics
      end
    end

    @metrics = @metrics.map do |service|
      Serious.demand(service)
    end

    @metrics = @metrics.flatten.compact.sort_by { |m| m.name }

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @metrics }
    end
  end

  def create
    metric = @section.metrics.build_from_template(JSON.parse(params[:metric_attributes]))

    unless metric.save
      flash[:error] = 'Could not add metric'
    end

    redirect_to dashboard_section_path(@section.dashboard, @section)
  end

  def find_section
    @section = Section.find(params[:section_id])
    @dashboard = @section.dashboard
  end
end
