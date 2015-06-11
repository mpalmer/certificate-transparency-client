require_relative './spec_helper'

describe "CT::Client.new" do
	it "needs a URL" do
		expect { CT::Client.new }.
		  to raise_error(ArgumentError)
	end

	it "accepts just a URL" do
		expect { CT::Client.new "https://ct.example.com" }.
		  to_not raise_error
	end

	it "takes a raw public key" do
		expect do
			CT::Client.new "https://ct.example.com",
			               :public_key => read_fixture_file("pk_raw")
		end.to_not raise_error
	end

	it "takes a base64 public key" do
		expect do
			CT::Client.new "https://ct.example.com",
			               :public_key => read_fixture_file("pk_base64")
		end.to_not raise_error
	end

	it "throws up on an invalid raw public key" do
		expect do
			CT::Client.new "https://ct.example.com",
			               :public_key => "this is total jibberish"
		end.to raise_error(ArgumentError, /Invalid public key/)
	end

	it "throws up on an invalid base64 public key" do
		expect do
			CT::Client.new "https://ct.example.com",
			               :public_key => "thisisbase64compliantjibberish"
		end.to raise_error(ArgumentError, /Invalid public key/)
	end
end
