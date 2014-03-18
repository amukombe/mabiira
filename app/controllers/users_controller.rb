class UsersController < ApplicationController
  layout 'user'
  before_filter :confirm_logged_in
  # GET /users
  # GET /users.json
  def index
    unread

    @users = User.paginate :page=>params[:page], :order=>'name asc' , :per_page => 10
    @role = Role.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    unread

    begin
      @user = User.find(params[:id])
      @role = Role.all
    rescue ActiveRecord::RecordNotFound
      flash[:notice] = "Attempt to access invalid user #{params[:id]}"
      redirect_to :action=>'index', :notice => 'Invalid user'
      #@user = User.find(params[:id])
      else
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @user }
      end
    end
    
  end

  # GET /users/new
  # GET /users/new.json
  def new
    unread

    @user = User.new
    @roles = Role.order(:title)

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/1/edit
  def edit
    unread

    @user = User.find(params[:id])
    @roles = Role.all
  end

  # POST /users
  # POST /users.json
  def create
    unread

    @user = User.new(params[:user])
    @roles = Role.all

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    unread
    
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user = User.find(params[:id])
    #@user.destroy

    begin
    @user.destroy
    flash[:notice] = "User #{@user.name} deleted"
    rescue Exception => e
    flash[:notice] = e.message
    end

    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end
end
