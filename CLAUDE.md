# CLAUDE.md

このリポジトリで作業する Claude Code（および他の AI アシスタント）向けのガイド。

## このアプリについて

小規模なソーシャルブックマークアプリ。ユーザーは**名前とパスワードのみ**で登録し
（メールアドレスなし）、URL を投稿すると `<title>` と meta description を自動で
スクレイピングして取得する。ブックマークにはタグ付けとコメントができ、新規ブックマーク
とコメントは Discord チャンネルに Bot が通知する。

UI は**日本語のみ**。`config.i18n.default_locale = :ja`、タイムゾーンは `Asia/Tokyo`
（`config/application.rb`）。

## 技術スタック

| 領域 | 採用技術 |
|---|---|
| フレームワーク | Rails 7.1（`Hoge::Application` — 生成時の名残。安易に「修正」しないこと） |
| Ruby | 3.3.1（`.ruby-version`）、Gemfile では `~> 3.3` |
| データベース | PostgreSQL（`pg`） |
| 認証 | Devise（`database_authenticatable`, `registerable`, `rememberable` のみ） |
| ビュー | ERB + Bootstrap 5.3（`data-bs-theme="dark"` でダークテーマ固定） |
| JS | Hotwire（Turbo + Stimulus）を importmap 経由で — **npm/yarn・webpack は不使用** |
| CSS | Sass（`dartsass-sprockets`）+ Sprockets アセットパイプライン |
| ページネーション | Kaminari（1 ページ 12 件、`bootstrap5-kaminari-views` テーマ） |
| カウンタキャッシュ | `counter_culture` |
| スクレイピング | Nokogiri + `open-uri` |
| Discord | `discordrb` |
| Lint | RuboCop（**`.rubocop.yml` なし** — デフォルト設定のまま） |
| テスト | Minitest（Rails 標準）。Capybara + Selenium は導入済みだが未使用 |

## ディレクトリ構成

```
app/
  controllers/     home, bookmarks, comments（ネスト）, tags, users, application
  models/          bookmark, tag, comment, user
  helpers/         application_helper.rb にコントリビューショングラフのロジック
  views/
    application/   _header, _footer パーシャル（レイアウトから描画）
    shared/        _bookmarks（カードグリッド + paginate）, _contribution_graph
    bookmarks/ tags/ users/ home/ devise/
  assets/stylesheets/  application.scss, contribution_graph.scss
  javascript/controllers/  Stimulus コントローラ（雛形の hello_controller のみ）
config/
  initializers/discord.rb   起動時に Discord Bot を起動（「注意点」参照）
  locales/                  ja / en、devise-i18n と kaminari_ja
db/migrate, db/schema.rb
docker/rails/, docker/nginx/   本番用イメージ
.devcontainer/                 開発環境（app + postgres）
test/                          雛形のみ。「テスト」の節を参照
```

## データモデル

```
User 1─* Bookmark *─* Tag        （HABTM。中間テーブル `bookmarks_tags`、モデルなし・timestamps なし）
User 1─* Comment                  Bookmark 1─* Comment
User 1─* Tag                      （タグは作成したユーザーが所有）
```

- `bookmarks.comments_count` は `Comment` 側から `counter_culture` が更新するカウンタ。
- 外部キーカラムはすべて `NOT NULL` かつ実 FK 制約付き。ただし HABTM 中間テーブルの
  `bookmark_id` / `tag_id` は NULL 許容で制約なし。
- `users` は `name` に一意インデックスあり。**email カラムは存在しない**
  （`20240402143152_delete_email_column_from_users.rb` で削除済み）。そのため Devise の
  recoverable / confirmable / validatable モジュールは意図的に外してある。
- `tags.color` は削除済み（`20240320111319_remove_color_from_tags.rb`）。

スキーマ変更は必ずマイグレーション経由で（`bin/rails g migration ...`）。`db/schema.rb`
は自動生成で `linguist-generated` 指定済み。

## 従うべき規約

