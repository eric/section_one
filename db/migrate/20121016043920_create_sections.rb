class CreateSections < ActiveRecord::Migration
  def change
    create_table :sections do |t|
      t.string :name
      t.belongs_to :dashboard
      
      t.integer :column, :default => 1
      t.integer :position
    end
  end
end
