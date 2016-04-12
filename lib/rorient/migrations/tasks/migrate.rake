namespace :rorient do
  namespace :db do
    desc 'Run migrations'
    task :migrate do
      Rorient::Migrations.migrate
    end
  end
end
