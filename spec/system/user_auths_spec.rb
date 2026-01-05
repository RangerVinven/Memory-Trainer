require 'rails_helper'

RSpec.describe "UserAuths", type: :system do
  before do
    driven_by(:rack_test)
  end

  it "allows a user to sign up" do
    visit root_path
    within(".auth-buttons") do
      click_link "Sign Up"
    end

    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password"
    fill_in "Password confirmation", with: "password"
    click_button "Sign up"

    expect(page).to have_content("Welcome! You have signed up successfully.")
    expect(page).to have_content("Welcome back, Test!")
  end

  it "allows a user to sign out" do
    user = FactoryBot.create(:user)
    sign_in user, scope: :user
    visit root_path

    # expect(page).to have_content("Welcome back, #{user.email.split('@').first.capitalize}!")
    click_button "Sign Out"

    expect(page).to have_content("Signed out successfully.")
    expect(page).to have_content("Login")
  end
end