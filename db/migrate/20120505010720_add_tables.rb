class AddTables < ActiveRecord::Migration
  def change
    create_table :countries, :id => false do |t|
      t.string :code, :limit => 2
      t.string :name
    end

    change_table :countries do |t|
      t.index :code
      t.index :name
    end

    create_table :subdivisions, :id => false do |t|
      t.string :code, :limit => 6
      t.string :name
      t.string :country_code, :limit => 2
    end

    change_table :subdivisions do |t|
      t.index [:country_code, :code]
      t.index :name
    end

    create_table :localities, :id => false do |t|
      t.string :name
      t.string :post_code, :limit => 4
      t.string :subdivision_code, :limit => 6
      t.float :longitude, :latitude
      t.integer :category_id
    end

    change_table :localities do |t|
      t.index :name
      t.index :post_code
      t.index [:subdivision_code, :name]
      t.index [:subdivision_code, :post_code]
    end
  end
end
