require 'rails_helper'

RSpec.describe "UserAuths", type: :system do
  before do
    driven_by(:rack_test)
  end

  it "allows a user to sign up" do
    visit root_path
    click_link "Sign up"

    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password"
    fill_in "Password confirmation", with: "password"
    click_button "Sign up"

    expect(page).to have_content("Welcome! You have signed up successfully.")
    expect(page).to have_content("Hello, test@example.com!")
  end

  it "allows a user to sign out" do
    user = FactoryBot.create(:user)
    sign_in user
    visit root_path

    expect(page).to have_content("Hello, #{user.email}!")
    click_button "Sign out"

    expect(page).to have_content("Signed out successfully.")
    expect(page).to have_content("Login")
  end
end