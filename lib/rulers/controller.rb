require 'erubis'
require "rulers/file_model"

module Rulers
  class Controller 
    include Rulers::Model
    
    def initialize(env)
      @env = env
    end
  
    def env
      @env 
    end

    def controller_name
      klass = self.class
      klass = klass.to_s.gsub(/Controller$/, "")
      Rulers.to_underscore(klass)
    end
  
    def render(view_name, locals = {})
      filename = File.join("app", "views", controller_name, "#{view_name}.html.erb")
      template = File.read(filename)
      eruby = Erubis::Eruby.new(template)

      instance_variables.each do |var|
        locals[var] = instance_variable_get(var)
      end

      result = eruby.result(locals)
    end
  end
end
