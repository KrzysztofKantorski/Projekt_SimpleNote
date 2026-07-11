using Projekt_SimpleNote.Data;
using Projekt_SimpleNote.Entities;

namespace SimpleNote_IntegrationTests.Helpers
{
    public static class AuthDataExtensions
    {
        public static User CreateTestAuthUser(
            this ApplicationDbContext context,
            string username="user",
            string passwordHash="Password123!",
            string role = "User",
            bool isActive = true
            )
        {
            var user = new User
            {
                Username = username,
                PasswordHash = BCrypt.Net.BCrypt.HashPassword(passwordHash),
                Role = role,
                IsActive = isActive
            };

            context.Users.Add(user);

            return user;
        }
    }
}
