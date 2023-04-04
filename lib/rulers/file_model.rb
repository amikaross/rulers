require "multi_json"

module Rulers
  module Model 
    class FileModel 
      def self.all 
        files = Dir["db/quotes/*.json"]
        files.map { |f| FileModel.new(f) }
      end

      def self.method_missing(method, *args)
        if method.to_s =~ /find_all_by_(\w+)/
          attribute = method.to_s.split("_")[-1]
          return find_all_by_attribute(attribute, args[0])
        else
          super
        end
      end

      def self.respond_to_missing(method, *)
        method =~ /find_all_by_(\w+)/ || super
      end

      def self.find_all_by_attribute(attribute, value)
        id = 1
        results = []
        m = FileModel.find(id)
        while !m.nil? do 
          results.push(m) if m[attribute] == value
          id += 1
          m = FileModel.find(id)
        end
        results
      end

      def self.create(attrs)
        hash = {}
        hash["submitter"] = attrs["submitter"] || ""
        hash["quote"] = attrs["quote"] || ""
        hash["attribution"] = attrs["attribution"] || ""

        files = Dir["db/quotes/*.json"]
        names = files.map { |f| File.split(f)[-1] }
        highest = names.map { |b| b.to_i }.max
        id = highest + 1 

        File.open("db/quotes/#{id}.json", "w") do |f|
          f.write <<-TEMPLATE 
            {
              "submitter": "#{hash["submitter"]}",
              "quote": "#{hash["quote"]}",
              "attribution": "#{hash["attribution"]}"
            }
            TEMPLATE
        end

        FileModel.new("db/quotes/#{id}.json")
      end

      def initialize(filename)
        @filename = filename 

        # If filename is "dir/37/json", @id is 37
        basename = File.split(filename)[-1]
        @id = File.basename(basename, ".json").to_i

        obj = File.read(filename)
        @hash = MultiJson.load(obj)
      end

      def [](name)
        @hash[name.to_s]
      end

      def []=(name, value)
        @hash[name.to_s] = value
      end

      def save
        File.open(@filename, "w") do |f|
          f.write <<-TEMPLATE
          {
            "submitter": "#{@hash["submitter"]}",
            "quote": "#{@hash["quote"]}",
            "attribution": "#{@hash["attribution"]}
          }
          TEMPLATE
        end
      end

      def self.find(id)
        id = id.to_i
        @dm_style_cache ||= {}
        begin
          if @dm_style_cache[id]
            return @dm_style_cache[id]
          end
          m = FileModel.new("db/quotes/#{id}.json")
          @dm_style_cache[id] = m 
          m
        rescue
          return nil 
        end 
      end
    end
  end
end