# 📚 Bookmarks - Social Bookmark Management Platform

<div align="center">

![Ruby on Rails](https://img.shields.io/badge/Ruby%20on%20Rails-7.1.3-CC0000?style=for-the-badge&logo=ruby-on-rails&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white)
![Bootstrap](https://img.shields.io/badge/Bootstrap-563D7C?style=for-the-badge&logo=bootstrap&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Discord](https://img.shields.io/badge/Discord-7289DA?style=for-the-badge&logo=discord&logoColor=white)

*A modern, feature-rich bookmark management application with social capabilities and Discord integration*

</div>

---

## 🌟 Features

### 🔖 Smart Bookmark Management
- **Auto-metadata extraction** - Automatically fetches page titles and descriptions using Nokogiri
- **URL validation** - Ensures valid URLs are bookmarked
- **Rich organization** - Tag-based categorization system
- **User-owned content** - Each user manages their own bookmarks

### 💬 Social Features  
- **Comment system** - Engage in discussions about bookmarks
- **Comment counters** - Track engagement with counter_culture gem
- **User profiles** - View other users' bookmark collections
- **Community interaction** - Discover and discuss interesting links

### 🤖 Discord Integration
- **Real-time notifications** - New bookmarks are automatically posted to Discord
- **Comment alerts** - Get notified when users add comments
- **Community bridge** - Connect your bookmark activity with Discord communities

### 🎨 Modern User Experience
- **Responsive design** - Bootstrap 5-powered interface
- **Hotwire enhancement** - Fast, SPA-like interactions with Turbo and Stimulus
- **Pagination** - Efficient browsing with Kaminari
- **Internationalization** - Japanese and English support

### 🔐 Security & Authentication
- **Devise integration** - Robust user authentication system
- **User isolation** - Secure access controls for bookmarks, tags, and comments
- **Session management** - Remember me functionality
- **Password security** - Encrypted password storage

---

## 🏗️ Architecture

### 📊 Data Model

```
┌─────────────┐       ┌─────────────┐       ┌─────────────┐
│    User     │◄─────►│  Bookmark   │◄─────►│    Tag      │
│             │       │             │       │             │
│ - name      │       │ - url       │       │ - name      │
│ - password  │       │ - title     │       │             │
│             │       │ - description│       │             │
└─────────────┘       │ - comments_count│    └─────────────┘
       │               └─────────────┘              │
       │                      │                    │
       │                      ▼                    │
       │               ┌─────────────┐              │
       └──────────────►│   Comment   │◄─────────────┘
                       │             │
                       │ - body      │
                       │             │
                       └─────────────┘
```

### 🔧 Technology Stack

| Layer | Technology | Purpose |
|-------|------------|---------|
| **Framework** | Ruby on Rails 7.1 | Full-stack web application framework |
| **Database** | PostgreSQL | Robust, scalable data storage |
| **Frontend** | Bootstrap 5 + Hotwire | Modern, responsive UI with enhanced interactions |
| **Authentication** | Devise | Secure user management |
| **Styling** | Dart Sass | Advanced CSS preprocessing |
| **Pagination** | Kaminari | Efficient data browsing |
| **Scraping** | Nokogiri | HTML parsing for metadata extraction |
| **Integration** | Discordrb | Discord bot functionality |
| **Testing** | Rails Test Suite + Capybara | Comprehensive test coverage |
| **Deployment** | Docker + Nginx | Containerized production deployment |

### 🎯 Core Components

#### Models
- **User**: Manages authentication and owns bookmarks, tags, and comments
- **Bookmark**: Central entity with URL validation and metadata
- **Tag**: Flexible categorization system with many-to-many relationship
- **Comment**: Social interaction layer with counter caching

#### Controllers
- **BookmarksController**: CRUD operations with auto-metadata fetching
- **TagsController**: Tag management and organization
- **CommentsController**: Nested comment handling
- **UsersController**: Profile viewing functionality

#### Key Features Implementation
- **Smart URL Processing**: Automatic title/description extraction using Nokogiri
- **Discord Bot**: Real-time notifications via discordrb gem
- **Performance**: Counter caching, eager loading, and pagination
- **Security**: Authentication checks and user-scoped queries

---

## 🚀 Getting Started

### Prerequisites
- Ruby 3.3.1
- PostgreSQL
- Node.js (LTS)
- Docker & Docker Compose (for production)

### 🛠️ Local Development

#### Option 1: Dev Containers (Recommended)
1. Install [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
2. Open as Dev Container
3. Follow the setup steps below

#### Option 2: Manual Setup
```bash
# Install dependencies
$ nvm install --lts
$ bundle install

# Configure credentials
$ EDITOR="code --wait" bin/rails credentials:edit
```

Add the following to your credentials:
```yaml
discord:
  token: your_discord_bot_token
  channel_id: your_discord_channel_id

secret_key_base: your_secret_key_base
```

```bash
# Setup database
$ rails db:create
$ rails db:migrate
$ rails db:seed

# Start development server
$ rails server
```

Visit `http://localhost:3000` to access the application.

### 🔧 Configuration

#### Discord Integration
1. Create a Discord bot at [Discord Developer Portal](https://discord.com/developers/applications)
2. Add bot token and channel ID to Rails credentials
3. Invite bot to your Discord server with appropriate permissions

#### Environment Variables
- `DATABASE_URL`: PostgreSQL connection string (production)
- `RAILS_ENV`: Environment setting (development/test/production)

---

## 🚢 Deployment

### Docker Production Setup
```bash
# Build images
$ docker compose build --no-cache

# Stop existing containers  
$ docker compose down

# Start production stack
$ docker compose up -d
```

### 📦 Docker Architecture
- **Rails App**: Containerized Ruby on Rails application
- **Nginx**: Reverse proxy and static file serving
- **PostgreSQL**: Database container with persistent volumes

---

## 💾 Backup & Restore

### Automated Backup
```bash
# Make backup script executable
$ chmod +x backup.sh

# Schedule daily backups at 2 AM
$ crontab -e
0 2 * * * /path/to/your/project/backup.sh
```

### Restore from Backup
```bash
$ docker run --rm \
  -v bookmarks-rails_postgres-data:/volume \
  -v $(pwd):/backup \
  busybox tar xvf /backup/postgres-data_backup.tar -C /
```

---

## 🧪 Testing

### Running Tests
```bash
# Run all tests
$ rails test

# Run specific test categories
$ rails test:models
$ rails test:controllers
$ rails test:system

# Run with coverage
$ rails test --coverage
```

### Test Coverage
- **Models**: Comprehensive validation and association testing
- **Controllers**: Request/response testing for all endpoints
- **System Tests**: End-to-end user interaction testing with Capybara

---

## 📈 Development Workflow

### Code Quality
- **Rubocop**: Automated code style checking
- **Bullet**: N+1 query detection in development
- **Rails Best Practices**: Following Rails conventions

### Performance Optimizations
- **Counter Culture**: Efficient comment counting without N+1 queries
- **Eager Loading**: Preloading associations to reduce database queries
- **Database Indexing**: Optimized queries with proper indexes
- **Pagination**: Memory-efficient data browsing

### Internationalization
- Support for Japanese and English
- Devise integration with localized authentication messages
- Kaminari pagination with Japanese translations

---

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Development Guidelines
- Follow Rails conventions and best practices
- Write tests for new functionality
- Update documentation for significant changes
- Use Rubocop for code style consistency

---

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

---

## 🙏 Acknowledgments

- **Ruby on Rails** - The web framework that makes development joy
- **Bootstrap** - For the beautiful and responsive UI components
- **Devise** - For robust authentication system
- **Discord** - For community integration capabilities
- **PostgreSQL** - For reliable data storage

---

<div align="center">

**Built with ❤️ by [tabosuke](https://github.com/tabo-syu)**

*Happy bookmarking! 📚✨*

</div>