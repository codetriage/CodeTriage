require 'json'
require 'uri'
require 'cgi'

module GitHubBub
  class Response < HTTParty::Response

     def self.create(response)
       response = self.new(response.request, response.response, response.parsed_response)
       response
     end

     def json_body
      ::JSON.parse(self.body)
     end

     def pagination
       @pagination ||= parse_pagination
     end

     def parsed_response
      response.body.inspect
     end

     def inspect
      inspect_id = "%x" % (object_id * 2)
      %(#<#{self.class}:0x#{inspect_id}, @response=#{response.inspect}, @headers=#{headers.inspect}>)
     end

     def next_url
       pagination['next_url']
     end

     def last_url
       pagination['last_url']
     end

     def first_url
       pagination['first_url']
     end

     def last_page?
       return true if next_url.nil?
       last_page_number = page_number_from_url(last_url)
       next_page_number = page_number_from_url(next_url)
       next_page_number >= last_page_number
     end

     def page_number_from_url(url)
       query = ::URI.parse(url).query
       ::CGI.parse(query)["page"].first.to_i
     end

     def parse_pagination
       header_links = self.headers['link'] ||  ""
       header_links.split(',').each_with_object({})do |element, hash|
         key   = element[/rel=["'](.*)['"]/, 1]
         value = element[/<(.*)>/, 1]
         hash["#{key}_url"] = value
       end
     end
   end
end