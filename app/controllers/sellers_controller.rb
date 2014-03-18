class SellersController < ApplicationController
  layout 'user'
  before_filter :confirm_logged_in_admin
  # GET /sellers
  # GET /sellers.json
  def index
    unread

    @sellers = Seller.paginate :page=>params[:page], :order=>'name asc' , :per_page => 10

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @sellers }
    end
  end

  # GET /sellers/1
  # GET /sellers/1.json
  def show
    unread

    @seller = Seller.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @seller }
    end
  end

  # GET /sellers/new
  # GET /sellers/new.json
  def new
    unread

    @seller = Seller.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @seller }
    end
  end

  # GET /sellers/1/edit
  def edit
    unread

    @seller = Seller.find(params[:id])
  end

  # POST /sellers
  # POST /sellers.json
  def create
    unread

    @seller = Seller.new(params[:seller])

    respond_to do |format|
      if @seller.save
        format.html { redirect_to @seller, notice: 'Seller was successfully created.' }
        format.json { render json: @seller, status: :created, location: @seller }
      else
        format.html { render action: "new" }
        format.json { render json: @seller.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /sellers/1
  # PUT /sellers/1.json
  def update
    unread
    
    @seller = Seller.find(params[:id])

    respond_to do |format|
      if @seller.update_attributes(params[:seller])
        format.html { redirect_to @seller, notice: 'Seller was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @seller.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sellers/1
  # DELETE /sellers/1.json
  def destroy
    @seller = Seller.find(params[:id])
    @seller.destroy

    respond_to do |format|
      format.html { redirect_to sellers_url }
      format.json { head :no_content }
    end
  end

  def enable
    @seller = Seller.find(params[:id])

    if @seller.update_attribute(:enabled, false)
      flash[:notice] = "seller disabled"
      redirect_to :controller=>'sellers', :action=>'index'
    else
      flash[:notice] = "failed to submit order"
    end
  end
  def disable
    @seller = Seller.find(params[:id])

    if @seller.update_attribute(:enabled, true)
      flash[:notice] = "seller disabled"
      redirect_to :controller=>'sellers', :action=>'index'
    else
      flash[:notice] = "failed to submit order"
    end
  end

  def display
    unread
    @sellers = Seller.all

  end

  def branch
    unread
    #begin
      @seller = current_seller
      @sellerID = Seller.find(params[:seller_id])
      @branches = Branch.order.where(:seller_id=>@sellerID.id).paginate :page=>params[:page], :order=>'created_at desc' , :per_page => 15

    #rescue ActiveRecord::RecordNotFound
     # logger.error "Attempt to access invalid cart #{params[:id]}"
      #flash[:alert] = "Invalid seller"
      #redirect_to :controller=>'sellers',:action=>'display'
    #end
  end

end
