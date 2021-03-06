## 0.8.0.beta.2 (2010-11-05)

* Added Savon.response_pattern to automatically walk deeper into the SOAP response Hash when a
  pattern (specified as an Array of Regexps and Symbols) matches the response. If for example
  your response always looks like ".+Response/return" as in:

      <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
        <soap:Body>
          <ns2:authenticateResponse xmlns:ns2="http://v1_0.ws.user.example.com">
            <return>
              <some>thing</some>
            </return>
          </ns2:authenticateResponse>
        </soap:Body>
      </soap:Envelope>

  you could set the response pattern to:

      Savon.configure do |config|
        config.response_pattern = [/.+_response/, :return]
      end

  then instead of calling:

      response.to_hash[:authenticate_response][:return]  # :some => "thing"

  to get the actual content, Savon::SOAP::Response#to_hash will try to apply given the pattern:

      response.to_hash  # :some => "thing"

  Please notice, that if you don't specify a response pattern or if the pattern doesn't match the
  response, Savon will behave like it always did.

* Added Savon::SOAP::Response#to_array (which also uses the response pattern).

## 0.8.0.beta.1 (2010-10-29)

* Changed Savon::Client.new to accept a block instead of multiple Hash arguments. You can access the
  wsdl, http and wsse objects inside the block to configure your client for a particular service.

			# Instantiating a client to work with a WSDL document
      client = Savon::Client.new do
        wsdl.document = "http://example.com?wsdl"
      end

			# Directly accessing the SOAP endpoint
			client = Savon::Client.new do
        wsdl.endpoint = "http://example.com"
        wsdl.namespace = "http://v1.example.com"
      end

* Fix for issue #77 (Cache parsed WSDLs locally).
  You can now use local WSDL documents:

      client = Savon::Client.new do
        wsdl.document = "../wsdl/service.xml"
      end

* Changed the way SOAP requests are being dispatched. Instead of using method_missing, you now use
  the new #request method, which also accepts a block for you to access the wsdl, http, wsse and
  soap object. Please notice, that a new soap object is created for every request. So you can only
  access it inside this block.

      # A simple request to an :authenticate method
      client.request :authenticate do
        soap.body = { :id => 1 }
      end

* The new Savon::Client#request method fixes issues #37, #61 and #64, which report problems with
  namespacing the SOAP input tag and attaching attributes to it. Some usage examples:

      client.request :get_user                  # Input tag: <getUser>
      client.request :wsdl, "GetUser"           # Input tag: <wsdl:GetUser>
      client.request :get_user :active => true  # Input tag: <getUser active="true">

* Savon's new #request method respects the given namespace. If you don't give it a namespace,
  Savon will set the target namespace to "xmlns:wsdl". But if you do specify a namespace, it will
  be set to the given Symbol.

