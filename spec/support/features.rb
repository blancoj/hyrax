# spec/support/features.rb
require File.expand_path('../features/session_helpers', __FILE__)
require File.expand_path('../features/confirmation', __FILE__)
require File.expand_path('../features/workflow', __FILE__)

require File.expand_path('../selectors', __FILE__)
require File.expand_path('../proxies', __FILE__)
require File.expand_path('../statistic_helper', __FILE__)

RSpec.configure do |config|
  config.include Features::SessionHelpers, type: :feature
  config.include Features::Confirmation, type: :feature
end
