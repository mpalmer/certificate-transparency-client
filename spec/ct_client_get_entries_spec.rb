require_relative './spec_helper'

describe "CT::Client#get_entries" do
	let(:client) do
		CT::Client.new "https://example.org",
		               :public_key => read_fixture_file("pk_base64")
	end

	let(:result) do
		stub_request(:get, "https://example.org/ct/v1/get-entries").
		  with(:query => { "start" => start, "end" => _end }).
		  to_return(
		    :headers => {"Content-Type" => "application/json"},
		    :body    => read_fixture_file("ok_entries")
		  )

		client.get_entries(first, last)
	end

	context "specifying both first and last" do
		let(:first) { 1000 }
		let(:last)  { 1045 }
		let(:start) { 1000 }
		let(:_end)  { 1045 }

		it "returns an array" do
			expect(result).to be_an(Array)
		end

		it "returns six entries" do
			expect(result.length).to eq(6)
		end

		it "returns an array of CT::LogEntry" do
			result.each { |r| expect(r).to be_a(CT::LogEntry) }
		end
	end

	context "specifying just first" do
		let(:first) { 1000 }
		let(:last)  { nil  }
		let(:start) { 1000 }
		let(:_end)  { 7872976 }

		let(:sth_req) do
			stub_request(:get, "https://example.org/ct/v1/get-sth").
			  to_return(
			    :headers => {"Content-Type" => "application/json"},
			    :body    => read_fixture_file("ok_sth")
			  )
		end

		before(:each) { sth_req }

		it "looked up the STH to get the end" do
			result
			expect(sth_req).to have_been_made
		end

		it "returns an array" do
			expect(result).to be_an(Array)
		end

		it "returns six entries" do
			expect(result.length).to eq(6)
		end

		it "returns an array of CT::LogEntry" do
			result.each { |r| expect(r).to be_a(CT::LogEntry) }
		end
	end
end
