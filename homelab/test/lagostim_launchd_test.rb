#!/usr/bin/env ruby

require "yaml"

repo_root = File.expand_path("..", __dir__)
bundle_dir = "/Users/marcelof/.local/libexec/lagostim-hermes"

%w[personal work].each do |profile|
  config = YAML.safe_load_file(
    File.join(repo_root, "vars/services/lagostim-#{profile}-hermes.yml"),
    aliases: true
  )

  expected_start = "#{bundle_dir}/service-#{profile}-hermes.sh"
  expected_stop = "#{bundle_dir}/stop-#{profile}-hermes.sh"
  raise "#{profile}: wrong start path" unless config["service_exec_start"] == expected_start
  raise "#{profile}: wrong stop path" unless config["service_exec_stop"] == expected_stop
  raise "#{profile}: wrong working directory" unless config["service_working_directory"] == bundle_dir

  env = config.fetch("service_environment")
  expected_compose = "#{bundle_dir}/docker-compose.yml"
  raise "#{profile}: wrong Compose path" unless env["HERMES_COMPOSE_FILE"] == expected_compose
  unless env["HERMES_EXISTING_CONTAINER_ONLY"] == "1"
    raise "#{profile}: launchd must only start an existing container"
  end

  destinations = config.fetch("service_runtime_bundle_files").map { |item| item.fetch("dest") }
  %W[hermes-service.sh service-#{profile}-hermes.sh stop-#{profile}-hermes.sh docker-compose.yml].each do |name|
    raise "#{profile}: missing #{name}" unless destinations.include?(name)
  end

  if profile == "work"
    expected_paths = {
      "WORK_HERMES_SLACK_ALLOWED_USERS_GOPASS_PATH" => "lagostim/work-hermes/slack-allowed-users",
      "WORK_HERMES_TELEGRAM_ALLOWED_USERS_GOPASS_PATH" => "lagostim/work-hermes/telegram-allowed-users"
    }
    expected_paths.each do |name, path|
      raise "work: wrong #{name}" unless env[name] == path
    end
  end
end

puts "lagostim launchd tests passed"
