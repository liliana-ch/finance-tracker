class UserStocksController < ApplicationController

  def create
    stock = Stock.check_db(params[:ticker])
    if stock.blank?
      stock = Stock.new_lookup(params[:ticker])
      stock.save
    end
    if current_user.can_track_stock?(params[:ticker])
      @user_stock = UserStock.create(user:current_user, stock: stock)
      flash[:notice] = "Stock #{stock.name} was successfully added to your portfolio"
      redirect_to my_portfolio_path
    else
      flash[:error] = if !current_user.under_stock_limit?
                        'You already tracked 10 stocked'
                      elsif current_user.stock_already_tracked?(@stock.ticker)
                        'You already tracked this stock'
                      end
      redirect_to my_portfolio_path
    end
  end

  def destroy
    stock = Stock.find(params[:id])
    user_stock = UserStock.where(user_id: current_user.id, stock_id: stock.id).first
    user_stock.destroy
    flash[:notice] = "#{stock.ticker} was successfully removed from portfolio"
    redirect_to my_portfolio_path
  end

end
