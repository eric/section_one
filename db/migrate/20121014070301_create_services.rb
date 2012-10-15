class CreateServices < ActiveRecord::Migration
  def change
    create_table :services do |t|
      t.string :service_type
      t.string :settings, :limit => 4096
    end
  end
end
