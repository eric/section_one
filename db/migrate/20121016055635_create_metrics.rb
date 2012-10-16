# attr_reader   :service_type
# attr_accessor :name, :description, :units, :url
# 
# attr_accessor :service_identifier

class CreateMetrics < ActiveRecord::Migration
  def change
    create_table :metrics do |t|
      t.string :name, :null => false
      t.string :description
      t.string :units
      t.string :graph_url
      t.string :service_identifier, :limit => 1024
      
      t.belongs_to :service
      t.belongs_to :section
      t.integer :position
    end
  end
end
