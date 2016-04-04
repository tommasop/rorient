module Rorient 
  module Migrations
    # Class that represents database gem will connect to
    #
    class Database
      HISTORY_TABLE = :rorientmigrations_schema
      attr_reader :name, :driver

      def initialize(name, options)
        @name    = name
        @server = options[:server]
        begin
          @driver = self.class.connect(options)
        rescue
          puts "[-] Could not connect to `#{@name}` database using #{@adapter} adapter"
          raise
        else
          puts "[+] Connected to `#{@name}` database using #{@adapter} adapter"
        end
        install_table
      end

      def migrate
        migrations = Rorient::Migrations::Migration.find(@name)
        if !migrations.empty?
          puts "[i] Executing migrations for `#{@name}` database"
          migrations.each { |migration| migration.execute(self) }
        else
          puts "[i] No migrations for `#{@name}` database"
        end
      end

      def seed
        seeds = Rorient::Migration::Seed.find(@name)
        if !seeds.empty?
          puts "[i] Seeding `#{@name}` database"
          seeds.each { |seed| seed.execute(self) }
        else
          puts "[i] No seeds for `#{@name}` database"
        end
      end

      def history
        @driver.query.execute(query_text: URI.encode("SELECT FROM #{HISTORY_TABLE}"))
      end

      private

      def self.connect(options)
        Rorient.connect(
                         server: options[:host],
                         user: options[:username],
                         password: options[:password],
                         db_name: options[:database]
        )
      end

      def install_table
        return if @driver.table_exists?(HISTORY_TABLE)

        puts "[!] Installing `#{HISTORY_TABLE}` history table"
        @driver.batch.execute( Oj.load('{ "transaction" : true,
                                 "operations" : [
                                   {
                                     "type" : "script",
                                     "language" : "sql",
                                     "script" : [ "CREATE CLASS #{HISTORY_TABLE.to_s}",
                                                  "CREATE PROPERTY #{HISTORY_TABLE.to_s}.time DOUBLE",
                                                  "CREATE PROPERTY #{HISTORY_TABLE.to_s}.executed DATETIME",
                                                  "CREATE PROPERTY #{HISTORY_TABLE.to_s}.name STRING",
                                                  "CREATE PROPERTY #{HISTORY_TABLE.to_s}.type STRING",
                                                  "CREATE INDEX ON #{HISTORY_TABLE.to_s} (name, type)" ]
                                   }
                                 ]
                               }')
                             )
        end
      end
    end
  end
end
