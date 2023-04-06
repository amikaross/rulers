require "sqlite3"
require "rulers/util"
require "multi_json"

DB = SQLite3::Database.new "test.db"

module Rulers
  module Model 
    class SQLite
      def self.json_field(*fields)
        @json_fields ||= []
        @json_fields.concat(fields.map(&:to_s))
      end

      def self.to_sql(key, val)
        if @json_fields.include?(key.to_s)
          return "'#{MultiJson.dump(val)}'"
        end
        case val
        when NilClass
          'null'
        when Numeric
          val.to_s
        when String
          "'#{val}'"
        else
          raise "Can't change #{val.class} to SQL!"
        end
      end

      def self.from_sql(key, val)
        if @json_fields.include?(key.to_s)
          return MultiJson.load(val)
        end
        val
      end

      def method_missing(name, *args)
        if @hash[name.to_s]
          self.class.class_eval do 
            define_method(name) do 
              self[name]
            end
          end
          return self.send(name)
        end

        if name.to_s[-1..-1] == "="
          col_name = name.to_s[0..-2]
          self.class.class_eval do 
            define_method(name) do |value|
              self[col_name] = value
            end
          end
          return self.send(name, args[0])
        end

        super
      end

      def initialize(data = nil)
        @hash = data
      end

      def save!
        fields = @hash.map do |k, v|
          "#{k}=#{self.class.to_sql(k, v)}"
        end.join(",")
        DB.execute <<~SQL
          UPDATE #{self.class.table}
          SET #{fields}
          WHERE id = #{@hash["id"]}
        SQL

        true
      end

      def save
        self.save! rescue false 
      end

      def self.create(values)
        values.delete "id"
        keys = schema.keys - ["id"]
        vals = keys.map do |key|
          values[key] ? to_sql(key, values[key]) : "null"
        end

        DB.execute <<~SQL
          INSERT INTO #{table} (#{keys.join(",")})
            VALUES (#{vals.join(",")});
        SQL

        raw_vals = keys.map { |k| values[k] }
        data = Hash[keys.zip(raw_vals)]
        sql = "SELECT last_insert_rowid();"
        data["id"] = DB.execute(sql)[0][0]
        self.new(data)
      end

      def self.count
        sql = <<~SQL
          SELECT COUNT(*) FROM #{table};
        SQL
        DB.execute(sql)[0][0]
      end

      def self.table
        Rulers.to_underscore(name)
      end

      def self.schema
        return @schema if @schema 
        @schema = {}
        DB.table_info(table) do |row|
          @schema[row["name"]] = row["type"]
        end
        @schema
      end

      def self.all
        rows = DB.execute <<~SQL
          select * from #{table};
        SQL
        rows.map do |row|
          self.new(Hash[schema.keys.zip(row)])
        end
      end

      def self.find(id)
        row = DB.execute <<~SQL
          select #{schema.keys.join(",")} from #{table}
          where id = #{id};
        SQL

        data = Hash[schema.keys.zip(row[0])]
        data.each do |k, v|
          data[k] = from_sql(k, v)
        end
        self.new(data)
      end

      def [](name)
        @hash[name.to_s]
      end

      def []=(name, value)
        @hash[name.to_s] = value
      end
    end
  end
end