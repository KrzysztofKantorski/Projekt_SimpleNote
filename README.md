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
git clone [https://github.com/YOUR_USERNAME/Projekt_SimpleNote.git](https://github.com/YOUR_USERNAME/Projekt_SimpleNote.git)
cd Projekt_SimpleNote
```
**2. Configure Environment Variables**
* DB_CONNECTION_STRING=Host=localhost;Database=simplenotedb;Username=postgres;Password=yourpassword
* JWT_SECRET=YourSuperSecretKeyThatIsAtLeast32CharactersLong!
* JWT_ISSUER=SimpleNoteAPI
* JWT_AUDIENCE=SimpleNoteApp

**3. Apply database migrations**
* dotnet ef database update

**4. Run API**
* dotnet run

**5. https://localhost:<PORT> (check console output for PORT)**
