require_dependency 'serious'

class MetricsController < ApplicationController
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
end
