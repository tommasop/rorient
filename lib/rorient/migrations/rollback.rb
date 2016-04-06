module Rorient
  module Migrations
    # Rollback class
    #
    class Rollback < Rorient::Migrations::Script
      def self.find(database_name)
        super(database_name, :rollback)
      end
    end
  end
end
