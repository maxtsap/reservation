class CreateTableReservations < ActiveRecord::Migration
  def change
    create_table :table_reservations do |t|
      t.integer :table_number
      t.datetime :started_at
      t.datetime :ended_at

      t.timestamps
    end
  end
end
