require 'net/http'
require 'uri'
require 'openssl'
require 'digest/sha2'

class Order < ActiveRecord::Base
  has_many :line_items, :dependent => :destroy
  belongs_to :item
  belongs_to :branch
  
  attr_accessor :phone_no, :total
  attr_accessible :address, :email, :name, :pay_type, :bought, :order_total, :phone_no, :delivery, :branch_id, :delivery_time
  
  EMAIL_REGEX = /^[A-Z0-9._%+-]+@[A-Z0-9._]+\.[A-Z]{2,4}$/i
  
  PAYMENT_TYPES = [ "MTN", "M-Sente" , "AIRTEL" ]
  validates :name, :delivery, :delivery_time, :pay_type, :phone_no, :branch_id, :presence => true
  validates :pay_type, :inclusion => PAYMENT_TYPES
  validates :email,:length=>{:maximum=>100}, :format=>EMAIL_REGEX,:confirmation=>true
  validates :phone_no,:confirmation=>true, :length=>{:minimum=>10, :maximum=>15}
  def add_line_items_from_cart(cart)
	cart.line_items.each do |item|
		item.cart_id = nil
		line_items << item
	end
   end
   #creating a digital signature
   def digtal_signature(name, phone_no, date)
     Digest::SHA2.hexdigest(name + "Ephesian 3:20. Now unto Him that is able ..." + phone_no + date)
   end
end
