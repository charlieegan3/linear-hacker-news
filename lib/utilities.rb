require 'timeout'

module Utilities
  def final_url(redirect_url)
    begin
      return Timeout.timeout(2) {
        URI.open(redirect_url, allow_redirections: :all) do |resp|
          return resp.base_uri.to_s
        end
      }
    rescue
      return HTTPClient.new.get(redirect_url).header['Location'].first.to_s
    end
  end

  def word_count(url)
    begin
      return 0 if url.match(/\.(jpg|gif|png|pdf)$/)
      return Timeout.timeout(2) {
        Nokogiri::HTML(URI.open(url, allow_redirections: :all, read_timeout: 2), nil, 'UTF-8')
          .css('p')
          .text
          .gsub(/\s+/, ' ')
          .split(' ')
          .size
      }
    rescue
      return 0
    end
  end
end
