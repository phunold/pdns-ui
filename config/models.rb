require 'rubygems'
require 'sequel'

# database interaction
class Pdns < Sequel::Model

  # FIXME create data class for LAST_SEEN,FIRST_SEEN
  def date
  end

end

# uses virutal attributes to validate input from "advanced_search"
class Search < Sequel::Model
  attr_accessor :query, :answer, :first_seen, :last_seen
  plugin :validation_helpers
  def validate
    validates_presence [:query,:answer]
    validates_max_length 254, [:query,:answer]
    validates_format /\A\d\d\d\d-\d\d-\d\d\z/, [:first_seen,:last_seen]
    # custom validation for iso-format dates
    errors.add(:last_seen, 'cannot be before first seen date') if last_seen < first_seen
  end

  # obj.inspect returned nothing, this will help
  def inspect
    "#{first_seen} #{last_seen} #{query} #{answer}"
  end

end
