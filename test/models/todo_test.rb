require "test_helper"

class TodoTest < ActiveSupport::TestCase
  def setup
    @todo = Todo.new(title: "Test Todo", description: "Test description")
  end

  # バリデーションテスト
  test "should be valid with valid attributes" do
    assert @todo.valid?
  end

  test "should not be valid without title" do
    @todo.title = nil
    assert_not @todo.valid?
    assert_includes @todo.errors[:title], "can't be blank"
  end

  test "should not be valid with empty title" do
    @todo.title = ""
    assert_not @todo.valid?
    assert_includes @todo.errors[:title], "can't be blank"
  end

  test "should not be valid with title too long" do
    @todo.title = "a" * 256
    assert_not @todo.valid?
    assert_includes @todo.errors[:title], "is too long (maximum is 255 characters)"
  end

  # デフォルト値テスト
  test "should default completed to false" do
    @todo.save
    assert_equal false, @todo.completed
  end

  # インスタンスメソッドテスト
  test "completed? should return completion status" do
    @todo.completed = false
    assert_equal false, @todo.completed?

    @todo.completed = true
    assert_equal true, @todo.completed?
  end

  test "pending? should return opposite of completed" do
    @todo.completed = false
    assert_equal true, @todo.pending?

    @todo.completed = true
    assert_equal false, @todo.pending?
  end

  test "toggle_completed! should switch completion status" do
    @todo.save
    initial_status = @todo.completed?
    
    @todo.toggle_completed!
    assert_equal !initial_status, @todo.completed?
    
    @todo.toggle_completed!
    assert_equal initial_status, @todo.completed?
  end

  # スコープテスト
  test "completed scope should return only completed todos" do
    completed_todo = Todo.create!(title: "Completed", completed: true)
    pending_todo = Todo.create!(title: "Pending", completed: false)

    assert_includes Todo.completed, completed_todo
    assert_not_includes Todo.completed, pending_todo
  end

  test "pending scope should return only pending todos" do
    completed_todo = Todo.create!(title: "Completed", completed: true)
    pending_todo = Todo.create!(title: "Pending", completed: false)

    assert_includes Todo.pending, pending_todo
    assert_not_includes Todo.pending, completed_todo
  end

  test "recent scope should return todos in reverse chronological order" do
    # テスト用のTodoのみ作成
    Todo.delete_all  # 既存データをクリア
    
    sleep(0.1)  # 時間差を確実にするため
    todo1 = Todo.create!(title: "First Todo")
    sleep(0.1)  
    todo2 = Todo.create!(title: "Second Todo")
    
    recent_todos = Todo.recent
    # 新しいものが最初に来ることを確認
    assert_equal "Second Todo", recent_todos.first.title
    assert_equal "First Todo", recent_todos.last.title
  end
end
