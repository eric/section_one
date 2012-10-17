module MetricsHelper
  def display_last_value(values)
    unless value = values.last
      return
    end

    number_with_precision(value, :precision => 2, :delimiter => ',', :strip_insignificant_zeros => true)
  end
end
