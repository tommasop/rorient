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
        @driver[HISTORY_TABLE]
      end

      private

      def self.connect(options)
        Rorient.connect(
                         server: options[:server],
                         user: options[:user],
                         password: options[:password],
                         db_name: options[:database]
        )
      end

      def install_table
        # TODO: check orientdb class existence
        return if @driver.table_exists?(HISTORY_TABLE)

        puts "[!] Installing `#{HISTORY_TABLE}` history table"
        # TODO: Create Rorient history table
        @driver.create_table(HISTORY_TABLE) do
          # rubocop:disable Style/SingleSpaceBeforeFirstArg
          primary_key :id
          Bignum      :time
          DateTime    :executed
          String      :name
          String      :type
          index       [:time, :type]
          # rubocop:enable Style/SingleSpaceBeforeFirstArg
        end
      end
    end
  end
end
