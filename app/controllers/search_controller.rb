class SearchController < ApplicationController
  layout 'user'
  def index
  	#@products = Product.where("title LIKE ? ", params[:title])  
  	if params[:search]
	@products = Product.search(params[:search]).order("created_at DESC")
	else
	@articles = Product.order("created_at DESC")
	end
  end

  def self.search(search)
	  #return scoped unless search.present?
  		where("title LIKE ?", "%#{search}%")
	end
end
