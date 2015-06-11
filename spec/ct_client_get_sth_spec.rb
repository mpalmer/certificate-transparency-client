require_relative './spec_helper'

describe "CT::Client#get_sth" do
	let(:client) do
		CT::Client.new "https://example.org",
		               :public_key => read_fixture_file("pk_base64")
	end

	let(:result) do
		stub_request(:get, "https://example.org/ct/v1/get-sth").
		  to_return(
		    :headers => {"Content-Type" => "application/json"},
		    :body    => read_fixture_file("ok_sth")
		  )

		client.get_sth
	end

	it "returns a CT::STH" do
		expect(result).to be_a(CT::SignedTreeHead)
	end

	it "the STH validates" do
		expect(result).to be_valid(client.public_key)
	end

	it "looks OK" do
		expect(result.tree_size).to eq(7872977)
	end
end
