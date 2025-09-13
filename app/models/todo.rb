class Todo < ApplicationRecord
  # バリデーション
  validates :title, presence: true, length: { minimum: 1, maximum: 255 }

  # スコープ（クエリを簡単にするため）
  scope :completed, -> { where(completed: true) }
  scope :pending, -> { where(completed: false) }
  scope :recent, -> { order(created_at: :desc) }

  # インスタンスメソッド
  def completed?
    completed
  end

  def pending?
    !completed
  end

  def toggle_completed!
    update!(completed: !completed)
  end
end
