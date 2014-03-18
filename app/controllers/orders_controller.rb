class OrdersController < ApplicationController
  before_filter :confirm_logged_in_admin, :except => [:new, :create]
  # GET /orders
  # GET /orders.json
  layout 'admin'

  def index
    unread

    @orders = Order.paginate :page=>params[:page], :order=>'created_at desc' , :per_page => 10
    #@orders = Order.all
    @cart = current_cart
    #@line_items = LineItem.find(params[:order_id])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @orders }
    end
  end

  # GET /orders/1
  # GET /orders/1.json
  def show
    unread

    @order = Order.find(params[:id])
    @cart = current_cart
    @line_items = LineItem.find_by_order_id(@order)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @order }
    end
  end

  # GET /orders/new
  # GET /orders/new.json
  def new
    unread

    @cart = current_cart
    if @cart.line_items.empty?
      flash[:notice] = "Your cart is empty"
      redirect_to(:controller=>'store', :action=>'index')
      return
    end

    @order = Order.new
    @cart = current_cart
    @line_item = LineItem.find_by_cart_id(@cart)

    #getting branches
    supermarket = @line_item.product.seller.id
    @branches = Branch.find_all_by_seller_id(supermarket)

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @order }
    end
  end

  # GET /orders/1/edit
  def edit
    unread

    @order = Order.find(params[:id])
    @cart = current_cart
  end

  # POST /orders
  # POST /orders.json
  def create
    unread

    @cart = current_cart
    if @cart.line_items.empty?
      redirect_to :controller=>'main', :action=>'index', :notice => "Your cart is empty"
      return
    end


    @order = Order.new(params[:order])
    @order.add_line_items_from_cart(current_cart)

    @line_item = LineItem.find_by_cart_id(@cart)
    #getting branches
    supermarket = @line_item.product.seller.id
    @branches = Branch.find_all_by_seller_id(supermarket)

     #  ******* sending request to PegPay server ******************
  # call the http post method
      @date = "#{Time.now}"
      url = URI.parse('https://41.190.131.222/pegpaytelecomsapi/PegPayTelecomsApi.asmx?WSDL')
       
    post_xml ='<?xml version="1.0" encoding="utf-8"?>
    <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
      <soap:Body>
        <PostTransaction xmlns="http://PegPayTelecomsApi/">
          <trans>
            <DigitalSignature>'+ "#{digital_signature}" +'</DigitalSignature>
            <FromTelecom>'+ "#{@order.pay_type}" +'</FromTelecom>
            <ToTelecom>'+ "#{@order.pay_type}" +'</ToTelecom>
            <PaymentCode>1</PaymentCode>
            <VendorCode>MABIRA</VendorCode>
            <Password>81W30DI846</Password>
            <PaymentDate>'+ Date.today.strftime("%m/%d/%Y")  +'</PaymentDate>
            <Telecom></Telecom>
            <CustomerRef>'+"#{@order.phone_no}"+'</CustomerRef>
            <CustomerName>'+"#{@order.name}"+'</CustomerName>
            <TranAmount>'+"#{@cart.total_price}"+'</TranAmount>
            <TranCharge>0</TranCharge>
            <VendorTranId>1</VendorTranId>
            <ToAccount></ToAccount>
            <FromAccount>'+"#{@order.phone_no}"+'</FromAccount>
            <TranType>PULL</TranType>
          </trans>
        </PostTransaction>
      </soap:Body>
    </soap:Envelope>'

          peg_pay_status_code = make_http_request(url, post_xml)
            puts "status code============================================"           
              puts peg_pay_status_code
            puts "status code============================================"
  #  ******* end of sending request to yo! payments server ******************
           message=getTransactionStatus(peg_pay_status_code )
           message

      respond_to do |format|
        if peg_pay_status_code == 0
          if @order.save
            Cart.destroy(session[:cart_id])
            session[:cart_id] = nil
            Notifier.order_received(@order).deliver
            flash[:notice] = 'Thank you for your order.' 
            format.html { redirect_to(:controller=>'main', :action=>'index') }
            format.json { render json: @order, status: :created, location: @order }
          else
            format.html { render action: "new" }
            format.json { render json: @order.errors, status: :unprocessable_entity }
          end
        else
          flash[:notice]= message

          format.html { render action: "new" }
          format.json { render json: @order.errors, status: :unprocessable_entity }
        end
    end
  end

  def make_http_request(uri, post_xml)
    require 'net/http'
    require 'open-uri'

    peg_pay_status_code = ""
    conn = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.path)
       if uri.scheme == 'https'
        require 'net/https'
        conn.use_ssl = true
              conn.verify_mode = OpenSSL::SSL::VERIFY_NONE   # needed for windows environment
      end
    request.body=post_xml
    request.content_type = 'text/xml'
    response = conn.request(request)
    
    peg_pay_status_code = response.read_body
    peg_pay_status_code

  end
  def getTransactionStatus(statusCode)
    returnMessage=""
    if statusCode=="0"
            returnMessage="SUCCESS"
    else
      returnMessage= statusCode
    end
        
    return returnMessage
  end
  
  def update
    unread

    @order = Order.find(params[:id])

    respond_to do |format|
      if @order.update_attributes(params[:order])
        format.html { redirect_to @order, notice: 'Order was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  def digital_signature
    require 'openssl'
    @date = Date.today.strftime("%m/%d/%Y")
    text_to_sign = "#{@order.phone_no}" + "#{@order.name}" + "#{@order.pay_type}" + "#{@order.pay_type}" + "1" + "MABIRA" + "81W30DI846" + "#{@date}" + "PULL" + "1" + "#{@cart.total_price}" + "#{@order.phone_no}" + " "

    password = 'milk&honey@HOC'
    private_key = OpenSSL::PKey::RSA.new(IO::read('mabira_private_key.pem'), password)
    ciphertext = private_key.private_encrypt(text_to_sign)
    signed_text = [ciphertext].pack('m*')
    puts signed_text
    signed_text
  end
  # DELETE /orders/1
  # DELETE /orders/1.json
  def destroy
    @order = Order.find(params[:id])
    @order.destroy

    respond_to do |format|
      format.html { redirect_to orders_url }
      format.json { head :no_content }
    end
  end

  def status
    unread
    
    @order = Order.find(params[:id])

    if @order.update_attribute(:status, true)
      #flash[:notice] = "order successfully submitted"
      redirect_to :controller=>'items', :action=>'new', :id=>@order
    else
      flash[:notice] = "failed to submit order"
    end
  end
  
end
