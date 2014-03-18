class Product < ActiveRecord::Base
  default_scope :order => 'title'  
  attr_accessible :description, :image_url, :price, :title, :seller_id, :branch_id
  has_many :line_items
  has_many :orders, :through => :line_items
  belongs_to :seller
  belongs_to :branch
  before_destroy :ensure_not_referenced_by_any_line_item
  
  

  validates :title, :description, :image_url, :presence => true
  validates :price, :numericality => {:greater_than_or_equal_to => 0.01}
  validates :title, :uniqueness => true

  def ensure_not_referenced_by_any_line_item
  	if line_items.count.zero?
  	   return true
  	else
  	   errors.add(:base, 'Line Items present' )
  	   return false
  	end
  end

  def self.search(search)
    #return scoped unless search.present?
      where("title LIKE ?", "%#{search}%")
  end
end
