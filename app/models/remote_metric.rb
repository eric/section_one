class RemoteMetric
  attr_reader   :service_type
  attr_accessor :name, :description, :units, :graph_url

  attr_accessor :service_identifier

  def initialize(service_type)
    @service_type = service_type
  end

  def as_json(*args)
    {
      :service_type       => service_type,
      :name               => name,
      :units              => units,
      :service_identifier => service_identifier
    }
  end
end