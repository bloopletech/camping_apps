load 'deploy' if respond_to?(:namespace) # cap2 differentiator

set :application, "camping"
#set :user, "bloople"
#set :repository,  "svn+slice://bloople@67.207.142.56/home/bloople/repo/camping/trunk"
#set :port, 9979
set :scm, :git
set :repository, "git@github.com:bloopletech/camping_apps.git"

set :deploy_to, "/home/bloople/www/#{application}"

set :deploy_via, :remote_cache

upload "_configuration.rb", "#{deploy_to}/current/_configuration.rb"

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
    run "killall -w rackup;(cd ~/www/camping/current/ && rackup -p 8004 -E none camping.ru 2>/dev/null >/dev/null &) | exit;"
  end

  task :start, :roles => :app do
    restart
  end

  task :migrate, :roles => :db, :only => { :primary => true } do
  end

  task :after_update_code, :roles => :app do
    run "ln -nfs #{deploy_to}/shared/system/blog/assets #{release_path}/blog/public/assets"
    run "ln -nfs #{deploy_to}/shared/system/kc/images/users #{release_path}/kc/public/images/users"
    run "ln -nfs #{deploy_to}/shared/system/portfolio/images/works #{release_path}/portfolio/public/images/works"
    run "ln -nfs #{deploy_to}/shared/system/ajas/anime_titles #{release_path}/ajas/public/images/anime_titles"
  end

  task :after_setup, :roles => :app do
    run "mkdir #{deploy_to}/shared/system/blog #{deploy_to}/shared/system/blog/public/assets"
    run "ln -nfs #{deploy_to}/shared/system/kc/images/users #{release_path}/kc/public/images/users"
    run "ln -nfs #{deploy_to}/shared/system/portfolio/images/works #{release_path}/portfolio/public/images/works"
    run "ln -nfs #{deploy_to}/shared/system/ajas/anime_titles #{release_path}/ajas/public/images/anime_titles"
  end
end