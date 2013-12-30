before 'deploy:restart', 'deploy:fix_monit_permissions'

set :monit_path, "/usr/bin/monit"

def run_with_monit(action, process)
  sudo "#{monit_path} #{action} #{process} && sleep 2"
end

def start_with_monit(process)
  run_with_monit('start', process)
end

def stop_with_monit(process)
  run_with_monit('stop', process)
end

namespace :deploy do

  # http://stackoverflow.com/questions/1449836/how-to-manage-rails-database-yml
  desc 'Symlinks the config files'
  task :symlink_config_files, :roles => :app do
    run "ln -nfs #{deploy_to}/shared/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{deploy_to}/shared/config/settings.yml #{release_path}/config/settings.yml"
    run "ln -nfs #{deploy_to}/shared/uploads #{release_path}/public/uploads"
  end

  desc 'Makes the monit.sh file executable'
  task :fix_monit_permissions do
    sudo "chmod -R go+x #{current_path}/monit.sh"
  end

  task :start do
    start_with_monit(monit_app_name)
  end

  task :stop do
    stop_with_monit(monit_app_name)
  end

  task :restart, roles: :app, except: {no_release: true} do
    stop_with_monit(monit_app_name)
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
    start_with_monit(monit_app_name)
  end
end
