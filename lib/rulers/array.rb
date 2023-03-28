class Array
  def deeply_empty? 
    empty? || all?(&:empty?)
  end

  def present?(val) 
    include?(val)
  end
end