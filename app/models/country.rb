class Country < ActiveRecord::Base
  def self.from_cache
    @@countries ||= Country.all
  end
end
