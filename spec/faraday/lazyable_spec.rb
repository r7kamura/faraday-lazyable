require "spec_helper"

describe Faraday::Lazyable do
  let(:client) do
    Faraday.new do |connection|
      connection.use Faraday::Lazyable
      connection.adapter :test, stubs
    end
  end

  let(:stubs) do
    Faraday::Adapter::Test::Stubs.new do |stub|
      stub.get(url) do
        history << true
        [response_status, response_headers, response_body]
      end
    end
  end

  let(:url) do
    "/"
  end

  let(:response_status) do
    200
  end

  let(:response_headers) do
    {}
  end

  let(:response_body) do
    "OK"
  end

  let(:history) do
    []
  end

  context "till any method is called to the response" do
    it "does not send any request" do
      response = client.get(url)
      history.should be_empty
      response.body
      history.should_not be_empty
    end
  end

  context "after any method is called to the response" do
    it "behaves like a real response" do
      response = client.get(url)
      response.status.should == response_status
      response.headers.should == response_headers
      response.body.should == response_body
      response.should be_a Faraday::Response
    end
  end

  context "even if 2 methods are called to the response" do
    it "sends only 1 request" do
      response = client.get(url)
      response.headers
      response.body
      history.size.should == 1
    end
  end

  context "when undefined method is called to the response" do
    it "raises NoMethodError" do
      response = client.get(url)
      expect { response.undefined_method }.to raise_error(NoMethodError)
    end

    it "sends a request" do
      response = client.get(url)
      response.undefined_method rescue nil
      history.size.should == 1
    end
  end
end
