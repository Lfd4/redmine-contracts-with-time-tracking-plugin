class CreateUserContractRates < (ActiveRecord::VERSION::MAJOR >= 5 ? ActiveRecord::Migration[4.2] : ActiveRecord::Migration)
  def change
    create_table :user_contract_rates do |t|
      t.integer :user_id
      t.integer :contract_id
      t.float :rate, :length => 8, :decimals => 2
    end
  end
end
