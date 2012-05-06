# This is a lookup for city/post code
#
# Note: it allows duplication of city name to allow post code lookup
class Locality < ActiveRecord::Base
  CATEGORY_ID_TO_STRING = {
    0 => 'Unknown',
    1 => 'Delivery Area',
    2 => 'Post Office Boxes',
    3 => 'LVR'
  }
  
  CATEGORY_STRING_TO_ID = CATEGORY_ID_TO_STRING.invert
  CATEGORY_STRING_TO_ID[nil] = CATEGORY_STRING_TO_ID[''] = 0

  belongs_to :subdivision, :primary_key => :code, :foreign_key => :subdivision_code

  scope :non_lvr, where('category_id != 3')

  def self.find_matching_search(city)
    non_lvr.where(['LOWER(name) LIKE ?', city + '%']).order('name, subdivision_code, post_code')
  end

  def category_as_string
    CATEGORY_ID_TO_STRING[category_id]
  end
end
