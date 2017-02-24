module Rorient 
  module Migrations
    # Class that represents database gem will connect to
    #
    class Database
      HISTORY_TABLE = "rorient_schema_migrations".freeze
      attr_reader :name, :driver

      def initialize(name, options)
        @name = name
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

      def rollback(steps=0)
        steps -= 1 if steps != 0
        # the rollback action must look into the db
        # for rollbacks the list must be taken in DESC order 
        rollback_files = Rorient::Migrations::Migration.find(@name)
        rollbacks = driver.query.execute(query_text: URI.encode("SELECT FROM #{history} ORDER BY time DESC"))[:result] 
        if !rollbacks.empty?
          puts "[i] Executing rollback for `#{@name}` database"
          # Rollback is executed only on the steps
          # performed migration
          rollbacks[0..steps].each do |rollback| 
            rollback_files.detect{| rf | rf[:name] == rollback.name }.unexecute(self)
          end
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
        @driver.batch.execute(Rorient::Batch.new(statements: 
          [ 
            "CREATE CLASS #{HISTORY_TABLE}",
            "CREATE PROPERTY #{HISTORY_TABLE}.time DOUBLE",
            "CREATE PROPERTY #{HISTORY_TABLE}.executed DATETIME",
            "CREATE PROPERTY #{HISTORY_TABLE}.name STRING",
            "CREATE PROPERTY #{HISTORY_TABLE}.type STRING",
            "CREATE INDEX #{HISTORY_TABLE}.time_type ON #{HISTORY_TABLE} (time, type) NOTUNIQUE_HASH_INDEX"
          ]).generate_hash)
      end
    end
  end
end
