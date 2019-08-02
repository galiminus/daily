module VariationsHelper
  def current_monthly_budget
    @current_user.monthly_budget - @variations.map(&:monthly_value).sum
  end

  def current_daily_budget
    @current_user.daily_budget - @variations.map(&:daily_value).sum
  end

  def format_value(value)
    money = Money.new(value * 100, @current_user.currency)
    money.format(symbol_position: money.currency.to_s === "EUR" ? :after : :before)
  end
end