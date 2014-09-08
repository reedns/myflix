require "spec_helper"

feature "user registers", {js: true, vcr: true} do
  
  background { visit register_path }

  scenario "with valid user input and valid card" do
    enter_user_information("John Smith")
    enter_credit_card("4242424242424242")
    click_button "Sign Up"
    expect(page).to have_content "Welcome, John Smith"
  end

  scenario "with valid user input and  invalid card" do
    enter_user_information("John Smith")
    enter_credit_card("400")
    click_button "Sign Up"
    expect(page).to have_content "This card number looks invalid"
  end
  
  scenario "with valid user input and  declined card" do
    enter_user_information("John Smith")
    enter_credit_card("4000000000000002")
    click_button "Sign Up"
    expect(page).to have_content "Your card was declined"
  end
  
  scenario "with invalid user input and valid card" do
    enter_user_information(nil)
    enter_credit_card("4242424242424242")
    click_button "Sign Up"
    expect(page).to have_content "Name can't be blank"
  end

  scenario "with invalid user input and invalid card" do
    enter_user_information(nil)
    enter_credit_card("400")
    click_button "Sign Up"
    expect(page).to have_content "This card number looks invalid"
  end

  scenario "with invalid user input and delcined card" do
    enter_user_information(nil)
    enter_credit_card("4000000000000002")
    click_button "Sign Up"
    expect(page).to have_content "Name can't be blank"
  end
end

def enter_user_information(name)
  fill_in "Email Address", with: "john@example.com"
  fill_in "Password", with: "password"
  fill_in "Full Name", with: name
end

def enter_credit_card(credit_card)
  fill_in "Credit Card Number", with: credit_card
  fill_in "Security Code", with: "123"
  select "8 - August", from: "date_month"
  select "2018", from: "date_year"
end