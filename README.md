# SimpleNote API 

Backend REST API for the SimpleNote mobile application (built with Flutter) and the Administrative Web Panel. Provides authentication, note management, social interactions (reactions, comments), and a management system.

## Technologies

* **Framework:** ASP.NET Core 8
* **Database:** PostgreSQL
* **ORM:** Entity Framework Core
* **Validation:** FluentValidation
* **Authentication:** JWT (JSON Web Tokens) with Refresh tokens 
* **Security:** BCrypt for password hashing, Middlewares

## Prerequisites

Before running the API locally, ensure you have the following installed:
* [.NET 9 SDK](https://dotnet.microsoft.com/download/dotnet/9.0)
* [PostgreSQL](https://www.postgresql.org/download/) (or Docker Desktop to run a Postgres container)
* Git

## Getting Started

**1. Clone the repository**
```bash
git clone https://github.com/KrzysztofKantorski/Projekt_SimpleNote
cd Projekt_SimpleNote
```
**2. Configure Environment Variables**
```
DB_CONNECTION_STRING=Host=localhost;Database=simplenotedb;Username=postgres;Password=yourpassword
JWT_SECRET=YourSuperSecretKey(min 32 characters)
JWT_ISSUER=SimpleNoteAPI
JWT_AUDIENCE=SimpleNoteApp
```

**3. Apply database migrations**
```
dotnet ef database update
```
**4. Run API**
``` 
dotnet run
```
**5. The app will start with http://localhost:PORT (check console output for PORT)**

## Authentication flow
This API uses a two-token architecture to maximize security and UX.

**1. Login (POST /api/auth/login)** 
* Returns an AccessToken (lives for 15 minutes) and a RefreshToken (lives for 7 days).

**2 Standard Requests**
* Attach the AccessToken to the Authorization header as a Bearer token:
Authorization: Bearer <AccessToken>

**3 Handling Token Expiration (401 Unauthorized)**
* The Flutter app must implement an HTTP Interceptor.
* When any request returns a 401 Unauthorized status, the interceptor should catch it, pause the request, and silently call using the saved RefreshToken: 
```
POST /api/auth/refresh
```
* On success, save the new tokens and automatically retry the original paused request.
* Do NOT send the RefreshToken with standard requests.

## API Documentation (Swagger)
API reference is automatically generated. You do not need to read through the source code to find endpoints or DTO structures.
Once the API is running, navigate to:
```
https://localhost:PORT/swagger
```
