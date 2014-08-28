module Subscribem
  module TestingSupport
    module AuthenticationHelpers
      include Warden::Test::Helpers
      #Warden.test_mode!
      def self.included(base)
        base.after do
          logout
        end
      end
      def sign_in_as(options={})
        options.each do |scope, object|
          login_as(object, scope: scope)
        end
      end
      RSpec.configure do |config|
        config.include AuthenticationHelpers, type: :feature
        config.after type: :feature do
          logout
        end
      end
    end
  end
end



