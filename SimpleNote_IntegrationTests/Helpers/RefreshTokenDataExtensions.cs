using Projekt_SimpleNote.Data;
using Projekt_SimpleNote.Entities;
namespace SimpleNote_IntegrationTests.Helpers
{
    public static class RefreshTokenDataExtensions
    {
        public static RefreshToken CreateTestRefreahToken(
            this ApplicationDbContext context,
            User user,
            string token = "dummy-token",
            DateTime? expiresAt = null)
        {
            var refreshToken = new RefreshToken
            {
                User = user,
                Token = token,
                ExpiresAt = DateTime.UtcNow.AddDays(7)
            };

            context.RefreshTokens.Add(refreshToken);

            return refreshToken;
        }
    }
}
