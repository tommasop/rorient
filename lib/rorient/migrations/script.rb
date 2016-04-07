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
                                script: statements(@type) 
                              }
                ]
            }
          puts my_migration
          driver.batch.execute(my_migration)
        rescue
          puts "[-] Error while executing #{@type} #{@name} !"
          puts "    Info: #{self}"
          raise
        else
          true & on_success
        end
      end

      def unexecute(db)
        @type = "rollback"
        puts " ---------------> #{db} #{@type} "
        @database = db
        return false if new?
        driver = @database.driver
        begin
           my_rollback = { transaction: false,
                operations: [
                              {
                                type: "script",
                                language: "sql",
                                script: statements(@type) 
                              }
                ]
            }
          puts my_rollback
          driver.batch.execute(my_migration)
        rescue
          puts "[-] Error while executing rollback #{@name} !"
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

      def statements(statement_type=nil)
        separator = Rorient::Migrations::Config.options[:separator]
        if separator
          statements = @content.split(separator)
          statements.collect!(&:strip)
          statements.reject(&:empty?)
          if (statements & ["--#{statement_type}", "--end-#{statement_type}"]).any?
            begin_at = statements.index("--#{statement_type}")+1
            end_at = m_statements.index("--end-#{statement_type}")-1
            statements[begin_at..end_at] 
          else
            statements
          end
        else
          [content]
        end
      end

      def to_s
        "#{@type.capitalize} `#{@path}` for `#{@file.database}` database"
      end

      private

      def new?
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
        
        case @type 
        when "migration"
          puts "[+] Migrating history table"
          @database.connected_db.document.create("@class": @database.history.to_s, time: @datetime, name: @name,
                                               type: @type, executed: Time.now.to_s) if @type == "migration"
        when "rollback"
          puts "[+] Rolling back history table"
          migration_record = @database.connected_db.query.execute(query_text: URI.encode("SELECT FROM #{@database.history} WHERE type = '" + @type + "' AND time = '" + @time + "' LIMIT 1"))[:result].first
          @database.connected_db.document.delete(rid: migration_record["@rid"]) if migration_record 
        end
      end
    end
  end
end
