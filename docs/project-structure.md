# Rails Todo アプリ - プロジェクト構造解説

このドキュメントでは、Rails Todo アプリケーションのディレクトリ構造と各ファイルの役割について説明します。

## 📁 プロジェクト全体構成

```text
todoapp-onrails/
├── app/                # アプリケーションの核となるディレクトリ
├── bin/                # 実行可能スクリプト
├── config/             # 設定ファイル
├── db/                 # データベース関連
├── docs/               # プロジェクトドキュメント
├── lib/                # カスタムライブラリ
├── log/                # ログファイル
├── public/             # 静的ファイル（画像、CSS、JSなど）
├── storage/            # Active Storage ファイル
├── test/               # テストファイル
├── tmp/                # 一時ファイル
├── vendor/             # サードパーティライブラリ
├── docker-compose.yml  # Docker Compose設定
├── Dockerfile          # 本番用Dockerイメージ設定
├── Dockerfile.dev      # 開発用Dockerイメージ設定
├── Gemfile             # Ruby gem依存関係
├── Gemfile.lock        # gem の固定バージョン
└── README.md           # プロジェクト概要
```

## 🎯 app/ ディレクトリ（MVC の核心部分）

### app/controllers/ - コントローラー層

```text
app/controllers/
├── application_controller.rb  # 全コントローラーの基底クラス
└── todos_controller.rb        # Todo の CRUD 操作を制御
```

**todos_controller.rb の役割:**

- HTTP リクエストを受け取る
- ビジネスロジックを実行（モデル経由）
- レスポンスを返す（ビュー描画 or リダイレクト）

**主要メソッド:**

- `index` - Todo 一覧表示
- `show` - Todo 詳細表示
- `new` - 新規作成フォーム表示
- `create` - Todo 作成処理
- `edit` - 編集フォーム表示
- `update` - Todo 更新処理
- `destroy` - Todo 削除処理
- `toggle` - 完了状態切り替え（カスタムアクション）

### app/models/ - モデル層

```text
app/models/
├── application_record.rb  # 全モデルの基底クラス
└── todo.rb                # Todo モデル（ビジネスロジック）
```

**todo.rb の機能:**

- データベーステーブル `todos` とのマッピング
- バリデーション（データ検証）
- スコープ（便利なクエリメソッド）
- インスタンスメソッド（ビジネスロジック）

**実装されている機能:**

```ruby
# バリデーション
validates :title, presence: true, length: { minimum: 1, maximum: 255 }

# スコープ
scope :completed, -> { where(completed: true) }
scope :pending, -> { where(completed: false) }
scope :recent, -> { order(created_at: :desc) }

# インスタンスメソッド
def completed?           # 完了状態確認
def pending?             # 未完了状態確認
def toggle_completed!    # 完了状態切り替え
```

### app/views/ - ビュー層

```text
app/views/
├── layouts/
│   └── application.html.erb  # 共通レイアウト
└── todos/
    ├── index.html.erb        # Todo 一覧画面
    ├── show.html.erb         # Todo 詳細画面
    ├── new.html.erb          # Todo 作成画面
    ├── edit.html.erb         # Todo 編集画面
    └── _form.html.erb        # フォーム部分テンプレート
```

**ERB テンプレートの特徴:**

- `<% %>` : Ruby コード実行（出力なし）
- `<%= %>` : Ruby コード実行（出力あり）
- 部分テンプレート（`_form.html.erb`）でコードの再利用

**Tailwind CSS の活用:**

- モダンな UI デザイン
- レスポンシブデザイン
- NextJS ライクな見た目

## ⚙️ config/ ディレクトリ（設定管理）

### 重要な設定ファイル

**config/routes.rb** - ルーティング設定

```ruby
resources :todos do
  member do
    patch :toggle  # /todos/:id/toggle
  end
end
root 'todos#index'
```

**config/database.yml** - データベース接続設定

```yaml
default: &default
  adapter: mysql2
  host: <%= ENV.fetch("DB_HOST") { "localhost" } %>
  password: <%= ENV.fetch("MYSQL_PASSWORD") { "" } %>
```

**config/application.rb** - アプリケーション基本設定

- タイムゾーン
- ロケール
- 自動読み込みパス

