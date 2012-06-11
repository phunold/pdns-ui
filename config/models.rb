# database interaction
class Pdns < Sequel::Model

  # FIXME this is not very nice, there should be a better way
  # than comparing two strings YYYY-MM-DD
  def today?
    if self[:LAST_SEEN].strftime("%Y-%m-%d") == Date.today.to_s then
      true
    else
      false
    end
  end

end

# uses virutal attributes to validate input from "advanced_search"
class Search < Sequel::Model
  attr_accessor :query, :answer, :first_seen, :last_seen, :rr, :maptype
  def validate
    errors.add(:query, 'is not valid') unless query =~ /\A[\w\._-]{0,253}\z/
    errors.add(:answer, 'is not valid') unless answer =~ /\A[\w\._-]{0,253}\z/
    errors.add(:last_seen, 'To date is not valid') unless (last_seen =~ /\A\d\d\d\d-\d\d-\d\d\z/ || last_seen.empty?)
    errors.add(:first_seen, 'From date is not valid') unless (first_seen =~ /\A\d\d\d\d-\d\d-\d\d\z/ || first_seen.empty?)
    errors.add(:last_seen, 'cannot be before first seen date') if last_seen < first_seen
  end

  def construct_sql(s)
    # stitch together sql statement (logical AND)
    unless query.empty?
      if query =~ /^[0-9]{1,3}\./
        s = s.where(:QUERY.ilike("%#{query}%","%#{query.split(".").reverse.join(".")}%"))
      else
        s = s.where(:QUERY.ilike("%#{query}%")) 
      end
    end
    s = s.where(:ANSWER.ilike("%#{answer}%")) unless answer.empty?
    s = s.filter(:RR => rr) unless rr.empty?
    s = s.filter(:MAPTYPE => maptype) unless maptype.empty?
    s = s.filter(:FIRST_SEEN >= Date.parse(first_seen)) unless first_seen.empty?
    s = s.filter(:LAST_SEEN <= Date.parse(last_seen)) unless first_seen.empty?

    # Final sql statement
    s.reverse(:LAST_SEEN)
  end

  # obj.inspect returned nothing, this will help
  def inspect
    "#{first_seen} #{last_seen} #{query} #{answer} #{rr} #{maptype}"
  end

end
