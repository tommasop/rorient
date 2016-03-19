module Rorient
  module Migrations
    # Migration class
    #
    class Migration < Rorient::Migrations::Script
      def self.find(database_name)
        super(database_name, :migration)
      end
    end
  end
end
