# frozen_string_literal: true

require "rulers/version"
require "rulers/array"
require "rulers/routing"
require "rulers/util"
require "rulers/dependencies"
require "rulers/controller"

module Rulers
  class Application
    def call(env)
      if env['PATH_INFO'] == '/favicon.ico'
        return [404, 
          {'Content-Type' => 'text/html'}, []]
      end

      if env['PATH_INFO'] == '/'
        return [200, 
          {'Content-Type' => 'text/html'}, 
          [File.read("public/index.html")]]
      end 

      klass, act = get_controller_and_action(env)
      controller = klass.new(env)

      begin 
        text = controller.send(act)
      rescue RuntimeError
        [500, {'Content-Type' => 'text/html'},
        ["Oh no! There's been a runtime error!"]]
      else
        [200, {'Content-Type' => 'text/html'},
        [text]]
      end 
    end
  end
end