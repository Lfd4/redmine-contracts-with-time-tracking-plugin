class AddContractIdToTimeEntries < (ActiveRecord::VERSION::MAJOR >= 5 ? ActiveRecord::Migration[4.2] : ActiveRecord::Migration)
  def change
    add_column :time_entries, :contract_id, :integer
  end
end
