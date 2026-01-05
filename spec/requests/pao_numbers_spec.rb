require 'rails_helper'

RSpec.describe "PaoNumbers", type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:other_user) { FactoryBot.create(:user) }

  before do
    sign_in user, scope: :user
  end

  describe "GET /index" do
    it "returns http success and creates missing numbers" do
      get pao_numbers_path
      expect(response).to have_http_status(:success)
      expect(user.pao_numbers.count).to eq(100)
    end
  end

  describe "PATCH /bulk_update" do
    it "updates the user's pao numbers" do
      pao = user.pao_numbers.create(number: 1, person: "Old")
      
      patch bulk_update_pao_numbers_path, params: {
        pao_numbers: {
          pao.id => { person: "New Person" }
        }
      }
      
      expect(pao.reload.person).to eq("New Person")
    end

    it "does NOT update another user's pao numbers (IDOR Protection)" do
      # Setup other user's data
      other_pao = other_user.pao_numbers.create(number: 1, person: "Other Person")
      
      # Try to update it as 'user'
      patch bulk_update_pao_numbers_path, params: {
        pao_numbers: {
          other_pao.id => { person: "Hacked" }
        }
      }
      
      # Verify it hasn't changed
      expect(other_pao.reload.person).to eq("Other Person")
    end
  end
end