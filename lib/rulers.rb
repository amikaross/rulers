# frozen_string_literal: true

require "rulers/version"
require "rulers/array"
require "rulers/routing"

module Rulers
  class Application
    def call(env)
      if env['PATH_INFO'] == '/favicon.ico'
        return [404, {'Content-Type' => 'text/html'}, []]
      end
      if env['PATH_INFO'] == '/'
        klass, act = get_controller_and_action({"PATH_INFO" => "/quotes/a_quote"})
      else
        klass, act = get_controller_and_action(env)
      end
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

  class Controller 
    def initialize(env)
      @env = env
    end

    def env
      @env 
    end
  end
end
