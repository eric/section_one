require_dependency 'section_one/scout_client'
require_dependency 'section_one/librato_metrics_client'

require 'hashie/mash'

class Service < ActiveRecord::Base
  attr_accessible :service_type, :settings
  serialize :settings, YAML

  validates_inclusion_of :service_type, :in => %w(scout librato)
  validate :validate_credentials

  def settings=(value)
    value = Hashie::Mash.new(value) unless value.is_a?(Hashie::Mash)
    write_attribute(:settings, value)
  end

  def settings
    value = read_attribute(:settings)
    value = YAML::load(value) if value.is_a?(String)
    value = Hashie::Mash.new(value) unless value.is_a?(Hashie::Mash)
    value
  end

  def client
    return nil unless settings

    creds = settings.with_indifferent_access

    @client ||= case service_type
    when 'scout'
      SectionOne::ScoutClient.new(creds)
    when 'librato'
      SectionOne::LibratoMetricsClient.new(creds)
    else
      nil
    end
  end

  def metrics
    return nil unless client

    client.metrics.tap do |metrics|
      metrics.each do |metric|
        metric.service = self
      end
    end
  end

  def values_for(identifier, duration, end_at = nil)
    return unless client

    end_at ||= Time.now
    start_at = end_at - duration

    client.values_for(identifier, start_at, end_at)
  end

  def validate_credentials
    if client && !client.valid?
      errors.add :base, 'Credentials are not valid.'
    end
  end
end
