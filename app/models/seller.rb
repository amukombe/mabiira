class Seller < ActiveRecord::Base
  has_many :products
  has_many :managers
  has_many :branches
  has_many :items
  
  attr_accessible :address, :name, :url, :link
  validates :name, :presence=>true, :uniqueness=>true
  validates :address,:url, :presence=>true

end
