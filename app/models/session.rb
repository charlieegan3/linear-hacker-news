class Session < ActiveRecord::Base
  serialize :sources, Array
  serialize :saved_items, Array
  validates_uniqueness_of :identifier
  validates_presence_of :identifier
  before_save :default_values

  def default_values
    self.completed_to ||= Time.at(0)
  end

  def log(time)
    update(
      completed_to: (Time.now < time) ? Time.now : time,
      read_count: (read_count) ? read_count + 1 : 1
    )
  end

  def update_sources(source)
    sources.include?(source) ? sources.delete(source) : sources << source
    save
  end

  def completed_to_human
    return nil unless completed_to
    ApplicationController.helpers
      .distance_of_time_in_words(completed_to, Time.new)
  end

  def self.find_or_create(identifier)
    if identifier.blank?
      create(identifier: generate_identifier)
    else
      find_by_identifier(identifier) || create(identifier: identifier)
    end
  end

  def self.valid_session_parameter(param)
    if param.present? && param.match(/^[a-z]{,100}$/)
      true
    else
      false
    end
  end

  def self.generate_identifier
    RandomUsername.username.tap do |identifier|
      10.times do
        break unless Session.find_by_identifier(identifier)
        identifier = RandomUsername.username
      end
    end
  end
end
