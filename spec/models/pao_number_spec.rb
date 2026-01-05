require 'rails_helper'

RSpec.describe PaoNumber, type: :model do
  let(:user) { FactoryBot.create(:user) }

  it "is valid with valid attributes" do
    pao = user.pao_numbers.build(number: 55, person: "Einstein")
    expect(pao).to be_valid
  end

  it "requires a number" do
    pao = user.pao_numbers.build(number: nil)
    expect(pao).to_not be_valid
  end

  it "requires number between 0 and 99" do
    pao = user.pao_numbers.build(number: 100)
    expect(pao).to_not be_valid
    pao.number = -1
    expect(pao).to_not be_valid
  end

  it "enforces uniqueness per user" do
    user.pao_numbers.create(number: 10)
    dup = user.pao_numbers.build(number: 10)
    expect(dup).to_not be_valid
  end
end