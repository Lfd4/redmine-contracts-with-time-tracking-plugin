# Plugin code in lib/ follows Rails' file naming (lib/contracts/project_patch.rb defines
# Contracts::ProjectPatch), so it autoloads on every Redmine version: Redmine 3/4 put lib/
# on the autoload path, Redmine 5+ autoload it with Zeitwerk.

Redmine::Plugin.register :contracts do
  name 'Redmine Contracts With Time Tracking'
  author 'Ben Syzek, Shanti Braford, Wesley Jones'
  description 'A Redmine plugin that allows you to manage contracts and associate time-entries with those contracts.'
  version '2.0.1-lfda.4'
  url 'https://github.com/upgradeya/redmine-contracts-with-time-tracking-plugin.git'

  # Hours are shown with Redmine's format_hours (time span format setting), Redmine 4.1+.
  requires_redmine :version_or_higher => '4.1'
 
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

# Apply the patches. Redmine 5+ (Rails 6+, Zeitwerk) runs init.rb itself inside
# to_prepare, so they are applied right here; on Redmine 3/4 init.rb runs once at boot and
# the patches go into Rails.configuration.to_prepare (ActionDispatch::Callbacks.to_prepare
# is gone in Rails 5).
apply_contracts_patches = lambda do
  { Project => Contracts::ProjectPatch, TimeEntry => Contracts::TimeEntryPatch,
    TimelogController => Contracts::TimelogControllerPatch, User => Contracts::UserPatch }.each do |klass, patch|
    klass.send(:include, patch) unless klass.included_modules.include?(patch)
  end
  Contracts::ContractsHookListener # registers the time entry form hook
  ContractCategory                 # an Enumeration subclass; load it so admin lists it
end

if Rails.respond_to?(:autoloaders)
  apply_contracts_patches.call
else
  Rails.configuration.to_prepare(&apply_contracts_patches)
end
