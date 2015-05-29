require_relative './spec_helper'

describe "CT::SignedTreeHead" do
	context ".new" do
		it "is happy to take nothing" do
			expect { CT::SignedTreeHead.new }.to_not raise_error
		end
	end

	context ".from_json" do
		it "needs an argument" do
			expect { CT::SignedTreeHead.from_json }.
			  to raise_error(ArgumentError)
		end

		it "pukes on arbitrary input" do
			expect { CT::SignedTreeHead.from_json("OMG WTF") }.
			  to raise_error(JSON::ParserError)
		end

		it "takes a JSON document" do
			expect { CT::SignedTreeHead.from_json(fixture_file("json_sth")) }.
			  to_not raise_error
		end

		let(:sth) { CT::SignedTreeHead.from_json(fixture_file("json_sth")) }

		it "records the tree size" do
			expect(sth.tree_size).to eq(4967961)
		end

		it "records the timestamp" do
			expect(sth.timestamp).to be_within(0.001).of(Time.at(1432858108.748))
		end

		it "validates" do
			expect(sth.valid?(fixture_file("rocketeer_pk").unbase64)).to be(true)
		end
	end
end
