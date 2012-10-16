class Section < ActiveRecord::Base
  belongs_to :dashboard
  has_many :metrics, :order => 'metrics.position'
  
  acts_as_list :scope => [ :dashboard_id, :column ]
  
  attr_accessible :name, :column, :position
  
end
