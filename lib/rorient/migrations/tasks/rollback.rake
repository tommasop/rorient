namespace :rorient do
  namespace :db do
    desc 'Execute Rollback'
    task :rollback do
      Rorient::Migrations.rollback
    end
  end
end
