class AddSlugColumnToRestaurantsTable < ActiveRecord::Migration
  def change
    add_column :restaurants, :slug, :string
  end
end
