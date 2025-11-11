# frozen_string_literal: true

RSpec.describe Doohly::Configuration do
  describe "#initialize" do
    it "sets default values" do
      config = described_class.new
      expect(config.api_base_url).to eq(Doohly::Configuration::DEFAULT_API_BASE_URL)
      expect(config.timeout).to eq(Doohly::Configuration::DEFAULT_TIMEOUT)
      expect(config.open_timeout).to eq(Doohly::Configuration::DEFAULT_OPEN_TIMEOUT)
      expect(config.api_token).to be_nil
      expect(config.logger).to be_nil
    end
  end

  describe "#validate!" do
    it "raises error when api_token is nil" do
      config = described_class.new
      expect { config.validate! }.to raise_error(Doohly::ConfigurationError, "API token is required")
    end

    it "raises error when api_token is empty" do
      config = described_class.new
      config.api_token = ""
      expect { config.validate! }.to raise_error(Doohly::ConfigurationError, "API token is required")
    end

    it "returns true when api_token is set" do
      config = described_class.new
      config.api_token = "test_token"
      expect(config.validate!).to be true
    end
  end
end

RSpec.describe Doohly do
  describe ".configure" do
    it "yields configuration block" do
      described_class.configure do |config|
        config.api_token = "my_token"
        config.timeout = 60
      end

      expect(described_class.configuration.api_token).to eq("my_token")
      expect(described_class.configuration.timeout).to eq(60)
    end

    it "validates configuration" do
      expect do
        described_class.configure do |config|
          config.api_token = nil
        end
      end.to raise_error(Doohly::ConfigurationError)
    end
  end

  describe ".reset_configuration!" do
    it "resets to default configuration" do
      described_class.configure { |c| c.api_token = "test" }
      described_class.reset_configuration!
      expect(described_class.configuration.api_token).to be_nil
    end
  end
end
