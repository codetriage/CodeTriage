module GitHubBub
  class Response < HTTParty::Response

     def self.create(response)
       response = self.new(response.request, response.response, response.parsed_response)
       response.body = JSON.parse(response.body)
       response
     end

     def pagination
       @pagination ||= parse_pagination
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
       query = URI.parse(url).query
       CGI.parse(query)["page"].first.to_i
     end

     def parse_pagination
       self.headers['link'].split(',').each_with_object({}) do |element, hash|
         key   = element[/rel='(.*)'/, 1]
         value = element[/<(.*)>/, 1]
         hash["#{key}_url"] = value
       end
     end
   end
end