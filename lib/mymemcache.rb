# simplistic in-memory cache
class MyMemCache

  def initialize
    @cache = {}
    @cache_ttl = 60 # default expiration time(hardcoded I know!)
  end

  def get(key)
    return nil unless @cache.has_key? key
    # check if expired?
    return nil if @cache[key][1] + @cache_ttl < Time.now
    # else return cache content for this key
    return @cache[key][0]
  end

  def set(key,val)
    @cache[key] = [val,Time.now()]
    return val
  end

end
