require "./test/test_helper"

class RestaurantTest < ActiveSupport::TestCase

  test "restaurant has a name" do
    restaurant1 = Restaurant.create
    restaurant2 = Restaurant.create

    restaurant1.name = "Billy's BBQ"
    restaurant1.save
    restaurant2.name = "Dive Bar"
    restaurant2.save

    assert_equal "Billy's BBQ", restaurant1.name
    assert_equal "Dive Bar", restaurant2.name
  end

  test "restaurant names are unique" do
    restaurant1 = Restaurant.new
    restaurant2 = Restaurant.new

    restaurant1.name = "Billy's BBQ"
    restaurant1.save

    assert_raise ActiveRecord::RecordInvalid do
      restaurant2.name = "Billy's BBQ"
      restaurant2.save!
    end
  end

  test "restaurant name creates slug name" do
    restaurant1 = Restaurant.new
    restaurant1.name = "Billy's BBQ"

    assert_equal "billys-bbq", restaurant1.slug
  end
end
