class Object
  def self.const_missing(c)
    return nil if @calling_const_get

    @calling_const_get = true 
    require Rulers.to_underscore(c.to_s)
    klass = Object.const_get(c)
    @calling_const_get = false 

    klass
  end
end