**コントローラ**
- `ApplicationController` が `before_action` で `@user = current_user` を設定し、Devise の
  サインアップで `:name` を許可する。ビューは `@user` を参照（ヘッダーパーシャルはローカル変数で受け取る）。
- 参照系は公開、更新系は認証必須:
  `before_action :authenticate_user!, except: %i[index show]`
- **更新系は必ず current_user 経由でスコープする**こと。トップレベルのモデルから引かない:
  `current_user.bookmarks.find(params[:id])` — これが唯一の所有者チェック。
  Pundit / CanCan は入っていないため、このパターンを崩すと認可が黙って消える。
- create / update の失敗時は `status: :unprocessable_entity` でフォームを再描画、
  destroy は `status: :see_other` でリダイレクト（Turbo の要求）。
- ビューで使う関連は必ず `preload` する。development では `bullet` が有効で、N+1 が
  あるとアラートが出る。

**モデル** — バリデーションはモデルに置く。`Bookmark` は `validate_url` gem の
`validates :url, url: true` を使用。

**ビュー** — Bootstrap のユーティリティクラスを直書き、日本語の文言はテンプレートに
ハードコード（i18n を通すのは Devise の文言と日付フォーマットのみ）。新しく追加する
ユーザー向け文言も日本語で書くこと。ブックマーク一覧は `shared/_bookmarks` を再利用する。
このパーシャルはカードグリッドの描画に加えて `paginate @bookmarks` を呼ぶため、
呼び出し元のアクションは `@bookmarks` を Kaminari のリレーション
（`.page(params[:page])`）として代入する必要がある。ローカル変数で渡すだけでは不足。

**スタイル** — `# frozen_string_literal: true` は config/ と一部の app/ ファイルには
あるが、モデル・コントローラにはない。編集するファイルの既存のスタイルに合わせること。
RuboCop はデフォルト設定のままなのでリポジトリ全体にかけると大量に警告が出る。
触ったファイルだけ確認する: `bundle exec rubocop app/models/bookmark.rb`

**コミット** — 履歴は Conventional Commits + gitmoji + 日本語の件名:

```
feat: 🎸 コメントが空のとき、コメントを投稿しないように
fix: 🐛 favicon を読み込めるように修正
chore: 🤖 DB の volume のバックアップスクリプトを作成
```

これに合わせること。ブランチは `feature/...` または `fix/...`、`main` へ PR でマージする。

## 開発環境

推奨は Dev Container（`.devcontainer/`）。app コンテナと `db` の postgres サービスが
立ち上がる。`config/database.yml` の development は `host: db`、`username: postgres`、
`password: postgres`、データベース名 `postgres` をハードコードしているため、
ローカルの `localhost` の postgres にはこのファイルを編集しない限り接続できない。

```bash
bundle install
bin/rails db:prepare        # または db:create db:migrate db:seed
bin/rails server            # http://localhost:3000
```

`db/seeds.rb` はユーザー 1 件（`test_user` / `password`）、タグ 1 件、ブックマーク 14 件を
作成する。`user_id: 1` / `tag_ids: [1]` をハードコードしているので、まっさらな DB でしか
動かない。

認証情報（`config/credentials.yml.enc`）には `RAILS_MASTER_KEY` または
`config/master.key` が必要だが、リポジトリには**含まれていない**。必要なキー:

```yaml
discord:
  token: ...
  channel_id: ...
secret_key_base: ...
```

編集は `EDITOR="code --wait" bin/rails credentials:edit`。

## テスト

```bash
bin/rails test                          # 全件
bin/rails test test/models/bookmark_test.rb
bin/rails test:system                   # Capybara + Selenium
```

**実行結果を信用する前に現状を把握すること。** テストはほぼ Rails の雛形のまま。
モデルテストは全件、コントローラテストも 4 つ中 3 つがコメントアウトされたプレースホルダ。
唯一の実アサーションである `test/controllers/bookmarks_controller_test.rb` は
`bookmarks_index_url` を呼んでいるが、このヘルパーは生成されていない
（`resources :bookmarks` が生成するのは `bookmarks_url`）ため例外になる。
フィクスチャも古い: `tags.yml` は削除済みの `color` カラムを設定しており、`users.yml` は
`{}`（2 行が `name` の一意インデックスで衝突する）、どのフィクスチャも `NOT NULL` の
`user_id` を設定していない。

