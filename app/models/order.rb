class Order < ActiveRecord::Base
  has_many :order_items
  has_many :items, through: :order_items
  belongs_to :user

  def self.pending
    where(status: "pending")
  end

  def order_items_by_restaurant
    order_items.group_by do |item|
      item.restaurant
    end
  end

  def total_items
    order_items.inject(0) do |sum, order_item|
      sum + order_item.quantity
    end
  end

  def update_status(new_status)
    Order.update(self.id, status: new_status)
  end

  def subtotal
    order_items.inject(0) do |sum, order_item|
      item_price = Item.find(order_item.item_id).price
      sum + order_item.quantity * item_price
    end
  end

end
