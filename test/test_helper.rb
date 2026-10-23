ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require_relative "test_helpers/session_test_helper"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    CLAVE = "clave-de-prueba-1"
  end
end

# Las pruebas de modelos trabajan dentro de la empresa "andes".
class ActiveSupport::TestCase
  setup { ActsAsTenant.current_tenant = empresas(:andes) unless is_a?(ActionDispatch::IntegrationTest) }
  teardown { ActsAsTenant.current_tenant = nil }
end
