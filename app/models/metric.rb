class Metric < ActiveRecord::Base
  belongs_to :section
  belongs_to :service

  acts_as_list :scope => :section_id

  attr_accessible :name, :description, :units, :graph_url,
    :service_identifier, :service

  serialize :service_identifier, YAML

  def values(duration = nil, end_at = nil)
    duration ||= 1.hour
    end_at     = Time.now

    service.values_for(service_identefier, duration, end_at)
  end
end
