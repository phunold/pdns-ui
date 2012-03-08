require 'rubygems'
require 'sequel'

# Flow is DNS request/DNS response together
class Pdns < Sequel::Model

  # FIXME create data class for LAST_SEEN,FIRST_SEEN
  def date
  end

end
