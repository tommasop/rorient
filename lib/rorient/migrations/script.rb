require 'find'
require 'benchmark'
require 'time'

module Rorient
  module Migrations
    # Script class
    class Script
      DELEGATED = [:name, :date, :time, :datetime, :type, :content, :path]
      attr_reader(*DELEGATED)

      def initialize(file)
        @file = file

        DELEGATED.each do |method|
          instance_variable_set("@#{method}", file.send(method))
        end
      end

      def execute(db)
        @database = db
        return false unless new?
        driver = @database.driver
        begin
           my_migration = { transaction: false,
                operations: [
                              {
                                type: "script",
                                language: "sql",
                                script: self.send("#{@type}_statements") 
                              }
                ]
            }
          driver.batch.execute(my_migration)
        rescue
          puts "[-] Error while executing #{@type} #{@name} !"
          puts "    Info: #{self}"
          raise
        else
          true & on_success
        end
      end

      def self.find(database, type)
        files = []

        Find.find(Dir.pwd) do |path|
          file = Rorient::Migrations::File.new(path, database, type)

          raise "Duplicate time for #{type}s: #{files.find { |f| f == file }}, #{file}" if
          file.valid? && files.include?(file)

          files << file if file.valid?
        end

        files.sort_by(&:datetime).map { |file| new(file) }
      end

      def migration_statements
        m_statements = statements
        if (m_statements & ["--UP", "--DOWN"]).any?
          begin_at = m_statements.index("--UP")+1
          end_at = m_statements.index("--DOWN")-1
          m_statements[begin_at..end_at] 
        else
          statements
        end
      end
      
      def rollback_statements
        r_statements = statements
        if r_statements.include?("--DOWN")
          begin_at = r_statements.index("--DOWN")+1
          r_statements[begin_at..-1] 
        end
      end

      def statements
        separator = Rorient::Migrations::Config.options[:separator]
        if separator
          statements = @content.split(separator)
          statements.collect!(&:strip)
          statements.reject(&:empty?)
        else
          [content]
        end
      end

      def to_s
        "#{@type.capitalize} `#{@path}` for `#{@file.database}` database"
      end

      private

      def new?
        puts @database
        history = @database.history
        # If migrations table is empty
        if @database.connected_db.query.execute(query_text: URI.encode("SELECT NULL FROM #{history} LIMIT 1"))[:result].nil?
          true
        else
          last = @database.connected_db.query.execute(query_text: URI.encode("SELECT FROM #{history} WHERE type = #{@type} ORDER BY time DESC LIMIT 1"))[:result].last
          is_new = @database.connected_db.query.execute(query_text: URI.encode("SELECT FROM #{history} WHERE type = #{@type}"))[:result].count == 0
          puts "[!] #{self} datetime BEFORE last one executed !" if
          is_new && last && last[:time] > @datetime

          is_new
        end
      end

      def on_success
        puts "[+] Successfully executed #{@type}, name: #{@name}"
        puts "    Info: #{self}"
        puts "    Benchmark: #{@benchmark}"

        @database.connected_db.document.create("@class": @database.history.to_s, time: @datetime, name: @name,
                                               type: @type, executed: Time.now.to_s)
      end
    end
  end
end
