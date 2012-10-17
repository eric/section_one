class Metric < ActiveRecord::Base
  belongs_to :section
  belongs_to :service

  acts_as_list :scope => :section_id

  attr_accessible :name, :description, :units, :graph_url,
    :service_identifier, :service_id

  serialize :service_identifier, YAML

  TEMPLATE_COLUMNS = %w(name description units graph_url
    service_identifier service_id)

  def self.build_from_template(template)
    data = template.with_indifferent_access.slice(*TEMPLATE_COLUMNS)

    new do |m|
      data.each do |name, value|
        m[name] = value
      end
    end
  end

  def values(duration = nil, end_at = nil)
    duration ||= 1.hour
    end_at     = 1.minutes.ago

    service.values_for(service_identifier, duration, end_at)
  end
end