テストを追加する場合はまずフィクスチャの修正が必要。**実際に実行せずに「テストが通った」
と報告しないこと。**

## 注意点

1. **Discord Bot がアプリ起動と同時に立ち上がる。** `config/initializers/discord.rb` が
   グローバル定数 `Bot` を作り、initializer の読み込み時に `Bot.run(background: true)` を
   呼ぶ。これは*すべての*環境、そして `rails` / `rake` の実行のたびに走り、有効な
   credentials のトークンを必要とする。`master.key` がない環境では最初にここで落ちる。
   コントローラは `create` の中で同期的に `Bot.send_message(...)` を呼んでおり、
   ジョブキューもエラーハンドリングもないため、Discord 側の障害がリクエストの失敗に直結する。
2. **ブックマーク作成時に外部への HTTP リクエストが発生する。**
   `BookmarksController#create` は投稿された URL を `open-uri` で開き Nokogiri で解析する。
   `title` と `description` は*導出値*であり、ユーザーのパラメータからは受け取らない
   （`bookmark_params` が許可するのは `:url`, `tag_ids`, `comments_attributes` のみ）。
   取得失敗はすべて rescue され `:url` に `無効なURL` エラーが付く。なお `#update` は同じ
   パラメータを使うが**再スクレイピングしない**ため、URL を編集しても title / description は
   古いままになる。
3. **`User` が `password` の presence をバリデーションしている。** Devise としては異例で、
   パスワードを伴わないユーザー更新に影響する。
4. **meta description のセレクタは壊れているが、挙動に組み込まれている。**
   `doc.css('//meta[name$="description"]/@content')` は XPath 構文を `css` に渡しており
   実質何もマッチしない。そのため `description` は常に title にフォールバックしている。
   修正すると既存の挙動が変わるので、ついでの修正ではなく意図をもって行うこと。
5. **コントリビューショングラフ**（`ApplicationHelper#contribution_graph_data`）は
   53 週分を*全*ブックマークに対して集計する。ユーザーによるスコープは一切なく、サイト全体の
   集計である。さらに `home/index.html.erb` はこのパーシャルを**2 回**描画しており
   （デスクトップ用とモバイル用を `d-none d-xl-block` / `d-block d-xl-none` で出し分け）、
   クエリと週ごとの集計がホーム表示 1 回につき 2 回走る。週の区切り処理はヘルパーではなく
   パーシャルの ERB 内にインラインで書かれている。
6. **アセットは Propshaft ではなく Sprockets。** 新しいスタイルシートは
   `app/assets/config/manifest.js` から辿れる必要がある。JS は package.json ではなく
   `config/importmap.rb` を通す（`bin/importmap pin ...`）。

## 本番環境

`compose.yml` は Rails アプリと postgres の前段に nginx（8080 → 80）を置く構成。
`.env` に `DB_NAME`, `DB_USER`, `DB_PASSWORD` が必要で、`RAILS_MASTER_KEY` はビルド引数
として渡す（アセットのプリコンパイルがイメージのビルド時に走るため）。

```bash
docker compose build --no-cache
docker compose down
docker compose up -d
```

`bin/docker-entrypoint` がサーバ起動前に `db:prepare` を実行する。`backup.sh` は
`bookmarks-rails_postgres-data` ボリュームを `./backup/` に tar で固め、7 日より古い
tar を削除する。cron から実行する想定。

## CI

`.github/workflows/claude.yaml` が唯一のワークフローで、issue や PR のコメントで
`@claude` がメンションされたときに `anthropics/claude-code-action` を実行する。
**テストや Lint の CI は存在しない**ため、ビルドが壊れてもプッシュ時には検知されない。
プッシュ前にローカルで確認すること。
