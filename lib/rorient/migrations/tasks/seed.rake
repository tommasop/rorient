namespace :rorientmigrations do
  namespace :db do
    desc 'Seed database'
    task :seed do
      Rorient::Migrations.seed
    end
  end
end
