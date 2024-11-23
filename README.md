# Rails Microservices Product Service

This repository is part of a microservices architecture demonstration project. It serves as a product service component for the main project [rails-microservices-demo](https://github.com/vulehuan/rails-microservices-demo).

## Overview

This is a Ruby on Rails API-mode application that handles product-related operations in a microservices architecture. It's designed to demonstrate best practices and common patterns in building microservices with Rails.

## Technical Stack

- **Ruby Version**: 3.x
- **Rails Version**: 7.x (API Mode)
- **Database**: PostgreSQL

## Key Features & Implementations

### Authentication & Authorization
- JWT (JSON Web Tokens) for authentication
- CanCanCan for role-based authorization

### Data Management
- PostgreSQL as the primary database
- Active Model Serializers for JSON response formatting
- API-only mode for lightweight and focused service

### Monitoring & Logging
- Sentry integration for error tracking and monitoring

### Testing
- RSpec as the testing framework
- SimpleCov for code coverage reporting

## Getting Started

### Prerequisites
- Ruby 3.x
- Rails 7.x
- PostgreSQL

### Installation

1. Clone the repository:
```bash
git clone https://github.com/vulehuan/rails-microservices-product-service.git
cd rails-microservices-product-service
```

2. Install dependencies:
```bash
bundle install
```

3. Database setup:
```bash
rails db:create
rails db:migrate
```

4. Start the server:
```bash
rails server
```

### Running Tests

To run the test suite:
```bash
bundle exec rspec
```

To view code coverage report:
```bash
open coverage/index.html
```

## Integration

This service is designed to work as part of the larger microservices ecosystem demonstrated in [rails-microservices-demo](https://github.com/vulehuan/rails-microservices-demo). Please refer to the main repository for full integration details and architecture overview.
