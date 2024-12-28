# Project Overview

This project was developed as a response to [the evaluation task from Bravado](ASSIGNMENT.md).

# Deployment

### Prerequisites

- Ruby 3.3.5
- Bundler 2.5.21
- Docker

### 1. Install gems

```bash
sudo apt install libpq-dev

bundle install
```

### 2. Environment variables

Set them in the `.env` file (a [template](.env.template) is provided) or in the environment itself:

### 3. Database setup

```bash
docker compose up
```

Create databases for both the development and test environments:

```bash
rails db:setup
```

### 4. Start Sidekiq

```bash
sidekiq
```

Now you should be all set to run the application using `rails s` or use RSpec.
