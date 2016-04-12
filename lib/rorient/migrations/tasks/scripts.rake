namespace :rorient do
  namespace :db do
    desc 'List found migration and seed files'
    task :scripts do
      Rorient::Migrations.scripts
    end
  end
end
