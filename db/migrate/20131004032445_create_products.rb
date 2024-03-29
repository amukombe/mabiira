class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :title
      t.text :description
      t.string :image_url
      t.decimal :price, :precision=>8, :scale=>2
      t.integer :seller_id
      t.boolean :availability, :default=>true
      t.integer :branch_id

      t.timestamps
    end
  end
end
