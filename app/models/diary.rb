class Diary < ApplicationRecord
  belongs_to :user

  def feeling_japanese
    case feeling
    when "good"
      "良かった"
    when "normal"
      "普通"
    when "bad"
      "悪かった"
    end
  end
end
