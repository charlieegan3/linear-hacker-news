class HackerNewsScraper
  include Scraper
  def initialize
    @pages = [
      { url: 'https://news.ycombinator.com/over?points=10', count: 30 },
      { url: 'https://news.ycombinator.com/show', count: 15 }
    ]
  end

  def items
    [].tap do |items|
      @pages.each_with_index do |page, index|
        rows(page[:url], page[:count]).each do |link, details|
          (item = row_item(link, details, index)) ? items << item : next
        end
      end
    end
  end

  private

  def row_item(link, details, index)
    false if reject_item?(item = { title: link_title(link), url: link_url(link) })
    item.merge!({
      source: 'hacker_news', topped: (index == 0) ? true : false,
      comment_url: comment_url(details), word_count: word_count(item[:url]),
    })
  end

  def rows(url, count)
    Nokogiri::HTML(open(url), nil, 'UTF-8')
      .css('table')[2].css('tr')
      .reject { |tr| non_item_row?(tr) }
      .in_groups_of(2)
      .to_a
      .take(count)
  end

  def link_title(link)
    link.at_css('td:last-child a').text
  end

  def link_url(link)
    url = link.css('td:last-child a').first['href']
    relative_url?(url) ? url.prepend('https://news.ycombinator.com/') : url
  end

  def comment_url(details)
    if details.css('a')
      details.css('a').last['href'].prepend('https://news.ycombinator.com/')
    else
      ''
    end
  end

  def non_item_row?(tr)
    tr.text.blank? ||
      tr.text == 'More' ||
      tr.text.include?('Please read the rules')
  end

  def relative_url?(url)
    url[0...4] != 'http'
  end

  def reject_item?(item)
    (item[:title].downcase.include?('hiring') ||
      Item.find_by_url(item[:url])) ? true : false
  end
end