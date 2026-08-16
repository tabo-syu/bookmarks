# CLAUDE.md

Guidance for Claude Code (and other AI assistants) working in this repository.

## What this app is

A small social bookmarking web app. Users register with a **name and password only**
(no email), post URLs, and the app scrapes the page's `<title>` and meta description
automatically. Bookmarks can be tagged and commented on, and every new bookmark or
comment is pushed to a Discord channel by a bot.

The UI is **Japanese-only**; `config.i18n.default_locale = :ja` and the timezone is
`Asia/Tokyo` (`config/application.rb`).

## Stack

| Area | Choice |
|---|---|
| Framework | Rails 7.1 (`Hoge::Application` — the module name is a leftover, don't "fix" it casually) |
| Ruby | 3.3.1 (`.ruby-version`); Gemfile allows `~> 3.3` |
| Database | PostgreSQL (`pg`) |
| Auth | Devise (`database_authenticatable`, `registerable`, `rememberable` only) |
| Views | ERB + Bootstrap 5.3 (dark theme forced via `data-bs-theme="dark"`) |
| JS | Hotwire (Turbo + Stimulus) over importmap — **no npm/yarn, no bundler/webpack** |
| CSS | Sass via `dartsass-sprockets` + Sprockets asset pipeline |
| Pagination | Kaminari (12 per page, `bootstrap5-kaminari-views` theme) |
| Counter caches | `counter_culture` |
| Scraping | Nokogiri + `open-uri` |
| Discord | `discordrb` |
| Lint | RuboCop (**no `.rubocop.yml`** — plain defaults) |
| Tests | Minitest (Rails default), Capybara + Selenium available but unused |

## Layout

```
app/
  controllers/     home, bookmarks, comments (nested), tags, users, application
  models/          bookmark, tag, comment, user
  helpers/         application_helper.rb holds the contribution-graph logic
  views/
    application/   _header, _footer partials (rendered from the layout)
    shared/        _bookmarks (card grid + paginate), _contribution_graph
    bookmarks/ tags/ users/ home/ devise/
  assets/stylesheets/  application.scss, contribution_graph.scss
  javascript/controllers/  Stimulus controllers (only the scaffold hello_controller)
config/
  initializers/discord.rb   boots the Discord bot at load time (see gotchas)
  locales/                  ja / en, plus devise-i18n and kaminari_ja
db/migrate, db/schema.rb
docker/rails/, docker/nginx/   production images
.devcontainer/                 dev environment (app + postgres)
test/                          scaffold-only; see "Tests" below
```

## Data model

```
User 1─* Bookmark *─* Tag        (HABTM via `bookmarks_tags`, no model, no timestamps)
User 1─* Comment                  Bookmark 1─* Comment
User 1─* Tag                      (tags are owned by the user who created them)
```

- `bookmarks.comments_count` is a `counter_culture` counter maintained from `Comment`.
- All FK columns are `NOT NULL` with real foreign keys except the HABTM join table,
  whose `bookmark_id` / `tag_id` are nullable and unconstrained.
- `users` has a unique index on `name`; there is **no email column** (it was dropped in
  `20240402143152_delete_email_column_from_users.rb`), so Devise's recoverable /
  confirmable / validatable modules are deliberately absent.
- `tags.color` was removed (`20240320111319_remove_color_from_tags.rb`).

Change the schema through migrations only (`bin/rails g migration ...`); `db/schema.rb`
is generated and marked `linguist-generated`.

## Conventions to follow

**Controllers**
- `ApplicationController` sets `@user = current_user` in a `before_action` and permits
  `:name` for Devise sign-up. Views read `@user` (the header partial takes it as a local).
- Read actions are public; writes require auth:
  `before_action :authenticate_user!, except: %i[index show]`.
- **Scope writes through the current user**, never through the top-level model:
  `current_user.bookmarks.find(params[:id])` — this is how ownership is enforced.
  There is no Pundit/CanCan; breaking this pattern silently removes authorization.
- Failed create/update renders the form with `status: :unprocessable_entity`;
  destroy redirects with `status: :see_other` (Turbo requirements).
- Always `preload` associations used in the view — `bullet` is enabled in development
  and will pop an alert on N+1.

**Models** — validations live in the model; `Bookmark` uses `validates :url, url: true`
from the `validate_url` gem.

**Views** — Bootstrap utility classes inline; Japanese copy hard-coded in templates
(only Devise strings and date formats go through i18n). Keep new user-facing strings
Japanese. Reuse `shared/_bookmarks` for any bookmark list — it renders the card grid
*and* calls `paginate @bookmarks`, so the calling action must assign `@bookmarks` as a
Kaminari relation (`.page(params[:page])`), not just pass the local.

**Style** — `# frozen_string_literal: true` appears on config/ and some app/ files but
not on the models/controllers; match whatever the file you're editing already does.
RuboCop runs with stock defaults, so a full-repo run is noisy — only check files you
touched: `bundle exec rubocop app/models/bookmark.rb`.

**Commits** — history uses Conventional Commits with a gitmoji and a Japanese subject:

```
feat: 🎸 コメントが空のとき、コメントを投稿しないように
fix: 🐛 favicon を読み込めるように修正
chore: 🤖 DB の volume のバックアップスクリプトを作成
```

Match this. Branches are `feature/...` or `fix/...`; work merges to `main` via PR.

## Development

Preferred path is the Dev Container (`.devcontainer/`), which brings up the app
container plus a `db` postgres service. `config/database.yml` hard-codes
`host: db`, `username: postgres`, `password: postgres`, database `postgres` for
development — so a plain local postgres on `localhost` will not connect without editing
that file.

```bash
bundle install
bin/rails db:prepare        # or db:create db:migrate db:seed
bin/rails server            # http://localhost:3000
```

`db/seeds.rb` creates one user (`test_user` / `password`), one tag, and 14 bookmarks.
It hard-codes `user_id: 1` / `tag_ids: [1]`, so it only works on a fresh database.

Credentials (`config/credentials.yml.enc`) require `RAILS_MASTER_KEY` /
`config/master.key`, which is **not** in the repo. Expected keys:

```yaml
discord:
  token: ...
  channel_id: ...
secret_key_base: ...
```

Edit with `EDITOR="code --wait" bin/rails credentials:edit`.

## Tests

```bash
bin/rails test                          # all
bin/rails test test/models/bookmark_test.rb
bin/rails test:system                   # Capybara + Selenium
```

**Be aware of the current state before trusting a green/red run:** the suite is almost
entirely unmodified Rails scaffolding. Every model test and three of the four controller
tests are commented-out placeholders. The one real assertion,
`test/controllers/bookmarks_controller_test.rb`, calls `bookmarks_index_url`, which is
not a route helper this app defines (`resources :bookmarks` generates `bookmarks_url`) —
so it raises. The fixtures are stale too: `tags.yml` sets a `color` column that was
dropped, `users.yml` is `{}` (two rows would collide on the unique `name` index), and
none of the fixtures set the `NOT NULL` `user_id` columns.

If you add tests, expect to fix the fixtures first. Don't report "tests pass" without
actually running them.

## Gotchas

1. **The Discord bot boots with the app.** `config/initializers/discord.rb` creates a
   global `Bot` constant and calls `Bot.run(background: true)` at initializer time. This
   runs for *every* environment and every `rails` / `rake` invocation, and it needs a
   valid credentials token. Without `master.key` this is the first thing that breaks.
   Controllers call `Bot.send_message(...)` inline in `create` — there is no job queue
   and no error handling, so a Discord outage fails the request.
2. **Bookmark creation makes an outbound HTTP request.** `BookmarksController#create`
   opens the submitted URL with `open-uri` and parses it with Nokogiri. `title` and
   `description` are *derived*, never taken from user params (`bookmark_params` permits
   only `:url`, `tag_ids`, `comments_attributes`). Any fetch failure is rescued into a
   `無効なURL` error on `:url`. Note `#update` reuses the same params but does **not**
   re-scrape, so editing a bookmark leaves the old title/description.
3. **`User` validates `password` presence**, which is unusual for Devise and affects any
   user update that doesn't supply a password.
4. **The meta-description selector is wrong but load-bearing.**
   `doc.css('//meta[name$="description"]/@content')` mixes XPath syntax into `css`; it
   effectively returns nothing, so `description` falls back to the title. Fixing it will
   change behavior for existing flows — do it deliberately, not as a drive-by.
5. **Contribution graph** (`ApplicationHelper#contribution_graph_data`) runs a grouped
   count over *all* bookmarks for 53 weeks, and it is site-wide — never scoped to a user.
   `home/index.html.erb` renders the partial **twice** (a desktop copy and a mobile copy,
   toggled with `d-none d-xl-block` / `d-block d-xl-none`), so the query and the week
   bucketing run twice per home-page load. The bucketing logic lives inline in the
   partial's ERB, not in the helper.
6. **Assets are Sprockets, not Propshaft.** New stylesheets need to be reachable from
   `app/assets/config/manifest.js`; new JS goes through `config/importmap.rb`
   (`bin/importmap pin ...`), not package.json.

## Production

`compose.yml` runs nginx (port 8080 → 80) in front of the Rails app and postgres.
Requires a `.env` with `DB_NAME`, `DB_USER`, `DB_PASSWORD`, and `RAILS_MASTER_KEY`
passed as a build arg (assets are precompiled at image build time).

```bash
docker compose build --no-cache
docker compose down
docker compose up -d
```

`bin/docker-entrypoint` runs `db:prepare` before booting the server. `backup.sh` tars the
`bookmarks-rails_postgres-data` volume into `./backup/` and prunes tarballs older than
7 days; it's meant to be driven by cron.

## CI

`.github/workflows/claude.yaml` is the only workflow — it runs `anthropics/claude-code-action`
when `@claude` is mentioned in an issue or PR comment. **There is no test or lint CI**, so
nothing catches a broken build on push; verify locally before pushing.
