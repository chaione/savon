require "spec_helper"

describe Savon::SOAP::Response do

  describe ".new" do
    it "should raise a Savon::SOAP::Fault in case of a SOAP fault" do
      lambda { soap_fault_response }.should raise_error(Savon::SOAP::Fault)
    end

    it "should not raise a Savon::SOAP::Fault in case the default is turned off" do
      Savon.raise_errors = false
      lambda { soap_fault_response }.should_not raise_error(Savon::SOAP::Fault)
      Savon.raise_errors = true
    end

    it "should raise a Savon::HTTP::Error in case of an HTTP error" do
      lambda { soap_response :code => 500 }.should raise_error(Savon::HTTP::Error)
    end

    it "should not raise a Savon::HTTP::Error in case the default is turned off" do
      Savon.raise_errors = false
      soap_response :code => 500
      Savon.raise_errors = true
    end
  end

  describe "#success?" do
    around do |example|
      Savon.raise_errors = false
      example.run
      Savon.raise_errors = true
    end

    it "should return true if the request was successful" do
      soap_response.should be_a_success
    end

    it "should return false if there was a SOAP fault" do
      soap_fault_response.should_not be_a_success
    end

    it "should return false if there was an HTTP error" do
      http_error_response.should_not be_a_success
    end
  end

  describe "#soap_fault?" do
    around do |example|
      Savon.raise_errors = false
      example.run
      Savon.raise_errors = true
    end

    it "should not return true in case the response seems to be ok" do
      soap_response.soap_fault?.should be_false
    end

    it "should return true in case of a SOAP fault" do
      soap_fault_response.soap_fault?.should be_true
    end
  end

  describe "#soap_fault" do
    around do |example|
      Savon.raise_errors = false
      example.run
      Savon.raise_errors = true
    end

    it "should return a Savon::SOAP::Fault" do
      soap_fault_response.soap_fault.should be_a(Savon::SOAP::Fault)
    end

    it "should return a Savon::SOAP::Fault containing the HTTPI::Response" do
      soap_fault_response.soap_fault.http.should be_an(HTTPI::Response)
    end

    it "should return a Savon::SOAP::Fault even if the SOAP response seems to be ok" do
      soap_response.soap_fault.should be_a(Savon::SOAP::Fault)
    end
  end

  describe "#http_error?" do
    around do |example|
      Savon.raise_errors = false
      example.run
      Savon.raise_errors = true
    end

    it "should not return true in case the response seems to be ok" do
      soap_response.http_error?.should_not be_true
    end

    it "should return true in case of an HTTP error" do
      soap_response(:code => 500).http_error?.should be_true
    end
  end

  describe "#http_error" do
    around do |example|
      Savon.raise_errors = false
      example.run
      Savon.raise_errors = true
    end

    it "should return a Savon::HTTP::Error" do
      http_error_response.http_error.should be_a(Savon::HTTP::Error)
    end

    it "should return a Savon::HTTP::Error containing the HTTPI::Response" do
      http_error_response.http_error.http.should be_an(HTTPI::Response)
    end

    it "should return a Savon::HTTP::Error even if the HTTP response seems to be ok" do
      soap_response.http_error.should be_a(Savon::HTTP::Error)
    end
  end

  describe "#original_hash" do
    it "should return the SOAP response body as a Hash" do
      soap_response.original_hash[:authenticate_response][:return].should ==
        ResponseFixture.authentication(:to_hash)
    end
  end

  describe "#to_hash" do
    let(:response) { soap_response }

    it "should memoize the result" do
      response.to_hash.should equal(response.to_hash)
    end

    context "without response pattern" do
      it "should return the original Hash" do
        response.to_hash[:authenticate_response].should be_a(Hash)
      end
    end

    context "with response pattern" do
      it "should apply the response pattern" do
        Savon.response_pattern = [/.+_response/, :return]
        response.to_hash[:success].should be_true
        
        Savon.response_pattern = nil  # reset to default
      end
    end

    context "with unmatched response pattern" do
      it "should return the original Hash" do
        Savon.response_pattern = [:unmatched, :pattern]
        response.to_hash.should == response.original_hash
        
        Savon.response_pattern = nil  # reset to default
      end
    end
  end

  describe "#to_array" do
    let(:response) { soap_response }

    around do |example|
      Savon.response_pattern = [/.+_response/, :return]
      example.run
      Savon.response_pattern = nil  # reset to default
    end

    it "should memoize the result" do
      response.to_array.should equal(response.to_array)
    end

    it "should return an Array for a single response element" do
      response.to_array.should be_an(Array)
      response.to_array.first[:success].should be_true
    end

    it "should return an Array for multiple response element" do
      Savon.response_pattern = [/.+_response/, :history, :case]
      list_response = soap_response :body => ResponseFixture.list
      
      list_response.to_array.should be_an(Array)
      list_response.to_array.should have(2).items
    end
  end

  describe "#to_xml" do
    it "should return the raw SOAP response body" do
      soap_response.to_xml.should == ResponseFixture.authentication
    end
  end

  describe "#http" do
    it "should return the HTTPI::Response" do
      soap_response.http.should be_an(HTTPI::Response)
    end
  end

  def soap_response(options = {})
    defaults = { :code => 200, :headers => {}, :body => ResponseFixture.authentication }
    response = defaults.merge options
    
    Savon::SOAP::Response.new HTTPI::Response.new(response[:code], response[:headers], response[:body])
  end

  def soap_fault_response
    soap_response :body => ResponseFixture.soap_fault
  end

  def http_error_response
    soap_response :code => 404, :body => "Not found"
  end

end
