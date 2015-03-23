class Item < ActiveRecord::Base
  validates_uniqueness_of :url

  before_save :truncate_title
  def truncate_title
    self.title = self.title[0..140] + '...' if self.title.length > 140
  end

  def self.matching(sources = ['hacker_news', 'reddit', 'product_hunt'])
    where(source: sources).
      limit(150).
      order(created_at: 'DESC')
  end

  def self.average_hour_count(sources)
    where(source: sources).
      where('created_at >= ?', Time.zone.now - 1.days).
      size / 24
  end
end
