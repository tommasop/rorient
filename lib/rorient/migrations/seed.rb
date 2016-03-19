module Rorient
  module Migrations
    # Seed class
    #
    class Seed < Rorient::Migrations::Script
      def self.find(database_name)
        super(database_name, :seed)
      end
    end
  end
end
