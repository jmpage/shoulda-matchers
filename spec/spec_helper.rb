# Create Rails environment based on the version given from Appraisal
TESTAPP_ROOT = File.join(File.dirname(__FILE__), '..', 'tmp', 'aruba', 'testapp')

FileUtils.rm_rf(TESTAPP_ROOT) if File.exists?(TESTAPP_ROOT)

`rails new #{TESTAPP_ROOT} --skip-bundle`

ENV['BUNDLE_GEMFILE'] ||= TESTAPP_ROOT + '/Gemfile'

Dir.chdir(TESTAPP_ROOT) do
  retry_count = 0
  loop do
    puts "Current directory: #{Dir.pwd}"
    %w(RUBYOPT BUNDLE_PATH BUNDLE_BIN_PATH BUNDLE_GEMFILE).each do |key|
      puts "#{key}: #{ENV[key].inspect}"
    end
    command = 'bundle install'
    output = `#{command} 2>&1`
    if $? == 0
      break
    else
      retry_count += 1
      if retry_count == 3
        raise "Command '#{command}' failed:\n#{output}"
      end
    end
  end
end

ENV['RAILS_ENV'] = 'test'

require "#{TESTAPP_ROOT}/config/environment"
require 'bourne'
require 'shoulda-matchers'
require 'rspec/rails'

PROJECT_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..')).freeze

$LOAD_PATH << File.join(PROJECT_ROOT, 'lib')

Dir[File.join(PROJECT_ROOT, 'spec', 'support', '**', '*.rb')].each { |file| require(file) }

# Run the migrations
ActiveRecord::Migration.verbose = false
ActiveRecord::Migrator.migrate(Rails.root.join('db/migrate'))

RSpec.configure do |config|
  config.mock_with :mocha
  config.include Shoulda::Matchers::ActionController,
                 :example_group => { :file_path => /action_controller/ }
end

raise 'ok good'
