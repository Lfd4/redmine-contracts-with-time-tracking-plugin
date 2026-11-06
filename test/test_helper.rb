# Load the normal Rails helper
require File.expand_path(File.dirname(__FILE__) + '/../../../test/test_helper')
ActiveRecord::FixtureSet.create_fixtures(File.dirname(__FILE__) + '/fixtures/', [:contracts, :user_contract_rates, :user_project_rates])

module ContractsTestHelper
  # The functional tests use the Rails 4.2 request style, `get :show, :id => 1`.
  # On Rails 5+ request params must be passed as `params:`; this wraps them.
  module LegacyRequests
    REQUEST_KEYS = [:params, :session, :flash, :xhr, :format, :body, :as]

    if Rails::VERSION::MAJOR >= 5
      [:get, :post, :put, :patch, :delete].each do |verb|
        define_method(verb) do |action, *args, **options|
          if args.empty? && options.any? && (options.keys & REQUEST_KEYS).empty?
            super(action, :params => options)
          else
            super(action, *args, **options)
          end
        end
      end

      # assigns(:name) moved to the rails-controller-testing gem in Rails 5.
      def assigns(name)
        @controller.instance_variable_get("@#{name}")
      end
    end
  end
end
