# Rails Todo アプリ - セットアップ & 起動ガイド

このドキュメントでは、Rails Todo アプリケーションのセットアップから起動までの手順を詳しく説明します。

## 🚀 クイックスタート

すぐに動作確認したい方向けの最速手順です。

```bash
# 1. リポジトリクローン
git clone <repository-url>
cd todoapp-onrails

# 2. MySQL パスワード設定（必要に応じて）
echo "MYSQL_PASSWORD=your_mysql_password" > .env

# 3. Docker でアプリ起動
docker-compose build
docker-compose run --rm web bundle exec rails db:create db:migrate
docker-compose up web

# 4. ブラウザでアクセス
# http://localhost:3000
```

## 📋 前提条件

以下のソフトウェアがインストールされている必要があります。

### 必須環境

- **Docker Desktop** (v20.10 以上)
- **MySQL** (v8.0 推奨、ローカルで稼働中)
- **Git**

### 動作確認環境

- macOS (Intel & Apple Silicon 対応)
- MySQL 8.0
- Docker Desktop for Mac

## 🛠 詳細セットアップ手順

### Step 1: 環境確認

```bash
# Docker の動作確認
docker --version
docker-compose --version

# MySQL の動作確認
mysql -u root -p -e "SELECT 'MySQL is running' as status;"
```

**期待される出力:**

```
Docker version 28.3.2
docker-compose version 2.27.0

+-------------------+
| status            |
+-------------------+
| MySQL is running  |
+-------------------+
```

### Step 2: プロジェクト取得

```bash
# プロジェクトをクローン
git clone <repository-url>
cd todoapp-onrails

# ディレクトリ構造確認
ls -la
```

### Step 3: 環境変数設定

MySQL のパスワード設定方法を選択してください。

#### 方法 A: .env ファイル使用（推奨）

```bash
# .env ファイルを作成
echo "MYSQL_PASSWORD=your_actual_password" > .env

# .env ファイル確認
cat .env
```

#### 方法 B: 環境変数で直接設定

```bash
# シェルセッション中で設定
export MYSQL_PASSWORD=your_actual_password

# 確認
echo $MYSQL_PASSWORD
```

#### 方法 C: パスワードなしの場合

```bash
# パスワード無しの MySQL の場合
echo "MYSQL_PASSWORD=" > .env
```

### Step 4: Docker イメージビルド

```bash
# 開発用 Docker イメージをビルド
docker-compose build

# ビルド成功確認
docker images | grep todoapp-onrails
```

**期待される出力:**

```
todoapp-onrails-web    latest    bbf52141e46c   2 minutes ago   1.2GB
```

### Step 5: データベースセットアップ

```bash
# データベース作成とマイグレーション実行
docker-compose run --rm web bundle exec rails db:create db:migrate

# 成功時のメッセージ例:
# Created database 'todoapp_development'
# Created database 'todoapp_test'
# == CreateTodos: migrating ======================================
# -- create_table(:todos)
#    -> 0.0088s
# == CreateTodos: migrated (0.0088s) =============================
```

### Step 6: アプリケーション起動

```bash
# Rails サーバー起動（フォアグラウンド）
docker-compose up web

# または、バックグラウンド起動
docker-compose up -d web
```

**起動成功のログ例:**

```
web-1  | => Booting Puma
web-1  | => Rails 7.2.2.2 application starting in development
web-1  | => Run `bin/rails server --help` for more startup options
web-1  | Puma starting in single mode...
web-1  | * Environment: development
web-1  | * Listening on http://0.0.0.0:3000
```

### Step 7: 動作確認

1. ブラウザで `http://localhost:3000` にアクセス
2. Todo アプリのホーム画面が表示されることを確認
3. 基本機能をテスト:
   - 新しい Todo の作成
   - Todo の編集
   - 完了状態の切り替え
   - Todo の削除

## 🔧 開発環境での操作

### よく使うコマンド

```bash
# Rails コンソール起動
docker-compose exec web bundle exec rails console

# データベースコンソール
docker-compose exec web bundle exec rails dbconsole

# マイグレーション実行
docker-compose exec web bundle exec rails db:migrate

# ルート確認
docker-compose exec web bundle exec rails routes

# ログ確認
docker-compose logs web

# コンテナ停止
docker-compose down

# 完全クリーンアップ（データも削除）
docker-compose down -v
```

### 新しい機能開発の流れ

```bash
# 1. モデル生成（例：User モデル）
docker-compose exec web bundle exec rails generate model User name:string email:string

# 2. マイグレーション実行
docker-compose exec web bundle exec rails db:migrate

# 3. コントローラー生成
docker-compose exec web bundle exec rails generate controller Users

# 4. ルートの追加（config/routes.rb を編集）
# 5. ビューファイル作成（app/views/users/）
# 6. 動作確認
```

## 🐛 トラブルシューティング

