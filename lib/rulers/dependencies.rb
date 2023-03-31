class Object
  def self.const_missing(c)
    @calling_const_get ||= {}
    return nil if @calling_const_get[c]

    @calling_const_get[c] = true 
    require Rulers.to_underscore(c.to_s)
    klass = Object.const_get(c)
    @calling_const_get[c] = false 

    klass
  end
end

