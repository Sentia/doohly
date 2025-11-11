# frozen_string_literal: true

RSpec.describe Doohly do
  it "has a version number" do
    expect(Doohly::VERSION).not_to be_nil
  end

  it "provides a client convenience method" do
    described_class.configure { |c| c.api_token = "test_token" }
    client = described_class.client
    expect(client).to be_a(Doohly::Client)
  end
end
