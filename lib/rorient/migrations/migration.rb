module Rorient
  module Migrations
    # Migration class
    #
    class Migration < Rorient::Migrations::Script
      def self.find(database_name)
        super(database_name, :migration)
      end

      def name
        super
      end
    end
  end
end
