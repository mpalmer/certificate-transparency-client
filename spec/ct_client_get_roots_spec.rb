require_relative './spec_helper'

describe "CT::Client#get_roots" do
	let(:client) do
		CT::Client.new "https://example.org",
		               :public_key => read_fixture_file("pk_base64")
	end

	let(:result) do
		stub_request(:get, "https://example.org/ct/v1/get-roots").
		  to_return(
		    :headers => {"Content-Type" => "application/json; charset=ISO-8859-1"},
		    :body    => read_fixture_file("roots")
		  )

		client.get_roots
	end

	it "returns an array" do
		expect(result).to be_an(Array)
	end

	it "returns a non-empty array" do
		expect(result).to_not be_empty
	end

	it "returns an array of X509 certificates" do
		result.each { |c| expect(c).to be_an(OpenSSL::X509::Certificate) }
	end
end