* Refactored Savon to use the new HTTPI (http://rubygems.org/gems/httpi) gem.
  HTTPI::Request replaces the Savon::Request, so please make sure to have a look
  at the HTTPI library and let me know about any problems. Using HTTPI actually
  fixes the following two issues.

* Savon now adds both "xmlns:xsd" and "xmlns:xsi" namespaces for you. Thanks Averell.
  It also properly serializes nil values as xsi:nil = "true".

* Fix for issue #24 (HTTP Digest Authentication).
  Instead of Net/HTTP, Savon now uses HTTPI to execute HTTP requests.
  HTTPI defaults to use HTTPClient which supports HTTP digest authentication.

* Fix for issue #76 (Config setting for WSDL-free operation).
  You now have to explicitly specify whether to use a WSDL document, when instantiating a client.

* Fix for issue #75 (Add response to SoapFault).
  Both Savon::SOAP::Fault and Savon::HTTP::Error now contain the HTTPI::Response.
  They also inherit from Savon::Error, making it easier to rescue both at the same time.

* Fix for issue #87 (Namespaced entries in the xml).
  Thanks to Leonardo Borges.

* Fix for issue #81 (irb on Ruby 1.9.2 doesn't disable wsdl).
  Replaced Savon::WSDL::Document#to_s with a #to_xml method.

* Fix for issues #85 and #88 (When gzip is enabled, binary data is logged).

* Fix for issue #80 (URI-reference is not quoted in Soapaction HTTP header).

* Fix for issue #60 (Savon::WSSE does not set wsu:Id attribute in wsse:UsernameToken tag).

* Fix for issue 96 (Savon doesn't guess upper_camelcased action).

* Removed global WSSE credentials. Authentication needs to be set up for each client instance.

* Started to remove quite a few core extensions.

## 0.7.9 (2010-06-14)

* Fix for issue #53 (<tt>DateTime#to_soap_value</tt> assumes UTC).

## 0.7.8 (2010-05-09)

* Fixed gemspec to include missing files in the gem.

## 0.7.7 (2010-05-09)

* SOAP requests now start with a proper XML declaration.

* Added support for gzipped requests and responses (http://github.com/lucascs). While gzipped SOAP
  responses are decoded automatically, you have to manually instruct Savon to gzip SOAP requests:

      client = Savon::Client.new "http://example.com/UserService?wsdl", :gzip => true

* Fix for issue #51. Added the :soap_endpoint option to <tt>Savon::Client.new</tt> which lets you
  specify a SOAP endpoint per client instance:

      client = Savon::Client.new "http://example.com/UserService?wsdl",
        :soap_endpoint => "http://localhost/UserService"

* Fix for issue #50. Savon still escapes special characters in SOAP request Hash values, but you can now
  append an exclamation mark to Hash keys specifying that it's value should not be escaped.

## 0.7.6 (2010-03-21)

* Moved documentation from the Github Wiki to the actual class files and established a much nicer
  documentation combining examples and implementation (using Hanna) at: http://savon.rubiii.com

* Added <tt>Savon::Client#call</tt> as a workaround for dispatching calls to SOAP actions  named after
  existing methods. Fix for issue #48.

* Add support for specifying attributes for duplicate tags (via Hash values as Arrays). Fix for issue #45.

* Fix for issue #41 (Escape special characters (e.g. &) for XML requests).

* Fix for issue #39 and #49. Added <tt>Savon::SOAP#xml</tt> which let's you specify completely custom
  SOAP request XML.

## 0.7.5 (2010-02-19)

* Fix for issue #34 (soap_actions returns empty for wsdl12).

* Fix for issue #36 (Custom WSDL actions broken).

* Added feature requested in issue #35 (Setting an attribute on an element?).

* Changed the key for specifying the order of tags from :@inorder to :order!

## 0.7.4 (2010-02-02)

* Fix for issue #33 (undefined method <tt>start_with?</tt>).

## 0.7.3 (2010-01-31)

* Added support for Geotrust-style WSDL documents (Julian Kornberger <github.corny@digineo.de>).

* Make HTTP requests include path and query only. This was breaking requests via proxy as scheme and host
  were repeated (Adrian Mugnolo <adrian@mugnolo.com>)

* Avoid warning on 1.8.7 and 1.9.1 (Adrian Mugnolo <adrian@mugnolo.com>).

* Fix for issue #29 (WSSE Created Bug?). Default to UTC to xs:dateTime value for WSSE authentication.

* Fix for issue #28 (Undefined Method ssl? on URI::Generic).

* Fix for issue #27 (http content-type defaults to utf-8). The Content-Type now defaults to UTF-8.

* Modification to allow assignment of an Array with an input name and an optional Hash of values to soap.input.
  Patches issue #30 (stanleydrew <andrewmbenton@gmail.com>).

* Fix for issue #25 (header-tag should not be sent if not set).

## 0.7.2 (2010-01-17)

* Exposed the Net::HTTP response (added by Kevin Ingolfsland). Use the "http" accessor (response.http) on your
  Savon::Response to access the <tt>Net::HTTP</tt> response object.

* Fix for issue #21 (savon is stripping ?SOAP off the end of WSDL locations).

* Fix for issue #22 (<tt>REXML::ParseException</tt> parsing 401 Unauthorized response body).

* Fix for issue #19 (Unable to set attribute in name-spaced WSSE password element).

* Added support for global header and namespaces. See issue #9 (Setting headers and namespaces).

## 0.7.1 (2010-01-10)

* The Hash of HTTP headers for SOAP calls is now public via <tt>Savon::Request#headers</tt>.
  Patch for: http://github.com/rubiii/savon/issues/#issue/8

## 0.7.0 (2010-01-09)

This version comes with several changes to the public API!
Pay attention to the following list and read the updated Wiki: http://wiki.github.com/rubiii/savon

* Changed how Savon::WSDL can be disabled. Instead of disabling the WSDL globally/per request via two
  different methods, you now simply append an exclamation mark (!) to your SOAP call: client.get_all_users!
  Make sure you know what you're doing because when the WSDL is disabled, Savon does not know about which
  SOAP actions are valid and just dispatches everything.

* The Net::HTTP object used by Savon::Request to retrieve WSDL documents and execute SOAP calls is now public.
  While this makes the library even more flexible, it also comes with two major changes:

  * SSL client authentication needs to be defined directly on the <tt>Net::HTTP</tt> object:

      client.request.http.client_cert = ...

    I added a shortcut method for setting all options through a Hash similar to the previous implementation:

      client.request.http.ssl_client_auth :client_cert => ...

  * Open and read timeouts also need to be set on the <tt>Net::HTTP</tt> object:
  
      client.request.http.open_timeout = 30
      client.request.http.read_timeout = 30

  * Please refer to the <tt>Net::HTTP</tt> documentation for more details:
    http://www.ruby-doc.org/stdlib/libdoc/net/http/rdoc/index.html

* Thanks to JulianMorrison, Savon now supports HTTP basic authentication:

    client.request.http.basic_auth "username", "password"

* Julian also added a way to explicitly specify the order of Hash keys and values, so you should now be able
  to work with services requiring a specific order of input parameters while still using Hash input.

      client.find_user { |soap| soap.body = { :name => "Lucy", :id => 666, :@inorder => [:id, :name] } }

* <tt>Savon::Response#to_hash</tt> now returns the content inside of "soap:Body" instead of trying to go one
  level deeper and return it's content. The previous implementation only worked when the "soap:Body" element
  contained a single child. See: http://github.com/rubiii/savon/issues#issue/17

* Added <tt>Savon::SOAP#namespace</tt> as a shortcut for setting the "xmlns:wsdl" namespace.

    soap.namespace = "http://example.com"

## 0.6.8 (2010-01-01)

* Improved specifications for various kinds of WSDL documents.

* Added support for SOAP endpoints which are different than the WSDL endpoint of a service.

* Changed how SOAP actions and inputs are retrieved from the WSDL documents. This might break a few existing
  implementations, but makes Savon work well with even more services. If this change breaks your implementation,
  please take a look at the +action+ and +input+ methods of the <tt>Savon::SOAP</tt> object.
  One specific problem I know of is working with the createsend WSDL and its namespaced actions.

  To make it work, call the SOAP action without namespace and specify the input manually:

      client.get_api_key { |soap| soap.input = "User.GetApiKey" }

## 0.6.7 (2009-12-18)

* Implemented support for a proxy server. The proxy URI can be set through an optional Hash of options passed
  to instantiating <tt>Savon::Client</tt> (Dave Woodward <dave@futuremint.com>)

* Implemented support for SSL client authentication. Settings can be set through an optional Hash of arguments
  passed to instantiating <tt>Savon::Client</tt> (colonhyphenp)

* Patch for issue #10 (Problem with operation tags without a namespace).

## 0.6.6 (2009-12-14)

* Default to use the name of the SOAP action (the method called in a client) in lowerCamelCase for SOAP action
  and input when Savon::WSDL is disabled. You still need to specify soap.action and maybe soap.input in case
  your SOAP actions are named any different.

## 0.6.5 (2009-12-13)

* Added an <tt>open_timeout</tt> method to <tt>Savon::Request</tt>.

## 0.6.4 (2009-12-13)

* Refactored specs to be less unit-like.

* Added a getter for the <tt>Savon::Request</tt> to <tt>Savon::Client</tt> and a read_timeout setter for HTTP requests.

* wsdl.soap_actions now returns an Array of SOAP actions. For the previous "mapping" please use <tt>wsdl.operations</tt>.

* Replaced WSDL document with stream parsing.

    Benchmarks (1000 SOAP calls):
    
           user        system     total       real
    0.6.4  72.180000   8.280000   80.460000   (750.799011)
    0.6.3  192.900000  19.630000  212.530000  (914.031865)

## 0.6.3 (2009-12-11)

* Removing 2 ruby deprecation warnings for parenthesized arguments. (Dave Woodward <dave@futuremint.com>)

* Added global and per request options for disabling <tt>Savon::WSDL</tt>.

    Benchmarks (1000 SOAP calls):
    
                   user        system     total       real
    WSDL           192.900000  19.630000  212.530000  (914.031865)
    disabled WSDL  5.680000    1.340000   7.020000    (298.265318)

* Improved XPath expressions for parsing the WSDL document.

    Benchmarks (1000 SOAP calls):
    
           user        system     total       real
    0.6.3  192.900000  19.630000  212.530000  (914.031865)
    0.6.2  574.720000  78.380000  653.100000  (1387.778539)

## 0.6.2 (2009-12-06)

* Added support for changing the name of the SOAP input node.

* Added a CHANGELOG.

## 0.6.1 (2009-12-06)

* Fixed a problem with WSSE credentials, where every request contained a WSSE authentication header.

## 0.6.0 (2009-12-06)

* method_missing now yields the SOAP and WSSE objects to a given block.

* The response_process (which previously was a block passed to method_missing) was replaced by <tt>Savon::Response</tt>.

* Improved SOAP action handling (another problem that came up with issue #1).

## 0.5.3 (2009-11-30)

* Patch for issue #2 (NoMethodError: undefined method <tt>invalid!</tt> for <tt>Savon::WSDL</tt>)

## 0.5.2 (2009-11-30)

* Patch for issue #1 (Calls fail if api methods have periods in them)

## 0.5.1 (2009-11-29)

* Optimized default response process.

* Added WSSE settings via defaults.

* Added SOAP fault and HTTP error handling.

* Improved documentation

* Added specs

## 0.5.0 (2009-11-29)

* Complete rewrite and public release.