**config/environments/** - 環境別設定

- `development.rb` - 開発環境
- `production.rb` - 本番環境
- `test.rb` - テスト環境

## 🗄 db/ ディレクトリ（データベース）

```text
db/
├── migrate/
│   └── 20250913091630_create_todos.rb  # マイグレーションファイル
├── schema.rb                           # 現在のDB構造
└── seeds.rb                            # 初期データ投入スクリプト
```

**マイグレーションファイルの役割:**

- データベーススキーマのバージョン管理
- テーブル作成・変更・削除の履歴
- チーム開発での DB 状態統一

**todos テーブル構造:**

```ruby
create_table :todos do |t|
  t.string :title                       # タイトル
  t.text :description                   # 説明
  t.boolean :completed, default: false  # 完了フラグ
  t.timestamps                          # created_at, updated_at
end
```

## 🐳 Docker 関連ファイル

### docker-compose.yml - 開発環境構築

```yaml
services:
  web: # Rails アプリコンテナ
    build:
      context: .
      dockerfile: Dockerfile.dev # 開発用 Dockerfile 使用
    ports:
      - "3000:3000" # ポートフォワーディング
    volumes:
      - .:/rails # ソースコード同期
    environment:
      - DB_HOST=host.docker.internal # Mac 用 MySQL 接続
```

### Dockerfile.dev - 開発用コンテナ設定

```dockerfile
FROM ruby:3.2.9
# 必要パッケージインストール
# Gemfile インストール
# アプリケーションコピー
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
```

### Dockerfile - 本番用コンテナ設定（マルチステージビルド）

- 最適化されたイメージサイズ
- セキュリティ強化（非 root ユーザー）
- アセットプリコンパイル

## 📦 依存関係管理

### Gemfile - Ruby ライブラリ定義

```ruby
gem "rails", "~> 7.2.2"   # Rails フレームワーク
gem "mysql2", "~> 0.5"    # MySQL アダプター
gem "puma", ">= 6.0"      # Web サーバー
gem "tailwindcss-rails"   # CSS フレームワーク（予定）
gem "turbo-rails"         # SPA ライクな体験
gem "stimulus-rails"      # JavaScript フレームワーク
```

### Gemfile.lock - バージョン固定

- 本番環境との一貫性保証
- 依存関係の完全なスナップショット

## 🚀 実行・ログディレクトリ

### bin/ - 実行スクリプト

- `bin/rails` - Rails CLI
- `bin/docker-entrypoint` - Docker エントリーポイント

### log/ - アプリケーションログ

- `development.log` - 開発環境のログ
- SQL クエリ、リクエスト処理時間等を記録

### tmp/ - 一時ファイル

- キャッシュ、セッションファイル
- PID ファイル

## 🌐 公開ディレクトリ

### public/ - 静的アセット

```text
public/
├── 404.html       # エラーページ
├── 422.html
├── 500.html
├── robots.txt     # SEO 設定
├── icon.png       # ファビコン
└── manifest.json  # PWA 設定
```

## 📁 その他のディレクトリ

### test/ - テストファイル

```text
test/
├── controllers/  # コントローラーテスト
├── models/       # モデルテスト
├── fixtures/     # テストデータ
└── system/       # システムテスト（E2E）
```

### lib/ - カスタムライブラリ

- アプリ固有のライブラリコード
- タスク定義

### vendor/ - サードパーティライブラリ

- gem 以外の外部ライブラリ

## 🔧 Rails の規約

### ファイル命名規約

- モデル: `Todo` → `app/models/todo.rb`
- コントローラー: `TodosController` → `app/controllers/todos_controller.rb`
- ビュー: `todos/index.html.erb`

### URL 規約（RESTful）

```text
GET     /todos           # index    一覧
GET     /todos/new       # new      新規フォーム
POST    /todos           # create   作成
GET     /todos/:id       # show     詳細
GET     /todos/:id/edit  # edit     編集フォーム
PATCH   /todos/:id       # update   更新
DELETE  /todos/:id       # destroy  削除
```

### データベース規約

- テーブル名: 複数形（`todos`）
- モデル名: 単数形（`Todo`）
- 主キー: `id`
- 外部キー: `モデル名_id`
- タイムスタンプ: `created_at`, `updated_at`

## 💡 開発のワークフロー

1. **モデル作成**: `rails generate model Todo title:string`
2. **マイグレーション実行**: `rails db:migrate`
3. **コントローラー作成**: `rails generate controller Todos`
4. **ルーティング追加**: `config/routes.rb` 編集
5. **ビュー作成**: `app/views/todos/` ディレクトリにファイル作成

## 🎯 このアプリの特徴

- **RESTful 設計**: 標準的な Rails 規約に準拠
- **レスポンシブ UI**: Tailwind CSS による現代的なデザイン
- **Docker 対応**: 簡単な環境構築
- **MySQL 連携**: ローカル DB との接続
- **バリデーション**: データ整合性の保証
- **スコープ活用**: 効率的なクエリ

このプロジェクト構造を理解することで、Rails アプリケーションの全体像と、各コンポーネントがどのように連携しているかが分かります。
