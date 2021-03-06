class ItemsController < ApplicationController

  before_action :require_login, except: [:index, :show, :add_to_order]
  before_action :require_owner, only: [:new, :edit]

  def index
    redirect_to root_path unless current_restaurant.nil? || current_restaurant.approved?
    @categories = current_restaurant.categories
    current_items = current_restaurant.items.active
    @restaurant = current_restaurant

    set_order_cookie
    if params["Categories"]
  	  @category = current_restaurant.categories.find(params["Categories"])
  	  @items = current_items.find_all {|item| item.categories.include? @category}
    else
  	  @items = current_items
    end
    set_order(cookies[:order_id])
  end

  def destroy
    restaurant = Item.find(params[:id]).restaurant
    Item.destroy(params[:id])
    redirect_to restaurant_path(restaurant)
  end

  def new
    @item = Item.new
    @restaurant = current_restaurant
    @categories = current_restaurant.categories
  end

  def edit
    @item = Item.find(params[:id])
    @restaurant = @item.restaurant
    @categories = @restaurant.categories
  end

  def retire
    @item = current_user.items.find(params[:id])
    @item.active = false
    @item.save

    redirect_to restaurant_dashboard_path(params[:restaurant_slug])
  end

  def create
    @item = Item.new(item_params)
      @item.save
      @item.update_categories(params[:item][:category])
      if @item.restaurant
        redirect_to restaurant_dashboard_path(@item.restaurant.slug)
      else
        redirect_to root_path
      end
  end

  def show
    @item = Item.find(params[:id])
    set_order(cookies[:order_id])
  end


  def update
    @item = Item.update(params[:id], item_params)
    @item.update_categories(params[:item][:category])
      if @item.restaurant
        redirect_to restaurant_dashboard_path(@item.restaurant.slug)
      else
      redirect_to root_path
      end
  end

  def add_to_order
    order = Order.find(cookies[:order_id])
    item = Item.find(params[:id])
    if order.items.include? item
      order_item = OrderItem.where(order_id:order.id, item_id:item.id).first
      new_quantity = order_item.quantity + 1
      order_item.update(quantity: new_quantity)
    else
      order.items << item
    end
    flash.notice = item.title + " added to cart!"
    redirect_to :back
  end

  private

  def item_params
    params.require(:item).permit(:title, :description, :price, :image, :active, :restaurant_id)
  end

  def set_order(order)
    if order
      @order = Order.find(order)
    else
      @order = nil
    end
  end

  def set_order_cookie
    unless cookies[:order_id]
      order = Order.create
      cookies[:order_id] = order.id
    end
  end
end
