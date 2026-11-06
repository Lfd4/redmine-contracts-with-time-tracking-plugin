class AddPrecisionToHourlyRate < (ActiveRecord::VERSION::MAJOR >= 5 ? ActiveRecord::Migration[4.2] : ActiveRecord::Migration)
  def change
    change_column :contracts, :hourly_rate, :decimal, :precision => 16, :scale => 2
  end
end
