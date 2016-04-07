module Rorient 
  module Migrations
    # Class that represents database gem will connect to
    #
    class Database
      HISTORY_TABLE = :rorient_migrations_schema
      attr_reader :name, :driver

      def initialize(name, options)
        @name    = name
        begin
          @driver = self.class.connect(options)
        rescue
          puts "[-] Could not connect to `#{@name}` database using rorient adapter"
          raise
        else
          puts "[+] Connected to `#{@name}` database using rorient adapter"
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

      def rollback(steps:0)
        steps -= 1 if steps != 0
        rollbacks = Rorient::Migrations::Migration.find(@name)
        puts " ---------------> #{steps} "
        if !rollbacks.empty?
          puts "[i] Executing rollback for `#{@name}` database"
          # Rollback is executed only on the steps
          # performed migration
          rollbacks[0..steps].each { |rollback| rollback.unexecute(self) }
        else
          puts "[i] No rollback possible for `#{@name}` database"
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
        HISTORY_TABLE
      end

      def connected_db
        @driver
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
        # Schema changes in OrientDB ar not transactionable
        @driver.batch.execute({ transaction: false,
                                 operations: [
                                   {
                                     type: "script",
                                     language: "sql",
                                     script: [ "BEGIN",
                                               "CREATE CLASS #{HISTORY_TABLE.to_s}",
                                               "CREATE PROPERTY #{HISTORY_TABLE.to_s}.time DOUBLE",
                                               "CREATE PROPERTY #{HISTORY_TABLE.to_s}.executed DATETIME",
                                               "CREATE PROPERTY #{HISTORY_TABLE.to_s}.name STRING",
                                               "CREATE PROPERTY #{HISTORY_TABLE.to_s}.type STRING",
                                               "CREATE INDEX #{HISTORY_TABLE.to_s}.time_type ON #{HISTORY_TABLE.to_s} (time, type) NOTUNIQUE_HASH_INDEX",
                                               "COMMIT"
                                             ]
                                   }
                                 ]
                               }
                             )
      end
    end
  end
end
