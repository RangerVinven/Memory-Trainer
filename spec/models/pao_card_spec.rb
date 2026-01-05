require 'rails_helper'

RSpec.describe PaoCard, type: :model do
  let(:user) { FactoryBot.create(:user) }

  it "is valid with valid attributes" do
    card = user.pao_cards.build(suit: :spades, rank: :ace)
    expect(card).to be_valid
  end

  it "enforces uniqueness of rank per suit per user" do
    user.pao_cards.create(suit: :hearts, rank: :king)
    dup = user.pao_cards.build(suit: :hearts, rank: :king)
    expect(dup).to_not be_valid
  end
end