# Roommates

A full-stack roommate and apartment listing platform developed as a university group project.

The goal of the project was to create a platform where users can register, create profiles, publish apartment/roommate listings, and browse available housing options.

The project uses a custom backend architecture based around PostgreSQL, PostgREST, Docker, and Nginx. The original version was deployed on a private Linux server using Docker Compose.

This repository is a public export of the project for demonstration and portfolio purposes.

---

# Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Architecture](#architecture)
- [Technology Stack](#technology-stack)
- [Repository Structure](#repository-structure)
- [Backend Design](#backend-design)
- [Database Architecture](#database-architecture)
- [Authentication System](#authentication-system)
- [File Storage](#file-storage)
- [Docker Setup](#docker-setup)
- [Installation](#installation)
- [Environment Configuration](#environment-configuration)
- [Database Initialization](#database_initialization)
- [Frontend Configuration](#frontend-configuration)
- [Deployment Notes](#deployment-notes)
- [Future Improvements](#future-improvements)
- [Lessons Learned](#lessons-learned)
- [License](#license)

---

# Overview

Roommates is a web application designed to help people find compatible roommates and housing opportunities.

Users can:

- Create an account
- Set up a personal profile
- Upload a profile picture
- Specify lifestyle preferences
- Browse apartment listings
- Search and filter available options
- Create and manage listings

The project was built with a focus on learning real-world backend architecture, including:

- Database-driven API design
- Authentication
- Reverse proxy configuration
- Containerized deployment
- Server administration
- Frontend/backend communication

---

# Features

## User Management

The application supports:

- User registration
- User authentication
- JWT-based sessions
- User profiles
- Profile pictures
- Personal information

User profiles contain:

- Username
- Email
- Phone number
- Age
- Nationality
- Gender
- Biography

Lifestyle preferences:

- Smoking habits
- Pet ownership
- Party habits
- Food preferences

---

## Apartment and Roommate Listings

The platform supports apartment-related data:

- Creating listings
- Viewing available apartments
- Associating listings with users
- Filtering available options

The database structure allows expansion with additional features such as:

- Messaging
- Favorites
- Reviews
- Recommendations

---

# Architecture

The application uses a multi-container backend architecture.

High-level overview:

```
                         Client Browser

                              |
                              |
                              v

                           Nginx
                    Reverse Proxy / Gateway

                              |
        +---------------------+---------------------+
        |                                           |
        v                                           v

 PostgREST Main                           PostgREST Auth
        |                                           |
        v                                           v

 PostgreSQL Main                          PostgreSQL Auth


                              |
                              v

                       File Storage
```

---

# Technology Stack

## Frontend

- HTML5
- CSS3
- JavaScript
- Fetch API
- LocalStorage for client-side session handling

The frontend communicates with the backend through HTTP requests.

---

## Backend

### PostgreSQL

Used as the primary data storage system.

Features used:

- Relational database design
- Foreign keys
- UUID identifiers
- SQL functions
- Views
- JSON aggregation
- Extensions

---

### PostgREST

PostgREST automatically exposes PostgreSQL functions and tables as REST APIs.

Instead of writing a traditional backend framework, application logic is handled through:

- PostgreSQL functions
- SQL queries
- Database permissions

Example:

```
POST /rpc/add_user
```

calls a PostgreSQL function responsible for user creation.

---

### Nginx

Nginx is used as:

- Reverse proxy
- Static file server
- API gateway
- CORS configuration layer

Requests flow through Nginx before reaching internal services.

Example:

```
Browser
   |
   |
   v
Nginx :80
   |
   |
   v
PostgREST :3000
```

---

### Docker

All backend components run inside isolated containers.

Services:

- PostgreSQL authentication database
- PostgreSQL main database
- PostgREST authentication API
- PostgREST main API
- Nginx reverse proxy

---

# Repository Structure

Example structure:

```
.
├── docker-compose.yml
│
├── frontend/
│   ├── index.html
│   ├── rest of the pages
│   ├── images used on the pages
│   ├── JS files
│   └── CSS files
│
├── sql_scripts/
│   ├── jwt.sql
│   └── main.sql
│
├── env_files/
│   ├── postgres-auth.env
│   ├── postgres-main.env
│   ├── postgrest-auth.env
│   └── postgrest-main.env
│
├── nginx/
│   ├── certs
│   └── conf.d/
│       ├── nginx.conf
│       ├── roommates_http.conf
│       ├── roommates_https.conf
│       ├── file_cors.conf
│       └── psql_cors.conf
│
├── README.md
│
└──jwt_secret
```

---

# Backend Design

The backend intentionally separates authentication and application data.

Instead of having one large database, the project uses:

```
PostgreSQL Auth Database
        |
        |
        v

Authentication API


PostgreSQL Main Database
        |
        |
        v

Application API
```

This separation provides:

- Better organization
- Reduced coupling
- Easier future scaling
- Independent database management

---

# Database Architecture

The project uses two PostgreSQL instances.

---

## Authentication Database

Responsible for:

- Users
- Credentials
- Password hashing
- JWT generation
- Authentication-related functions

Example operations:

```
Register user
Login user
Generate JWT token
```

---

## Main Application Database

Responsible for:

- Apartment listings
- User-related application data
- Preferences
- Other platform functionality

---

# Authentication System

Authentication uses JWT tokens.

Registration flow:

```
User enters information

        |
        v

Frontend sends request

        |
        v

PostgREST RPC function

        |
        v

PostgreSQL creates user

        |
        v

JWT token returned

        |
        v

Frontend stores token
```

Example API call:

```
POST /rpc/add_user
```

The frontend stores the returned token and sends it with authenticated requests.

---

# File Storage

Profile pictures are handled separately from the database.

Flow:

```
User uploads image

        |
        v

Frontend converts image

        |
        v

HTTP PUT request

        |
        v

Nginx file handler

        |
        v

Stored file
```

Images are referenced by generated UUID identifiers.

---

# Docker Setup

The project uses Docker Compose.

Main services:

## postgres-auth

Authentication database.

## postgrest-auth

Authentication API.

## postgres-main

Main application database.

## postgrest-main

Main application API.

## nginx

Reverse proxy and static file server.

---

# Installation

## Requirements

Install:

- Docker
- Docker Compose
- PostgreSQL client tools (optional)

---

Clone the whole repository first.

# Environment Configuration

This repo comes with created .env files, but still look through them before running the system.

Also check the secret file. Modify values according to your environment.

Environment files contain:

- Database credentials
- Database names
- PostgREST configuration
- JWT configuration

---

# Database Initialization

The project requires two PostgreSQL databases, as described above.

Initialization scripts:

```
database/
├── jwt.sql <-------- authentication database
└── main.sql <------- main business logic database
```

# Frontend Configuration

For frontend configuration, pay attention to:

```
frontend/js/config.js
```

This file was specifically made to simplify changing target address for the frontend. Change it according to your needs.

---

# Deployment Notes

The original deployment used:

- Ubuntu Server VM
  - Docker Compose
  - Nginx
  - HTTPS certificates
  - PostgreSQL persistent volumes

Production-specific files are not included in this repository:

- SSL certificates
- Private environment files
- Server-specific paths
- Original database storage volumes

The repository contains the application structure and configuration required to understand and recreate the system.

---

# Future Improvements

Possible improvements:

- Automated database initialization through Docker
- Improved environment management
- Better frontend framework adoption
- More extensive testing
- CI/CD pipeline
- Improved API documentation
- Production-ready deployment scripts

---

# Lessons Learned

This project provided practical experience with:

- Designing relational databases
- PostgreSQL administration
- SQL functions
- REST API development
- JWT authentication
- Docker containerization
- Linux server management
- Nginx reverse proxy configuration
- Debugging deployed applications
- Frontend/backend integration

---

# License

MIT License
