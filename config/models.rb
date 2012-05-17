# database interaction
class Pdns < Sequel::Model

  # FIXME create data class for LAST_SEEN,FIRST_SEEN
  def date
  end

end

# uses virutal attributes to validate input from "advanced_search"
class Search < Sequel::Model
  attr_accessor :query, :answer, :first_seen, :last_seen, :rr, :maptype
  def validate
    errors.add(:query, 'is not valid') unless query =~ /\A\w{0,253}\z/
    errors.add(:answer, 'is not valid') unless answer =~ /\A\w{0,253}\z/
    errors.add(:last_seen, 'To date is not valid') unless (last_seen =~ /\A\d\d\d\d-\d\d-\d\d\z/ || last_seen.empty?)
    errors.add(:first_seen, 'From date is not valid') unless (first_seen =~ /\A\d\d\d\d-\d\d-\d\d\z/ || first_seen.empty?)
    errors.add(:last_seen, 'cannot be before first seen date') if last_seen < first_seen
  end

  def construct_sql(s)
    # stitch together sql statement (logical AND)
    s = s.where(:QUERY.like("%#{query}%")) unless query.empty?
    s = s.where(:ANSWER.like("%#{answer}%")) unless answer.empty?
    s = s.filter(:RR => rr) unless rr.empty?
    s = s.filter(:MAPTYPE => maptype) unless maptype.empty?
    s = s.filter(:FIRST_SEEN >= Date.parse(first_seen)) unless first_seen.empty?
    s = s.filter(:LAST_SEEN <= Date.parse(last_seen)) unless first_seen.empty?

    # Final sql statement
    s.reverse_order(:LAST_SEEN)
  end


  # obj.inspect returned nothing, this will help
  def inspect
    "#{first_seen} #{last_seen} #{query} #{answer}"
  end

end
