require "./test/test_helper"

class AdminCanViewAllPagesTest < Capybara::Rails::TestCase

  test "admin can view all users" do
    user1 = User.new({username: 'admin', password: 'password', email: "admin@example.com"})
    user1.admin = true
    user1.save
    user2 = User.create({username: 'bob_bob', password: 'password', email: "bob_bob@example.com"})

    visit root_path
    click_on "Login"

    fill_in "Username", with: 'admin'
    fill_in "Password", with: 'password'
    click_button "Login"

    visit users_path
    assert_content page, 'All users'
  end

  test "admin can view individual users" do
    user1 = User.new({username: 'admin', password: 'password', email: "admin@example.com"})
    user1.admin = true
    user1.save
    user2 = User.create({username: 'bob_bob', password: 'password', email: "bob_bob@example.com"})

    visit root_path
    click_on "Login"

    fill_in "Username", with: 'admin'
    fill_in "Password", with: 'password'
    click_button "Login"

    visit user_path(user2)
    assert_content page, 'bob_bob'
  end

  test "admin can create item" do
    user1 = User.new({username: 'admin', password: 'password', email: "example@example.com"})
    user1.admin = true
    user1.save!
    restaurant1 = Restaurant.new(slug: "billys-bbq", name: "Billy's BBQ")
    restaurant1.users << user1
    restaurant1.status = "Approved"
    restaurant1.save!

    visit root_path
    click_on "Login"
    fill_in "Username", with: 'admin'
    fill_in "Password", with: 'password'
    click_button "Login"

    visit new_item_path(restaurant1.slug)
    fill_in "Title", :with => "deviled eggs"
    fill_in "Description", :with => "12 luscious eggs"
    fill_in "Price", :with => "3"
    click_button "Add Item"

    assert_content page, "deviled eggs"
  end

  test "admin can edit an item" do
    @item = Item.create({title: "Burger", description: "Loafy goodness", price: '1'})
    user1 = User.new({username: 'admin', password: 'password', email: "admin@example.com"})
    user1.admin = true
    user1.save
    restaurant1 = Restaurant.new(slug: "billys-bbq", name: "Billy's BBQ")
    restaurant1.users << user1
    restaurant1.items << @item
    restaurant1.status = "Approved"
    restaurant1.save!

    visit root_path
    click_on "Login"

    fill_in "Username", with: 'admin'
    fill_in "Password", with: 'password'
    click_button "Login"
    visit edit_item_path(restaurant1.slug, @item.id)
    fill_in "Title", :with => "Cow"
    click_button "Update item"
    assert_content page, "Cow"
  end

  test "can see current orders" do
    item = {title: "cookie", description: "chocolate chip",
                        price: "3"}
    order = Order.new
    order.save
    order.items.create(item)
    user1 = User.new({username: 'admin', password: 'password', email: "admin@example.com"})
    user1.admin = true
    user1.save

    visit root_path
    click_on "Login"

    fill_in "Username", with: 'admin'
    fill_in "Password", with: 'password'
    click_button "Login"
    visit orders_path
    within("#orders") do
      assert_content page, "cookie"
      assert_content page, "pending"
    end
  end

  test "categories are prepopulated on edit" do
    item = Item.create({title: "Deviled Eggs", description: "one dozen eggs", price: 5})
    category1 = Category.create({name: "Snacks"})
    category2 = Category.create({name: "Lunch"})
    item.categories << category1

    user1 = User.new({username: 'admin', password: 'password', email: "admin@example.com"})
    user1.admin = true
    user1.save

    restaurant1 = Restaurant.new(slug: "billys-bbq", name: "Billy's BBQ")
    restaurant1.users << user1
    restaurant1.items << item
    restaurant1.status = "Approved"
    restaurant1.categories << category1
    restaurant1.categories << category2
    restaurant1.save!

    visit root_path
    click_on "Login"
    fill_in "Username", with: 'admin'
    fill_in "Password", with: 'password'
    click_button "Login"

    visit edit_item_path(restaurant1.slug, item)
    assert has_checked_field?("item_category_1")
  end

  test "correct categories are prepopulated on edit" do
    item = Item.create({title: "Deviled Eggs", description: "one dozen eggs", price: 5})
    category1 = Category.create({name: "Snacks"})
    category2 = Category.create({name: "Lunch"})
    item.categories << category1

    user1 = User.new({username: 'admin', password: 'password', email: "admin@example.com"})
    user1.admin = true
    user1.save

    restaurant1 = Restaurant.new(slug: "billys-bbq", name: "Billy's BBQ")
    restaurant1.users << user1
    restaurant1.items << item
    restaurant1.status = "Approved"
    restaurant1.categories << category1
    restaurant1.categories << category2
    restaurant1.save!

    visit root_path
    click_on "Login"
    fill_in "Username", with: 'admin'
    fill_in "Password", with: 'password'
    click_button "Login"

    visit edit_item_path(restaurant1.slug, item.id)
    assert has_unchecked_field?("item_category_2")
  end
end
