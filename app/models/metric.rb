class Metric < ActiveRecord::Base
  belongs_to :section
  belongs_to :service

  acts_as_list :scope => :section_id

  attr_accessible :name, :description, :units

  serialize :service_identifier, YAML

end
