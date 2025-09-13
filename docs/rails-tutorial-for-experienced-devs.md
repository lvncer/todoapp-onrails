# Rails Tutorial for Experienced Developers 🚀

NextJS、Django 等のフレームワーク経験者向けの Rails 解説

## はじめに

このチュートリアルは、NextJS、Django、その他の Web フレームワークの経験があるあなたに向けて作成されました。Rails の「Convention over Configuration（設定より規約）」の哲学と、その具体的な実装について学んでいきましょう。

## 🏗 プロジェクト構造比較

### NextJS vs Rails

```text
# NextJS
pages/
  api/
  _app.js
  index.js
components/
styles/

# Rails
app/
  controllers/
  models/
  views/
config/
db/
```

**Rails 特有のポイント:**

- `app/`配下に MVC 全てが配置される
- `config/routes.rb`で一元的にルーティング管理
- `db/migrate/`でデータベーススキーマをバージョン管理

## 📊 MVC Architecture Deep Dive

### 1. Model (Active Record)

**Django の ORM との違い:**

```ruby
# Rails - Active Record Pattern
class Todo < ApplicationRecord
  validates :title, presence: true
  scope :completed, -> { where(completed: true) }

  def toggle_completed!
    update!(completed: !completed)
  end
end

# 使用例
Todo.completed              # SELECT * FROM todos WHERE completed = true
todo.toggle_completed!      # 即座にDBを更新
```

**重要な概念:**

- **Active Record Pattern**: モデル自体が DB 操作を持つ
- **Scopes**: 再利用可能なクエリメソッド
- **Bang methods** (`!`): 例外を発生させるメソッド
- **Callbacks**: `before_save`, `after_create`等のライフサイクルフック

### 2. Controller (Action Controller)

**NextJS API Routes との比較:**

```javascript
// NextJS
export default function handler(req, res) {
  if (req.method === "GET") {
    // GET logic
  }
  if (req.method === "POST") {
    // POST logic
  }
}
```

```ruby
# Rails - RESTful by design
class TodosController < ApplicationController
  before_action :set_todo, only: [:show, :edit, :update, :destroy]

  def index    # GET /todos
    @todos = Todo.recent
  end

  def create   # POST /todos
    @todo = Todo.new(todo_params)
    if @todo.save
      redirect_to @todo, notice: 'Success!'
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def todo_params
    params.require(:todo).permit(:title, :description, :completed)
  end
end
```

**Rails 独自の概念:**

- **RESTful routes**: 自動的に 7 つのアクションが生成される
- **Strong Parameters**: セキュリティのためのパラメータ制御
- **Instance variables** (`@todos`): ビューに自動的に渡される
- **before_action**: DRY なコード実現のためのフィルター

### 3. View (Action View)

**React/NextJS との違い:**

```jsx
// React/NextJS
const TodoList = ({ todos }) => {
  return (
    <div>
      {todos.map((todo) => (
        <div key={todo.id}>
          <h3>{todo.title}</h3>
          <button onClick={() => toggle(todo.id)}>Toggle</button>
        </div>
      ))}
    </div>
  );
};
```

```erb
<%# Rails ERB Template %>
<div class="todo-list">
  <% @todos.each do |todo| %>
    <div class="todo-item">
      <h3 class="<%= 'completed' if todo.completed? %>">
        <%= todo.title %>
      </h3>
      <%= button_to 'Toggle', toggle_todo_path(todo), method: :patch %>
    </div>
  <% end %>
</div>
```

**ERB の特徴:**

- `<% %>`: Ruby コード（出力なし）
- `<%= %>`: Ruby コード（出力あり）
- **Helpers**: `link_to`, `form_with`等の便利メソッド
- **Partials**: `render 'form'`で部分テンプレートを共有

## 🛣 Routing System

**NextJS の file-based routing との違い:**

```javascript
// NextJS - ファイルベース
pages/
  todos/
    index.js        // /todos
    [id].js         // /todos/:id
    new.js          // /todos/new
```

```ruby
# Rails - 設定ベース (config/routes.rb)
Rails.application.routes.draw do
  resources :todos do
    member do
      patch :toggle  # PATCH /todos/:id/toggle
    end
  end
  root 'todos#index'
end

# 自動生成されるルート:
# GET    /todos          todos#index
# GET    /todos/new      todos#new
# POST   /todos          todos#create
# GET    /todos/:id      todos#show
# GET    /todos/:id/edit todos#edit
# PATCH  /todos/:id      todos#update
# DELETE /todos/:id      todos#destroy
```

## 🗄 Database & Migrations

**Django との比較:**

```python
# Django models.py
class Todo(models.Model):
    title = models.CharField(max_length=200)
    completed = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
```

```ruby
# Rails migration
class CreateTodos < ActiveRecord::Migration[7.2]
  def change
    create_table :todos do |t|
      t.string :title
      t.boolean :completed, default: false
      t.timestamps  # created_at, updated_at を自動追加
    end
  end
end

# Rails model
class Todo < ApplicationRecord
  # テーブル名、カラムは自動推論
  # created_at, updated_at は自動管理
end
```

