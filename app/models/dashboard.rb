class Dashboard < ActiveRecord::Base
  has_many :sections, :order => 'sections.column, sections.position' do
    def column(num)
      where(:column => num)
    end
  end

  attr_accessible :name

end
