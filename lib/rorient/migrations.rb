# Rorient::Migrations
Oj.default_options = {:symbol_keys => true}

module Rorient
  module Migrations

    autoload :Database, 'rorient/migrations/database'
    autoload :Config, 'rorient/migrations/config'
    autoload :File, 'rorient/migrations/file'
    autoload :Script, 'rorient/migrations/script'
    autoload :Migration, 'rorient/migrations/migration'
    autoload :Seed, 'rorient/migrations/seed'

    extend self

    def migrate
      databases(&:migrate)
    end

    def seed
      databases(&:seed)
    end

    def rollback
      databases(&:rollback)
    end

    def scripts
      Config.databases.each do |name, _config|
        Migration.find(name).each { |migration| puts migration }
        Seed.find(name).each      { |seed|      puts seed      }
      end
    end

    def databases
      Config.databases.each do |name, config|
        db = Database.new(name, config)
        yield db if block_given?
      end
    end
    
    def load_tasks!
      load 'rorient/migrations/tasks/migrate.rake'
      load 'rorient/migrations/tasks/rollback.rake'
      load 'rorient/migrations/tasks/seed.rake'
      load 'rorient/migrations/tasks/scripts.rake'
    end
  end
end
