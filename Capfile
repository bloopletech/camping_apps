load 'deploy' if respond_to?(:namespace) # cap2 differentiator

default_run_options[:pty] = true

set :application, "camping_apps"
set :user, "bloople"
#set :port, 9979
set :scm, :git
set :repository, "git@github.com:bloopletech/camping_apps.git"

set :deploy_to, "/www/#{application}"

set :deploy_via, :remote_cache

set :keep_releases, 2

role :app, "173.230.157.72"
role :web, "173.230.157.72"
role :db,  "173.230.157.72", :primary => true

set :runner, user

def run_in_current(task)
  run "cd #{release_path}; TERM=xterm-color rvm use 1.8.7; #{task}; exit;", :pty => false, :shell => 'bash -l'
end

namespace :deploy do
#  task :stop, :roles => :app do
#    run "cd #{deploy_to}/current/;rake stop_rackup_production; exit;", :pty => false
#  end

#  task :start, :roles => :app do
#    restart
#  end

  desc "Restart the server"
  task :restart, :roles => :app do
    sudo "monit -c /etc/monit/monitrc restart rackup"
    run_in_current "rake clear_caches"
  end

  desc "The spinner task is used by :cold_deploy to start the application up"
  task :spinner, :roles => :app do
    restart
  end

  task :migrate, :roles => :db, :only => { :primary => true } do
  end

  task :finalize_update, :except => { :no_release => true } do
    run "chmod -R g+w #{latest_release}" if fetch(:group_writable, true)

    # mkdir -p is making sure that the directories are there for some SCM's that don't
    # save empty folders
    run <<-CMD
      rm -rf #{latest_release}/log #{latest_release}/public/system #{latest_release}/tmp/pids &&
      mkdir -p #{latest_release}/public &&
      mkdir -p #{latest_release}/tmp &&
      ln -s #{shared_path}/log #{latest_release}/log &&
      ln -s #{shared_path}/system #{latest_release}/public/system &&
      ln -s #{shared_path}/pids #{latest_release}/tmp/pids
    CMD
  end

  task :after_update_code, :roles => :app do
    run "ln -nfs #{deploy_to}/shared/lib/configuration.rb #{release_path}/init/configuration.rb"
    run "ln -nfs #{deploy_to}/shared/system/blog/assets #{release_path}/blog/public/assets"
    run "ln -nfs #{deploy_to}/shared/system/kc/images/users #{release_path}/kc/public/images/users"
    run "ln -nfs #{deploy_to}/shared/system/akc/images/users #{release_path}/akc/public/images/users"
    run "ln -nfs #{deploy_to}/shared/system/portfolio/images/works #{release_path}/portfolio/public/images/works"
    run "ln -nfs #{deploy_to}/shared/system/ajas/anime_titles #{release_path}/ajas/public/images/anime_titles"
    run_in_current "rake generate_nginx_config"
  end

  task :after_setup, :roles => :app do
    after_update_code
  end
end

after :deploy, 'deploy:cleanup'