class User < ApplicationRecord
  has_many :user_stocks
  has_many :stocks, through: :user_stocks
  has_many :friendships
  has_many :inverse_friendships, class_name: "Friendship", :foreign_key => "friend_id"
  has_many :friends, class_name: "User",
                     through: :friendships
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  def stock_already_tracked?(ticker_symbol)
   stock = Stock.check_db(ticker_symbol)
   return false unless stock
   stocks.where(id: stock.id).exists?
  end

  def under_stock_limit?
    stocks.count < 10
  end

  def can_track_stock?(ticker_symbol)
   under_stock_limit? && !stock_already_tracked?(ticker_symbol)
  end

  def full_name
    return"#{first_name} #{last_name}" if first_name || last_name
    "Anonymous"
  end
  def friends
    friends_array = friendships.map{|friendship| friendship.friend}
    friends_array + inverse_friendships.map{|friendship| friendship.user}
    friends_array.compact
  end
end
