# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Rails.application.load_tasks

namespace :nomnichi do
  class NomnichiShell
    require "thor"
    attr_reader :sh

    def initialize
      @sh = Thor.new
    end

    def warn_file_existance(filename)
      return false unless File.exists?(filename)

      sh.say_status "ignore", "already exists #{filename}", :yellow
      return true
    end

    def create_file_from_template(dest_path, binding)
      template = ERB.new(File.open(dest_path + ".template").read, nil, "-")

      begin
        File.open(dest_path, "w", 0600) do |file|
          file.write(template.result(binding))
        end
        sh.say_status "ok", "create #{dest_path}", :green
      rescue StandardError => e
        sh.say_status "failed", "#{e.message.split(' @').first} #{dest_path}", :red
      end
    end
  end

  task :install => [:install_secrets, :install_application_settings]

  task :install_application_settings do
    engine = NomnichiShell.new
    sh = engine.sh
    path = "config/application_settings.yml"

    sh.say_status "info", "Setting up #{path}..."
    next if engine.warn_file_existance(path)

    # setup variables required in template
    config = {
      description:   "This file is created by bundle exec rake nomnichi:install_application_settings.",
      client_id:     sh.ask("Application client id:"),
      client_secret: sh.ask("Application client secret:"),
      org_name:      sh.ask("Your GitHub organization name:"),
      team_name:     nil,
      team_id:       nil
    }

    # Ask user account for listing his/her teams.
    user_name = sh.ask("Your GitHub account name:")
    teams = JSON.parse(`curl -s -u #{user_name} https://api.github.com/orgs/#{config[:org_name]}/teams`)
    teams.each {|team| puts "* #{team['name']}: #{team['description']}"}

    # Ask team name and find it's id.
    config[:team_name] = sh.ask("Your GitHub team name:")
    teams.each {|team| config[:team_id] = team['id'] if team['name'] == config[:team_name]}

    unless config[:team_id]
      sh.say_status "fail", "No GitHub team #{config[:org_name]}/#{config[:team_name]} found .. abort.", :red
      return 1
    end

    engine.create_file_from_template(path, binding)
  end

  task :install_secrets do
    engine = NomnichiShell.new
    sh = engine.sh
    path = "config/secrets.yml"

    sh.say_status "info", "Setting up #{path}..."
    next if engine.warn_file_existance(path)

    # setup variables required in template
    config = {
      secret_key_base:     nil
    }

    config[:secret_key_base] = SecureRandom.hex(64)
    engine.create_file_from_template(path, binding)
  end
end
