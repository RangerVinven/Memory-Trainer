require 'rails_helper'

RSpec.describe "TrainingFlow", type: :system do
  let(:user) { FactoryBot.create(:user) }

  before do
    driven_by(:rack_test)
    sign_in user, scope: :user
  end

  it "completes a number training session" do
    visit new_training_session_path
    
    select "Number", from: "Training type"
    fill_in "Total Items", with: "5"
    click_button "Begin Training"

    expect(page).to have_content("Press Space for next")
    # Get the number from the page
    number = find(".numbers-wrapper").text
    
    click_button "Finish Early"

    expect(page).to have_content("Recall Phase")
    fill_in "Your Recall Input", with: number
    click_button "Check Results"

    expect(page).to have_content("Results")
    expect(page).to have_content("Accuracy: 100.0%")
  end
end
