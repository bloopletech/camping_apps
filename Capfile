load 'deploy' if respond_to?(:namespace) # cap2 differentiator

set :application, "camping"
set :user, "bloople"
set :port, 9979
set :scm, :git
set :repository, "git@github.com:bloopletech/camping_apps.git"

set :deploy_to, "/home/bloople/www/#{application}"

set :deploy_via, :remote_cache

set :keep_releases, 2

role :app, "bloople.net"
role :web, "bloople.net"
role :db,  "bloople.net", :primary => true

set :runner, user

namespace :deploy do
  desc "The spinner task is used by :cold_deploy to start the application up"
  task :spinner, :roles => :app do
    restart
  end

  desc "Restart the mongrel cluster"
  task :restart, :roles => :app do
    run "cd #{deploy_to}/current/;killall -w rackup;(rackup -p 8004 -E none init/camping.ru >/dev/null 2>kc-err.log &); exit;"
  end

  task :start, :roles => :app do
    restart
  end

  task :migrate, :roles => :db, :only => { :primary => true } do
  end

  task :after_update_code, :roles => :app do
    cmd = "scp -P #{port} init/configuration.rb #{user}@bloople.net:#{release_path}/init/"
    puts cmd
    system cmd
    run "ln -nfs #{deploy_to}/shared/system/blog/assets #{release_path}/blog/public/assets"
    run "ln -nfs #{deploy_to}/shared/system/kc/images/users #{release_path}/kc/public/images/users"
    run "ln -nfs #{deploy_to}/shared/system/akc/images/users #{release_path}/akc/public/images/users"
    run "ln -nfs #{deploy_to}/shared/system/quiz/images/users #{release_path}/quiz/public/images/users"
    run "ln -nfs #{deploy_to}/shared/system/portfolio/images/works #{release_path}/portfolio/public/images/works"
    run "ln -nfs #{deploy_to}/shared/system/ajas/anime_titles #{release_path}/ajas/public/images/anime_titles"
    run "rm -rf #{release_path}/quiz/public/quiz; ln -nfs /home/bloople/www/bloople.net/public/quiz #{release_path}/quiz/publc/quiz"
  end

  task :after_setup, :roles => :app do
    cmd =  "scp -P #{port} init/configuration.rb #{user}@bloople.net:#{release_path}/init/"
    puts cmd
    system cmd
    run "mkdir #{deploy_to}/shared/system/blog #{deploy_to}/shared/system/blog/public/assets"
    run "ln -nfs #{deploy_to}/shared/system/kc/images/users #{release_path}/kc/public/images/users"
    run "ln -nfs #{deploy_to}/shared/system/akc/images/users #{release_path}/akc/public/images/users"
    run "ln -nfs #{deploy_to}/shared/system/quiz/images/users #{release_path}/quiz/public/images/users"
    run "ln -nfs #{deploy_to}/shared/system/portfolio/images/works #{release_path}/portfolio/public/images/works"
    run "ln -nfs #{deploy_to}/shared/system/ajas/anime_titles #{release_path}/ajas/public/images/anime_titles"
    run "rm -rf #{release_path}/quiz/public/quiz; ln -nfs /home/bloople/www/bloople.net/public/quiz #{release_path}/quiz/publc/quiz"
  end
end