### よくある問題と解決方法

#### 1. MySQL 接続エラー

```
Error: Access denied for user 'root'@'localhost'
```

**解決方法:**

- パスワードが正しく設定されているか確認
- MySQL が起動しているか確認
- `host.docker.internal` が解決できているか確認

```bash
# MySQL 接続テスト
mysql -u root -p -h localhost -e "SELECT 1"

# Docker から MySQL への接続テスト
docker run --rm -it mysql:8.0 mysql -h host.docker.internal -u root -p
```

#### 2. Docker ビルドエラー

```
Error: failed to solve: process "/bin/sh -c bundle install"
```

**解決方法:**

```bash
# Docker キャッシュクリア
docker system prune -a

# 再ビルド
docker-compose build --no-cache
```

#### 3. ポート競合エラー

```
Error: Port 3000 is already in use
```

**解決方法:**

```bash
# 使用中のプロセス確認
lsof -i :3000

# プロセス終了
kill -9 <PID>

# または異なるポート使用
# docker-compose.yml で "3001:3000" に変更
```

#### 4. 権限エラー

```
Error: Permission denied
```

**解決方法:**

```bash
# ディレクトリの所有権を変更
sudo chown -R $(whoami):$(whoami) .

# または Docker を root 以外で実行
sudo usermod -aG docker $USER
```

### ログの確認方法

```bash
# Rails アプリケーションログ
docker-compose logs web

# リアルタイムログ監視
docker-compose logs -f web

# MySQL ログ（必要に応じて）
docker-compose logs db
```

## 🔄 データベース操作

### マイグレーション管理

```bash
# 現在の状態確認
docker-compose exec web bundle exec rails db:version

# マイグレーション一覧
docker-compose exec web bundle exec rails db:migrate:status

# 前のバージョンに戻す
docker-compose exec web bundle exec rails db:rollback

# 特定のバージョンに戻す
docker-compose exec web bundle exec rails db:migrate:down VERSION=20250913091630

# データベースリセット（開発時のみ）
docker-compose exec web bundle exec rails db:reset
```

### シードデータ投入

```bash
# db/seeds.rb を実行
docker-compose exec web bundle exec rails db:seed

# データベースをリセットしてシード投入
docker-compose exec web bundle exec rails db:reset db:seed
```

### バックアップとリストア

```bash
# データベースダンプ作成
mysqldump -u root -p todoapp_development > backup.sql

# リストア
mysql -u root -p todoapp_development < backup.sql
```

## 🧪 テスト実行

```bash
# 全テスト実行
docker-compose exec web bundle exec rails test

# 特定のテスト実行
docker-compose exec web bundle exec rails test test/models/todo_test.rb

# システムテスト（ブラウザテスト）
docker-compose exec web bundle exec rails test:system
```

## 📦 本番デプロイ準備

### アセットプリコンパイル

```bash
# アセットビルド
docker-compose exec web bundle exec rails assets:precompile

# アセットクリーンアップ
docker-compose exec web bundle exec rails assets:clean
```

### セキュリティチェック

```bash
# セキュリティ監査
docker-compose exec web bundle exec brakeman

# コード品質チェック
docker-compose exec web bundle exec rubocop
```

## 📊 パフォーマンス監視

### 開発環境でのプロファイリング

```bash
# SQL クエリ分析のため、ログレベルを調整
# config/environments/development.rb に追加:
# config.log_level = :debug
```

### メモリ使用量確認

```bash
# コンテナのリソース使用量
docker stats todoapp-onrails-web-1

# Rails メモリ使用量
docker-compose exec web bundle exec rails runner "puts 'Memory: #{`ps -o rss= -p #{Process.pid}`.to_i / 1024}MB'"
```

## 🛡 セキュリティ設定

### SSL/TLS 設定（本番時）

```ruby
# config/environments/production.rb
config.force_ssl = true
```

### 環境変数の管理

```bash
# 本番環境での秘密情報管理
docker-compose exec web bundle exec rails credentials:edit

# 確認
docker-compose exec web bundle exec rails credentials:show
```

## 📚 参考リソース

- [Rails Guides](https://guides.rubyonrails.org/) - 公式ドキュメント
- [Docker Compose Documentation](https://docs.docker.com/compose/) - Docker Compose 公式
- [MySQL 8.0 Reference Manual](https://dev.mysql.com/doc/refman/8.0/en/) - MySQL 公式

---

## 🆘 サポート

問題が解決しない場合は、以下の情報と共にお問い合わせください：

1. エラーメッセージの全文
2. 実行したコマンド
3. 環境情報（OS、Docker バージョン等）
4. ログファイルの内容

```bash
# 環境情報収集スクリプト
echo "=== System Info ==="
uname -a
docker --version
docker-compose --version
mysql --version
echo "=== Docker Logs ==="
docker-compose logs web --tail 20
```
