using Projekt_SimpleNote.Data;
using Projekt_SimpleNote.Entities;

namespace SimpleNote_IntegrationTests.Helpers
{
    public static class UserDataExtensions
    {
        //Create test user
        public static User CreateTestUser(
            this ApplicationDbContext context,
            string username = "TestUser",
            string role = "User",
            bool isActive = true)
        {
            var user = new User
            {
                Username = username,
                Role = role,
                IsActive = isActive,
                CreatedAt = DateTime.UtcNow
            };

            context.Users.Add(user);
            return user;
        }
    }
}

