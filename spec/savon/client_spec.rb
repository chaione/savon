require "spec_helper"

describe Savon::Client do
  let(:client) { Savon::Client.new { wsdl.document = Endpoint.wsdl } }

  describe ".new" do
    context "with a block expecting one argument" do
      it "should yield the WSDL object" do
        Savon::Client.new { |wsdl| wsdl.should be_a(Savon::WSDL::Document) }
      end
    end

    context "with a block expecting two arguments" do
      it "should yield the WSDL and HTTP objects" do
        Savon::Client.new do |wsdl, http|
          wsdl.should be_an(Savon::WSDL::Document)
          http.should be_an(HTTPI::Request)
        end
      end
    end

    context "with a block expecting three arguments" do
      it "should yield the WSDL, HTTP and WSSE objects" do
        Savon::Client.new do |wsdl, http, wsse|
          wsdl.should be_an(Savon::WSDL::Document)
          http.should be_an(HTTPI::Request)
          wsse.should be_an(Savon::WSSE)
        end
      end
    end

    context "with a block expecting no arguments" do
      it "should let you access the WSDL object" do
        Savon::Client.new { wsdl.should be_a(Savon::WSDL::Document) }
      end

      it "should let you access the HTTP object" do
        Savon::Client.new { http.should be_an(HTTPI::Request) }
      end

      it "should let you access the WSSE object" do
        Savon::Client.new { wsse.should be_a(Savon::WSSE) }
      end
    end
  end

  describe "#wsdl" do
    it "should return the Savon::WSDL::Document" do
      client.wsdl.should be_a(Savon::WSDL::Document)
    end
  end

  describe "#http" do
    it "should return the HTTPI::Request" do
      client.http.should be_an(HTTPI::Request)
    end
  end

  describe "#wsse" do
    it "should return the Savon::WSSE object" do
      client.wsse.should be_a(Savon::WSSE)
    end
  end

  describe "#request" do
    before do
      HTTPI.stubs(:get).returns(new_response(:body => WSDLFixture.load))
      HTTPI.stubs(:post).returns(new_response)
    end

    context "without any arguments" do
      it "should raise an ArgumentError" do
        lambda { client.request }.should raise_error(ArgumentError)
      end
    end

    context "with a single argument (Symbol)" do
      it "should set the input tag to result in <getUser>" do
        client.request(:get_user) { soap.input.should == [:getUser, {}] }
      end

      it "should set the target namespace with the default identifier" do
        namespace = 'xmlns:wsdl="http://v1_0.ws.auth.order.example.com/"'
        HTTPI::Request.any_instance.expects(:body=).with { |value| value.include? namespace }
        
        client.request :get_user
      end

      it "should not set the target namespace if soap.namespace was set to nil" do
        namespace = "http://v1_0.ws.auth.order.example.com/"
        HTTPI::Request.any_instance.expects(:body=).with { |value| !value.include?(namespace) }
        
        client.request(:get_user) { soap.namespace = nil }
      end
    end

    context "with a single argument (String)" do
      it "should set the input tag to result in <get_user>" do
        client.request("get_user") { soap.input.should == [:get_user, {}] }
      end
    end

    context "with a Symbol and a Hash" do
      it "should set the input tag to result in <getUser active='true'>" do
        client.request(:get_user, :active => true) { soap.input.should == [:getUser, { :active => true }] }
      end
    end

    context "with two Symbols" do
      it "should set the input tag to result in <wsdl:getUser>" do
        client.request(:v1, :get_user) { soap.input.should == [:v1, :getUser, {}] }
      end

      it "should set the target namespace with the given identifier" do
        namespace = 'xmlns:v1="http://v1_0.ws.auth.order.example.com/"'
        HTTPI::Request.any_instance.expects(:body=).with { |value| value.include? namespace }
        
        client.request :v1, :get_user
      end

      it "should not set the target namespace if soap.namespace was set to nil" do
        namespace = "http://v1_0.ws.auth.order.example.com/"
        HTTPI::Request.any_instance.expects(:body=).with { |value| !value.include?(namespace) }
        
        client.request(:v1, :get_user) { soap.namespace = nil }
      end
    end

    context "with two Symbols and a Hash" do
      it "should set the input tag to result in <wsdl:getUser active='true'>" do
        client.request(:wsdl, :get_user, :active => true) { soap.input.should == [:wsdl, :getUser, { :active => true }] }
      end
    end

    context "with a block expecting one argument" do
      it "should yield the SOAP object" do
        client.request(:authenticate) { |soap| soap.should be_a(Savon::SOAP::XML) }
      end
    end

    context "with a block expecting two arguments" do
      it "should yield the SOAP and WSDL objects" do
        client.request(:authenticate) do |soap, wsdl|
          soap.should be_a(Savon::SOAP::XML)
          wsdl.should be_an(Savon::WSDL::Document)
        end
      end
    end

    context "with a block expecting three arguments" do
      it "should yield the SOAP, WSDL and HTTP objects" do
        client.request(:authenticate) do |soap, wsdl, http|
          soap.should be_a(Savon::SOAP::XML)
          wsdl.should be_an(Savon::WSDL::Document)
          http.should be_an(HTTPI::Request)
        end
      end
    end

    context "with a block expecting four arguments" do
      it "should yield the SOAP, WSDL, HTTP and WSSE objects" do
        client.request(:authenticate) do |soap, wsdl, http, wsse|
          soap.should be_a(Savon::SOAP::XML)
          wsdl.should be_a(Savon::WSDL::Document)
          http.should be_an(HTTPI::Request)
          wsse.should be_a(Savon::WSSE)
        end
      end
    end

    context "with a block expecting no arguments" do
      it "should let you access the SOAP object" do
        client.request(:authenticate) { soap.should be_a(Savon::SOAP::XML) }
      end

      it "should let you access the HTTP object" do
        client.request(:authenticate) { http.should be_an(HTTPI::Request) }
      end

      it "should let you access the WSSE object" do
        client.request(:authenticate) { wsse.should be_a(Savon::WSSE) }
      end

      it "should let you access the WSDL object" do
        client.request(:authenticate) { wsdl.should be_a(Savon::WSDL::Document) }
      end
    end
  end

  context "with a remote WSDL document" do
    let(:client) { Savon::Client.new { wsdl.document = Endpoint.wsdl } }
    before { HTTPI.expects(:get).returns(new_response(:body => WSDLFixture.load)) }

    it "should return a list of available SOAP actions" do
      client.wsdl.soap_actions.should == [:authenticate]
    end

    it "adds a SOAPAction header containing the SOAP action name" do
      HTTPI.stubs(:post).returns(new_response)
      
      client.request :authenticate do
        http.headers["SOAPAction"].should == %{"authenticate"}
      end
    end

    it "should execute SOAP requests and return the response" do
      HTTPI.expects(:post).returns(new_response)
      response = client.request(:authenticate)
      
      response.should be_a(Savon::SOAP::Response)
      response.to_xml.should == ResponseFixture.authentication
    end
  end

  context "with a local WSDL document" do
    let(:client) { Savon::Client.new { wsdl.document = "spec/fixtures/wsdl/xml/authentication.xml" } } 

    before { HTTPI.expects(:get).never }

    it "should return a list of available SOAP actions" do
      client.wsdl.soap_actions.should == [:authenticate]
    end

    it "adds a SOAPAction header containing the SOAP action name" do
      HTTPI.stubs(:post).returns(new_response)
      
      client.request :authenticate do
        http.headers["SOAPAction"].should == %{"authenticate"}
      end
    end

    it "should execute SOAP requests and return the response" do
      HTTPI.expects(:post).returns(new_response)
      response = client.request(:authenticate)
      
      response.should be_a(Savon::SOAP::Response)
      response.to_xml.should == ResponseFixture.authentication
    end
  end

  context "without a WSDL document" do
    let(:client) do
      Savon::Client.new do
        wsdl.endpoint = Endpoint.soap
        wsdl.namespace = "http://v1_0.ws.auth.order.example.com/"
      end
    end

    before { HTTPI.expects(:get).never }

    it "raise an ArgumentError when trying to access the WSDL" do
      lambda { client.wsdl.soap_actions }.should raise_error(ArgumentError)
    end

    it "adds a SOAPAction header containing the SOAP action name" do
      HTTPI.stubs(:post).returns(new_response)
      
      client.request :authenticate do
        http.headers["SOAPAction"].should == %{"authenticate"}
      end
    end

    it "should execute SOAP requests and return the response" do
      HTTPI.expects(:post).returns(new_response)
      response = client.request(:authenticate)
      
      response.should be_a(Savon::SOAP::Response)
      response.to_xml.should == ResponseFixture.authentication
    end
  end

  context "when encountering a SOAP fault" do
    let(:client) do
      Savon::Client.new do
        wsdl.endpoint = Endpoint.soap
        wsdl.namespace = "http://v1_0.ws.auth.order.example.com/"
      end
    end

    before { HTTPI::expects(:post).returns(new_response(:code => 500, :body => ResponseFixture.soap_fault)) }

    it "should raise a Savon::SOAP::Fault" do
      lambda { client.request :authenticate }.should raise_error(Savon::SOAP::Fault)
    end
  end

  context "when encountering an HTTP error" do
    let(:client) do
      Savon::Client.new do
        wsdl.endpoint = Endpoint.soap
        wsdl.namespace = "http://v1_0.ws.auth.order.example.com/"
      end
    end

    before { HTTPI::expects(:post).returns(new_response(:code => 500)) }

    it "should raise a Savon::HTTP::Error" do
      lambda { client.request :authenticate }.should raise_error(Savon::HTTP::Error)
    end
  end

  def new_response(options = {})
    defaults = { :code => 200, :headers => {}, :body => ResponseFixture.authentication }
    response = defaults.merge options
    
    HTTPI::Response.new response[:code], response[:headers], response[:body]
  end

end
