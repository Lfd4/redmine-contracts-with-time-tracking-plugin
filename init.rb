require_dependency 'contracts/hooks/hooks'
require_dependency 'contracts/patches/time_entry_patch'
require_dependency 'contracts/patches/timelog_controller_patch'
require_dependency 'contracts/patches/user_patch'
require_dependency 'contracts/patches/project_patch'
require_dependency 'contracts/validators/is_after_agreement_date_validator'
require_dependency 'contracts/validators/is_after_start_date_validator'


Redmine::Plugin.register :contracts do
  name 'Redmine Contracts With Time Tracking'
  author 'Ben Syzek, Shanti Braford, Wesley Jones'
  description 'A Redmine plugin that allows you to manage contracts and associate time-entries with those contracts.'
  version '2.0.1-lfda.1'
  url 'https://github.com/upgradeya/redmine-contracts-with-time-tracking-plugin.git'

  requires_redmine :version_or_higher => '3.3'
 
  menu :application_menu, :contracts, { :controller => :contracts, :action => :all }, :caption => :label_contracts, :if => Proc.new { User.current.logged? && User.current.allowed_to?(:view_all_contracts_for_project, nil, :global => true) } 
  menu :project_menu, :contracts, { :controller => :contracts, :action => :index }, :caption => :label_contracts, :param => :project_id

  settings :default => {'empty' => true}, :partial => 'settings/contract_settings'

  project_module :contracts do
    permission :view_all_contracts_for_project,       :contracts => :index
    permission :view_contract_details,                :contracts => :show
    permission :edit_contracts,                       :contracts => [:edit, :update, :add_time_entries, :assoc_time_entries_with_contract, :lock]
    permission :create_contracts,                     :contracts => [:new, :create]
    permission :delete_contracts,                     :contracts => :destroy
    permission :view_hourly_rate,                     :contracts => :view_hourly_rate #view_hourly_rate is a fake action!
    permission :create_expenses,                      :expenses => [:new, :create]
    permission :edit_expenses,                        :expenses => [:edit, :update]
    permission :delete_expenses,                      :expenses => :destroy
    permission :view_expenses,                        :expenses => :show
  end
end

# Load your patches from contracts/lib/contracts/patches/
# (ActionDispatch::Callbacks.to_prepare is gone in Rails 5; Rails.configuration.to_prepare
# works on Rails 4.2 and 5.)
Rails.configuration.to_prepare do
  { Project => Contracts::ProjectPatch, TimeEntry => Contracts::TimeEntryPatch,
    TimelogController => Contracts::TimelogControllerPatch, User => Contracts::UserPatch }.each do |klass, patch|
    klass.send(:include, patch) unless klass.included_modules.include?(patch)
  end
  require_dependency 'contract_category'
end