**Migration の利点:**

- **Version control**: データベーススキーマの変更履歴
- **Rollback**: `rails db:rollback`で前の状態に戻せる
- **Environment parity**: 開発・本番で同一スキーマ保証

## 🔧 Rails CLI & Generators

**Create React App との比較:**

```bash
# Create React App
npx create-react-app my-app
cd my-app
npm start

# Rails
rails new my-app
cd my-app
rails server
```

**Rails の強力な Generator:**

```bash
# モデル + マイグレーション + テスト生成
rails generate model Todo title:string completed:boolean

# コントローラー + ビュー + ルート生成
rails generate controller Todos index show new create

# 全部まとめて scaffold
rails generate scaffold Todo title:string description:text completed:boolean
```

## ⚡ 今回の Todo アプリの設計解説

### 1. Model 設計 (app/models/todo.rb)

```ruby
class Todo < ApplicationRecord
  # Validation - フロントエンドの検証と重複するがサーバーサイドでも必須
  validates :title, presence: true, length: { minimum: 1, maximum: 255 }

  # Scopes - 再利用可能なクエリ、SQLのWHERE句を抽象化
  scope :completed, -> { where(completed: true) }
  scope :pending, -> { where(completed: false) }
  scope :recent, -> { order(created_at: :desc) }

  # Instance methods - ビジネスロジックをモデルに集約
  def completed?
    completed  # boolean?メソッドは Rails の規約
  end

  def pending?
    !completed
  end

  def toggle_completed!
    update!(completed: !completed)  # ! は例外発生版
  end
end
```

**NextJS/React との設計思想の違い:**

- **Rails**: ビジネスロジックはモデル層に配置
- **React**: ビジネスロジックはコンポーネントや hooks に分散

### 2. Controller 設計 (app/controllers/todos_controller.rb)

```ruby
class TodosController < ApplicationController
  # DRY principle - 共通処理を1箇所に
  before_action :set_todo, only: [:show, :edit, :update, :destroy]

  def index
    @todos = Todo.recent  # scope使用、ビューで@todosとして利用可能
  end

  def create
    @todo = Todo.new(todo_params)

    if @todo.save
      # 成功時: リダイレクト + flash message
      redirect_to @todo, notice: 'Todo was successfully created.'
    else
      # 失敗時: フォーム再表示 + バリデーションエラー
      render :new, status: :unprocessable_entity
    end
  end

  private

  # Strong Parameters - Mass Assignment攻撃を防ぐ
  def todo_params
    params.require(:todo).permit(:title, :description, :completed)
  end
end
```

**RESTful 設計の美学:**

- 各アクションが明確な責任を持つ
- HTTP メソッドとアクションが 1:1 対応
- URL が予測可能（`/todos/123/edit`）

### 3. View 設計 (ERB Templates)

```erb
<!-- app/views/todos/index.html.erb -->
<% @todos.each do |todo| %>
  <div class="<%= 'completed' if todo.completed? %>">
    <%= link_to todo.title, todo_path(todo) %>

    <%= button_to toggle_todo_path(todo), method: :patch do %>
      <!-- SVGアイコン -->
    <% end %>
  </div>
<% end %>

<!-- 統計情報 -->
Total: <%= @todos.count %>
Completed: <%= @todos.completed.count %>
```

**React と ERB の違い:**

- **React**: JavaScript 内でマークアップ、state 管理が必要
- **ERB**: サーバーサイドで HTML 生成、フォーム送信ベース

### 4. Routing 設計 (config/routes.rb)

```ruby
resources :todos do
  member do
    patch :toggle  # /todos/:id/toggle
  end
end

root 'todos#index'  # localhost:3000 → todos#index
```

**生成されるルート一覧:**

```text
    todos GET    /todos          todos#index
          POST   /todos          todos#create
 new_todo GET    /todos/new      todos#new
edit_todo GET    /todos/:id/edit todos#edit
     todo GET    /todos/:id      todos#show
          PATCH  /todos/:id      todos#update
          DELETE /todos/:id      todos#destroy
toggle_todo PATCH /todos/:id/toggle todos#toggle
```

## 🚀 開発フロー

### 1. 基本的な開発サイクル

```bash
# 1. 新機能のためのブランチ作成
git checkout -b feature/user-auth

# 2. モデル生成 & マイグレーション
rails generate model User email:string
rails db:migrate

# 3. テスト駆動開発
rails test

# 4. コントローラー生成
rails generate controller Users

# 5. ルート追加
# config/routes.rb を編集

# 6. ビュー作成
# app/views/users/ 配下にERBファイル作成

# 7. 動作確認
rails server

# 8. テスト & デプロイ
rails test
git add . && git commit -m "Add user authentication"
```

### 2. デバッグ & 開発ツール

```bash
# Rails Console - Nodeの REPL 相当
rails console
> Todo.create(title: "Test todo")
> Todo.completed.count

# Database Console
rails dbconsole
mysql> SELECT * FROM todos;

# ログ確認
tail -f log/development.log

# Routes確認
rails routes | grep todos
```

