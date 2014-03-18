class Cart < ActiveRecord::Base
  # attr_accessible :title, :body
  has_many :line_items, :dependent => :destroy

  def add_product(product_id)
	current_item = line_items.where(:product_id => product_id).first
		if current_item
		current_item.quantity += 1
		else
		current_item = line_items.build(:product_id => product_id)
		end
	current_item
	end

	def total_price
		line_items.to_a.sum { |item| item.total_price } + service_charge
	end

	def total_items
		line_items.sum(:quantity)
	end
	
	def service_charge
	  	service_fee = ''
	  	total = line_items.to_a.sum { |item| item.total_price }
	  	if total<=30000
	  		service_fee = 300
	  	elsif total<=60000
	  		service_fee = 400
	  	elsif total<=125000
	  		service_fee = 500
	  	elsif total<=250000
	  		service_fee = 600
	  	elsif total<=500000
	  		service_fee = 700
	  	elsif total<=1000000
	  		service_fee = 1000	
	  	else
	  		service_fee = 2000		
	  	end
	  	return service_fee
	end
end
