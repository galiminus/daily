module VariationsHelper
  def current_monthly_budget
    @current_monthly_budget ||= @current_user.monthly_budget - @variations.map(&:monthly_value).sum
  end

  def current_daily_budget
    @current_daily_budget ||= @current_user.daily_budget(@date) - @current_user.variations.from_today(@date).map { |v| v.daily_value(@date) }.sum
  end

  def effective_daily_budget
    if current_daily_budget > 0
      current_daily_budget
    elsif saved_this_month < 0
      0
    else
      0
    end
  end

  def format_value(value)
    money = Money.new(value * 100, @current_user.currency)
    money.format(format: money.currency.to_s === "EUR" ? "%n %u" : "%u%n")
  end

  def format_budget_value(value, budget)
    if value < 0
      format_value(value.abs) + " overspent over #{format_value(budget)}"
    else
      format_value(value) + " remaining over #{format_value(budget)}"
    end
  end

  def saved_this_month
    @saved_this_month ||=
      if @date.day == 1
        0
      else
        (1..(@date.day - 1)).map do |day|
          @current_user.daily_budget(@date - day.days) - @current_user.variations.from_today(@date - day.days).map { |v| v.daily_value(@date - day.days) }.sum
        end.sum
      end
  end

  def overspent_daily_budget
    (current_daily_budget < 0 ? current_daily_budget.abs : 0)
  end

  def variations_for(recurring, range)
    if !recurring && range == 'this-month'
       @variations.where(recurring: false, base: true) + @variations.where(recurring: false, base: false).group_by(&:label).map do |label, variations|
        Variation.new(label: label, value: variations.map(&:value).sum)
      end
    else
      @variations.where(recurring: recurring)
    end
  end
end