### 3. よく使う Rails のデバッグテクニック

```ruby
# 1. binding.break でデバッガー起動
def create
  binding.break  # ここで実行停止
  @todo = Todo.new(todo_params)
end

# 2. Rails.logger でログ出力
def index
  Rails.logger.info "Loading todos: #{Time.current}"
  @todos = Todo.recent
end

# 3. raise でオブジェクト内容確認
def show
  raise @todo.inspect  # エラーページでオブジェクト内容表示
end
```

## 🔐 セキュリティ & ベストプラクティス

### 1. Rails セキュリティ機能

```ruby
# 1. Strong Parameters - 既に実装済み
def todo_params
  params.require(:todo).permit(:title, :description, :completed)
end

# 2. CSRF Protection - デフォルトで有効
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
end

# 3. SQL Injection 対策 - Active Record が自動対応
Todo.where(title: params[:title])  # 安全
Todo.where("title = '#{params[:title]}'")  # 危険！
```

### 2. バリデーション戦略

```ruby
# Model レベル（必須）
class Todo < ApplicationRecord
  validates :title, presence: true, length: { maximum: 255 }
  validates :description, length: { maximum: 1000 }
end

# フロントエンド（UX向上）
# JavaScript での即座フィードバック

# データベースレベル（最終防衛）
# マイグレーションでnull: false制約
```

## 🌐 本番環境への展開

### 1. 環境設定

```ruby
# config/database.yml
production:
  adapter: mysql2
  database: <%= ENV['DATABASE_NAME'] %>
  username: <%= ENV['DATABASE_USER'] %>
  password: <%= ENV['DATABASE_PASSWORD'] %>
  host: <%= ENV['DATABASE_HOST'] %>
```

### 2. アセット管理

```bash
# 本番用アセットビルド
rails assets:precompile

# 静的ファイル配信（Nginx等で）
# public/assets/ 配下のファイル
```

### 3. 環境変数管理

```ruby
# config/credentials.yml.enc（Rails 6+）
rails credentials:edit

# または .env ファイル + dotenv-rails gem
# .env
DATABASE_PASSWORD=secret123
SMTP_PASSWORD=mailgun_key
```

## 🎯 Next Steps

この Todo アプリをベースに以下の機能追加を検討してみてください：

### 1. ユーザー認証

```ruby
# Gem追加
gem 'devise'

# ユーザーモデル生成
rails generate devise User
```

### 2. API 化

```ruby
# API専用コントローラー
class Api::V1::TodosController < ApplicationController
  def index
    render json: Todo.all
  end
end
```

### 3. リアルタイム機能

```ruby
# Action Cable（WebSocket）
rails generate channel TodoChannel
```

### 4. テスト追加

```ruby
# RSpec + Factory Bot
gem 'rspec-rails'
gem 'factory_bot_rails'

# テスト例
describe Todo do
  it "validates presence of title" do
    todo = Todo.new(title: "")
    expect(todo).not_to be_valid
  end
end
```

### 5. パフォーマンス最適化

```ruby
# N+1クエリ対策
@todos = Todo.includes(:user).recent

# キャッシュ
class Todo < ApplicationRecord
  after_update :clear_cache

  private

  def clear_cache
    Rails.cache.delete("todos_count")
  end
end
```

## 📚 学習リソース

- [Rails Guides](https://guides.rubyonrails.org/) - 公式ドキュメント
- [Rails Tutorial](https://railstutorial.org/) - 詳細チュートリアル
- [GoRails](https://gorails.com/) - 実践的な動画コース
- [Ruby on Rails API](https://api.rubyonrails.org/) - API リファレンス

## 🚀 アプリケーション起動方法

### 前提条件

1. Docker Desktop が起動していること
2. ローカル MySQL が起動していること（port 3306）
3. MySQL に root ユーザーでアクセス可能であること

### 起動手順

```bash
# 1. リポジトリ移動
cd /Users/lvncer/GitRepos/todoapp-onrails

# 2. MySQL接続テスト（必要に応じて）
mysql -u root -p

# 3. 環境変数設定（MySQLにパスワードがある場合）
export MYSQL_PASSWORD=your_mysql_password

# 4. データベース作成 & マイグレーション
docker-compose run --rm web bundle exec rails db:create db:migrate

# 5. アプリケーション起動
docker-compose up web

# 6. ブラウザでアクセス
# http://localhost:3000
```

### トラブルシューティング

```bash
# データベース接続エラー時
# config/database.yml の設定確認
# ローカルMySQLの起動確認

# Dockerの問題時
docker-compose down
docker system prune -f
docker-compose up --build

# 権限エラー時
sudo chown -R $(whoami):$(whoami) .
```

---

Happy coding! 🎉

Rails の「Convention over Configuration」と「DRY (Don't Repeat Yourself)」の哲学を体感してください。何か質問があれば、Rails コミュニティは非常に友好的なので、遠慮なく質問してくださいね！
