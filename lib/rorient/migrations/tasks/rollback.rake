namespace :rorient do
  namespace :db do
    desc 'Execute Rollback'
    task :rollback do
      Rorient::Migrations.rollback(ENV['STEPS'].to_i)
    end
  end
end
