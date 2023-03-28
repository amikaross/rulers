class Array
  def deeply_empty? 
    empty? || all?(&:empty?)
  end

  def present? 
    puts "this is a test"
  end
end