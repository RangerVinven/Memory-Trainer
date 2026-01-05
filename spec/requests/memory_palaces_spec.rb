require 'rails_helper'

RSpec.describe "MemoryPalaces", type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:other_user) { FactoryBot.create(:user) }
  
  before { sign_in user, scope: :user }

  describe "GET /index" do
    it "returns http success" do
      get memory_palaces_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "shows user's palace" do
      palace = user.memory_palaces.create(name: "My Palace")
      get memory_palace_path(palace)
      expect(response).to have_http_status(:success)
    end

    it "returns 404 for other user's palace (IDOR)" do
      other_palace = other_user.memory_palaces.create(name: "Secret")
      get memory_palace_path(other_palace)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /create" do
    it "creates a new palace" do
      expect {
        post memory_palaces_path, params: { memory_palace: { name: "New One" } }
      }.to change(MemoryPalace, :count).by(1)
    end
  end
end