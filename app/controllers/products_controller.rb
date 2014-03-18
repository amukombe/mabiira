class ProductsController < ApplicationController
  layout 'user'
  before_filter :confirm_logged_in_admin, :except=>[:index, :status_remove, :status_add]
  # GET /products
  # GET /products.json
  #layout 'admin'
  def index
    unread
    if session[:role] == 'Manager'
      branch_id = session[:branch_id]
      @branch = Branch.find_by_id(branch_id)
      @products = Product.find_all_by_branch_id(params[:branch_id])
    else
      @branch = Branch.find(params[:branch_id])
      @products = Product.find_all_by_branch_id(params[:branch_id])
    end
    #@products = Product.paginate :page=>params[:page], :order=>'created_at desc' , :per_page => 10

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @products }
    end
  end

  # GET /products/1
  # GET /products/1.json
  def show
    unread

    @product = Product.find(params[:id])
    #seller = Seller.find(params[:seller_id])
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @product }
    end
  end

  # GET /products/new
  # GET /products/new.json
  def new
    unread

    @product = Product.new
    @sellers = Seller.order('sellers.name ASC')
    @branches = Branch.order('branches.branch_name ASC')


    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @product }
    end
  end

  # GET /products/1/edit
  def edit
    unread

    @product = Product.find(params[:id])
    sellerID = @product.seller_id
    @sellers = Seller.all
    @branches = Branch.order('branches.branch_name ASC')
  end

  # POST /products
  # POST /products.json
  def create
    unread

    @product = Product.new(params[:product])
    @sellers = Seller.all
    @branches = Branch.all

    respond_to do |format|
      if @product.save
        format.html { redirect_to @product, notice: 'Product was successfully created.' }
        format.json { render json: @product, status: :created, location: @product }
      else
        format.html { render action: "new" }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /products/1
  # PUT /products/1.json
  def update
    unread

    @product = Product.find(params[:id])
    @sellers = Seller.all
    @branches = Branch.all

    respond_to do |format|
      if @product.update_attributes(params[:product])
        format.html { redirect_to @product, notice: 'Product was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1
  # DELETE /products/1.json
  def destroy
    unread

    @product = Product.find(params[:id])
    @product.destroy

    respond_to do |format|
      format.html { redirect_to products_url }
      format.json { head :no_content }
    end
  end

  def who_bought
    unread
    
    @product = Product.find(params[:id])
    respond_to do |format|
    format.atom
    format.xml { render :xml => @product }
    end
  end

  def search
    
  end

  def status_remove
    unread
    
    @product = Product.find(params[:id])
    @branchID = @product.branch_id

    if @product.update_attribute(:availability, false)
      flash[:notice] = "product successfully removed"
      redirect_to :controller=>'products', :action=>'index', :branch_id=>@branchID
    else
      flash[:notice] = "failed to submit order"
    end
  end

  def status_add
    unread
    
    @product = Product.find(params[:id])
    @branchID = @product.branch_id
    
    if @product.update_attribute(:availability, true)
      flash[:notice] = "product successfully removed"
      redirect_to :controller=>'products', :action=>'index', :id=>@branchID
    else
      flash[:notice] = "failed to submit order"
    end
  end

end
