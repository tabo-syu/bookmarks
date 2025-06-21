<div align="center">

# 📚 Bookmarks

**スマートなブックマーク管理プラットフォーム**

[![Ruby on Rails](https://img.shields.io/badge/Ruby%20on%20Rails-7.1-CC0000?style=for-the-badge&logo=ruby-on-rails&logoColor=white)](https://rubyonrails.org/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![Bootstrap](https://img.shields.io/badge/Bootstrap-5.3-7952B3?style=for-the-badge&logo=bootstrap&logoColor=white)](https://getbootstrap.com/)
[![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)
[![Discord](https://img.shields.io/badge/Discord-7289DA?style=for-the-badge&logo=discord&logoColor=white)](https://discord.com/)

</div>

## ✨ 機能

### 📋 コア機能
- **スマートブックマーク管理** - URL の自動メタデータ抽出
- **タグシステム** - 効率的な分類とフィルタリング
- **コメント機能** - ブックマークに詳細な注釈を追加
- **ユーザー認証** - Devise による安全なアカウント管理
- **ページネーション** - 大量のブックマークを効率的に表示

### 🤝 ソーシャル機能
- **Discord 連携** - コミュニティ通知とボット統合
- **ユーザープロフィール** - 個人のブックマークコレクション表示
- **共有機能** - ブックマークを他のユーザーと共有

### 🌐 技術的特徴
- **多言語対応** - 日本語・英語のインターナショナライゼーション
- **モダン UI** - Bootstrap 5 によるレスポンシブデザイン
- **Hotwire** - Turbo/Stimulus によるリアルタイム更新
- **パフォーマンス最適化** - カウンターキャッシュとクエリ最適化

## 🏗️ アーキテクチャ

### データモデル
```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│    User     │    │  Bookmark   │    │    Tag      │
├─────────────┤    ├─────────────┤    ├─────────────┤
│ id          │    │ id          │    │ id          │
│ name        │◄──►│ user_id     │◄──►│ name        │
│ created_at  │    │ title       │    │ created_at  │
│ updated_at  │    │ url         │    │ updated_at  │
└─────────────┘    │ description │    └─────────────┘
                   │ created_at  │           │
                   │ updated_at  │           │
                   └─────────────┘           │
                          │                  │
                          ▼                  │
                   ┌─────────────┐           │
                   │   Comment   │           │
                   ├─────────────┤           │
                   │ id          │           │
                   │ bookmark_id │           │
                   │ content     │           │
                   │ created_at  │           │
                   │ updated_at  │           │
                   └─────────────┘           │
                                            │
                   ┌─────────────────────────┘
                   │
                   ▼
            ┌─────────────────┐
            │ BookmarkHasTag  │
            ├─────────────────┤
            │ bookmark_id     │
            │ tag_id          │
            └─────────────────┘
```

### 技術スタック

| カテゴリ | 技術 | バージョン |
|---------|-----|----------|
| **バックエンド** | Ruby on Rails | 7.1.3+ |
| **データベース** | PostgreSQL | - |
| **フロントエンド** | Hotwire (Turbo/Stimulus) | - |
| **CSS フレームワーク** | Bootstrap | 5.3.2 |
| **認証** | Devise | 4.9+ |
| **Web スクレイピング** | Nokogiri | - |
| **Discord 連携** | Discordrb | - |
| **ページネーション** | Kaminari | - |
| **デプロイ** | Docker | - |

## 🚀 開発環境のセットアップ

### 方法 1: Dev Container (推奨)

1. [Dev Containers 拡張機能](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) をインストール
2. プロジェクトを Dev Container として開く

### 方法 2: ローカル環境

#### 前提条件
- Ruby 3.3.1
- Node.js (LTS版)
- PostgreSQL
- Git

#### セットアップ手順

```bash
# 依存関係のインストール
$ nvm install --lts
$ bundle install

# データベースのセットアップ
$ rails db:setup

# 認証情報の編集
$ EDITOR="code --wait" bin/rails credentials:edit
```

#### 認証情報の設定
```yaml
# config/credentials.yml.enc
aws:
  access_key_id: your_aws_key
  secret_access_key: your_aws_secret

discord:
  token: your_discord_bot_token
  channel_id: your_discord_channel_id

# Rails のセッション暗号化に使用
secret_key_base: your_secret_key_base
```

#### 開発サーバーの起動
```bash
$ rails server
```

アプリケーション: http://localhost:3000

## 🐳 本番環境のデプロイ

### Docker を使用したデプロイ

```bash
# イメージのビルド
$ docker compose build --no-cache

# サービスの停止
$ docker compose down

# サービスの起動
$ docker compose up -d
```

### 環境変数

以下の環境変数を設定してください：

```bash
DATABASE_URL=postgresql://user:password@host:port/database
RAILS_MASTER_KEY=your_master_key
DISCORD_BOT_TOKEN=your_discord_token
DISCORD_CHANNEL_ID=your_channel_id
```

## 🧪 テスト

### テストスイートの実行

```bash
# 全テストの実行
$ rails test

# システムテストの実行
$ rails test:system

# 特定のテストファイルの実行
$ rails test test/controllers/bookmarks_controller_test.rb
```

### テストの種類
- **Unit Tests** - モデル、ヘルパーのテスト
- **Controller Tests** - HTTP リクエスト/レスポンスのテスト
- **System Tests** - エンドツーエンドの統合テスト (Capybara + Selenium)

## 💾 バックアップ・復元

### 自動バックアップの設定

```bash
# バックアップスクリプトに実行権限を付与
$ chmod +x backup.sh

# crontab で定期実行を設定（毎日午前2時）
$ crontab -e
0 2 * * * /path/to/your/project/backup.sh
```

### 手動復元

```bash
# データベースの復元
$ docker run --rm \
  -v bookmarks-rails_postgres-data:/volume \
  -v $(pwd):/backup \
  busybox tar xvf /backup/postgres-data_backup.tar -C /
```

## 🔧 開発ツール

### コード品質管理
- **RuboCop** - Ruby コードスタイルの静的解析
- **Bullet** - N+1 クエリの検出
- **HTMLBeautifier** - ERB テンプレートの整形

### デバッグ
- **Debug gem** - Ruby の標準デバッガー
- **Web Console** - ブラウザ内デバッグコンソール

## 📊 パフォーマンス最適化

### 実装済み最適化
- **Counter Cache** - 関連レコード数の効率的な管理
- **Database Indexing** - クエリパフォーマンスの向上
- **Eager Loading** - N+1 クエリ問題の防止
- **Page Caching** - 静的コンテンツのキャッシュ

### モニタリング
- **Bullet gem** - クエリ問題の検出
- **Rails Health Check** - アプリケーションの状態監視 (`/up`)

## 🤖 Discord 連携

このアプリケーションは Discord ボットと統合されており、以下の機能を提供します：

- **新しいブックマーク通知** - 追加時の自動通知
- **コミュニティ共有** - 指定チャンネルでの情報共有
- **リアルタイム更新** - Discord 経由での活動通知

### Discord ボットの設定

1. Discord Developer Portal でボットを作成
2. 必要な権限を設定
3. トークンとチャンネル ID を認証情報に追加

## 🌍 国際化対応

### サポート言語
- **日本語** (ja) - デフォルト
- **英語** (en)

### 翻訳ファイル
- `config/locales/ja.yml` - 日本語翻訳
- `config/locales/en.yml` - 英語翻訳
- `config/locales/devise.ja.yml` - Devise 日本語翻訳
- `config/locales/kaminari_ja.yml` - Kaminari 日本語翻訳

## 🛡️ セキュリティ

### 実装済みセキュリティ機能
- **CSRF Protection** - クロスサイトリクエストフォージェリ対策
- **SQL Injection Prevention** - パラメータ化クエリ
- **XSS Protection** - HTML エスケープ
- **URL Validation** - 悪意のある URL の検証
- **Secure Headers** - セキュリティヘッダーの設定

## 🤝 コントリビューション

### 開発フロー

1. **Issue の作成** - 機能追加やバグ報告
2. **ブランチ作成** - `feature/your-feature-name` または `fix/issue-name`
3. **開発** - コードの実装とテストの追加
4. **テスト** - `rails test` でテストスイートを実行
5. **プルリクエスト** - レビューのための PR 作成

### コーディング規約
- RuboCop 設定に従う
- テストカバレッジを維持する
- コミットメッセージは日本語または英語で明確に記述

## 📝 ライセンス

このプロジェクトは MIT ライセンスの下で公開されています。

## 📞 サポート

問題や質問がある場合は、以下の方法でお問い合わせください：

- **Issues** - GitHub Issues でバグ報告や機能要求
- **Discord** - リアルタイムサポート（設定済みの場合）

---

<div align="center">

**🔗 スマートなブックマーク管理で、情報整理を効率化しましょう！**

Made with ❤️ by the Bookmarks Team

</div>