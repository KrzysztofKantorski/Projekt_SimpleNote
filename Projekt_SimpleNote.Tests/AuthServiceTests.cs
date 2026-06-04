using MockQueryable.Moq;
using Moq;
using Projekt_SimpleNote.Data;
using Projekt_SimpleNote.Dto.Auth;
using Projekt_SimpleNote.Entities;
using Projekt_SimpleNote.Services;

namespace Projekt_SimpleNote.Tests
{
    public class AuthServiceTests
    {
        //Create enviroment for jwt token generation
        public AuthServiceTests()
        {
            Environment.SetEnvironmentVariable("JWT_SECRET", "skdjflsjdflkjsldjflskjdlfjsdlkfjlskdf");
            Environment.SetEnvironmentVariable("JWT_ISSUER", "TestIssuer");
            Environment.SetEnvironmentVariable("JWT_AUDIENCE", "TestAudience");
        }

        private Mock<ApplicationDbContext> CreateMockContext(List<User>? users = null, List<RefreshToken>? tokens = null)
        {
            var mockContext = new Mock<ApplicationDbContext>();

            if (users != null)
                mockContext.Setup(c => c.Users).Returns(users.BuildMockDbSet().Object);

            if (tokens != null)
                mockContext.Setup(c => c.RefreshTokens).Returns(tokens.BuildMockDbSet().Object);

            return mockContext;
        }


        [Fact]
        public async Task RegisterAsync_ShouldCreateUser_WhenUsernameIsUnique()
        {
            var mockContext = CreateMockContext(users: new List<User>());
            var service = new AuthService(mockContext.Object);
            var dto = new RegisterDto ("newUser", "password123" );

            var result = await service.RegisterAsync(dto);

            Assert.True(result.Success);
            Assert.Equal("Registration went successfully.", result.Message);
            mockContext.Verify(m => m.Users.AddAsync(It.IsAny<User>(), It.IsAny<CancellationToken>()), Times.Once);
            mockContext.Verify(m => m.SaveChangesAsync(It.IsAny<CancellationToken>()), Times.Once);
        }


        [Fact]
        public async Task RegisterAsync_ShouldReturnFalse_WhenUsernameAlreadyExists()
        {
            var existingUser = new User { Id = 1, Username = "existingUser" };
            var mockContext = CreateMockContext(users: new List<User> { existingUser });
            var service = new AuthService(mockContext.Object);
            var dto = new RegisterDto("existingUser", "password123");

            var result = await service.RegisterAsync(dto);

            Assert.False(result.Success);
            Assert.Equal("Username alerdy in use", result.Message);

            //Nothing must be saved to db
            mockContext.Verify(m => m.SaveChangesAsync(It.IsAny<CancellationToken>()), Times.Never);
        }

        [Fact]
        public async Task LoginAsync_ShouldReturnTokens_WhenCredentialsAreValid()
        {
            
            var plainPassword = "myPassword";
            var hashedPassword = BCrypt.Net.BCrypt.HashPassword(plainPassword);
            var user = new User 
            { 
                Id = 1,
                Username = "admin", 
                PasswordHash = hashedPassword,
                IsActive = true, 
                Role = "User" 
            };

            var mockContext = CreateMockContext(users: new List<User> { user }, tokens: new List<RefreshToken>());
            var service = new AuthService(mockContext.Object);
            var dto = new LoginDto ("admin", plainPassword);

            var result = await service.LoginAsync(dto);

            Assert.True(result.Success);
            Assert.NotNull(result.Tokens);
            Assert.NotEmpty(result.Tokens!.AccessToken);
            Assert.NotEmpty(result.Tokens!.RefreshToken);

            //Verify that refresh token was saved to db
            mockContext.Verify(m => m.RefreshTokens.AddAsync(It.IsAny<RefreshToken>(), It.IsAny<CancellationToken>()), Times.Once);
            mockContext.Verify(m => m.SaveChangesAsync(It.IsAny<CancellationToken>()), Times.Once);
        }


        [Fact]
        public async Task LoginAsync_ShouldReturnFalse_WhenPasswordIsIncorrect()
        {
            var plainPassword = "myPassword";
            var hashedPassword = BCrypt.Net.BCrypt.HashPassword(plainPassword);

            var user = new User { Id = 1, Username = "admin", PasswordHash = hashedPassword, IsActive = true };
            var mockContext = CreateMockContext(users: new List<User> { user });
            var service = new AuthService(mockContext.Object);

            //Send incorrect password
            var dto = new LoginDto ("admin", "wrongPassword");

            var result = await service.LoginAsync(dto);

            Assert.False(result.Success);
            Assert.Equal("Incorrect username or password", result.Message);
        }


        [Fact]
        public async Task LoginAsync_ShouldReturnFalse_WhenUserIsInactive()
        {
            var user = new User 
            { 
                Id = 1, 
                Username = "bannedUser", 
                IsActive = false 
            }; 
            var mockContext = CreateMockContext(users: new List<User> { user });
            var service = new AuthService(mockContext.Object);
            var dto = new LoginDto ("bannedUser", "anyPassword" );

            var result = await service.LoginAsync(dto);

            // User exists but is not active, so login should fail
            Assert.False(result.Success);
            Assert.Equal("Your account is not active.", result.Message);
        }


        [Fact]
        public async Task RefreshTokenAsync_ShouldReturnNewTokens_WhenTokenIsValid()
        {
            //Test data
            var user = new User 
            { 
                Id = 1, 
                Username = "test", 
                IsActive = true, 
                Role = "User" 
            };

            var activeToken = new RefreshToken
            {
                Token = "old-valid-token",
                UserId = 1,
                User = user,
                ExpiresAt = DateTime.UtcNow.AddDays(1), 
                RevokedAt = null 
            };

            var mockContext = CreateMockContext(tokens: new List<RefreshToken> { activeToken });
            var service = new AuthService(mockContext.Object);

            var result = await service.RefreshTokenAsync("old-valid-token");

            Assert.True(result.Success);
            Assert.NotNull(result.Tokens);

            //Old token should be revoked
            Assert.NotNull(activeToken.RevokedAt);

            //Verify that new refresh token was saved to db
            mockContext.Verify(m => m.RefreshTokens.AddAsync(It.IsAny<RefreshToken>(), It.IsAny<CancellationToken>()), Times.Once);
            mockContext.Verify(m => m.SaveChangesAsync(It.IsAny<CancellationToken>()), Times.Once);
        }


        [Fact]
        public async Task RefreshTokenAsync_ShouldReturnFalse_WhenTokenIsExpired()
        {
            //Test data
            var user = new User { Id = 1, IsActive = true };
            var expiredToken = new RefreshToken
            {
                Token = "expired-token",
                UserId = 1,
                User = user,

                //Token expired yesterday
                ExpiresAt = DateTime.UtcNow.AddDays(-1), 
                RevokedAt = null
            };

            var mockContext = CreateMockContext(tokens: new List<RefreshToken> { expiredToken });
            var service = new AuthService(mockContext.Object);

            var result = await service.RefreshTokenAsync("expired-token");

            // Token is expired, so refresh should fail
            Assert.False(result.Success);
            Assert.Equal("Session expired. Log in again", result.Message);
        }


        [Fact]
        public async Task LogoutAsync_ShouldRevokeToken_WhenTokenExistsAndIsActive()
        {
            // Arrange
            var activeToken = new RefreshToken
            {
                Token = "valid-token-to-logout",

                //Not revoked yet
                RevokedAt = null 
            };

            var mockContext = CreateMockContext(tokens: new List<RefreshToken> { activeToken });
            var service = new AuthService(mockContext.Object);

            var result = await service.LogoutAsync("valid-token-to-logout");

            Assert.True(result.Success);

            //Verify that token got revokation date
            Assert.NotNull(activeToken.RevokedAt);

            //Verify that changes were saved to db
            mockContext.Verify(m => m.SaveChangesAsync(It.IsAny<CancellationToken>()), Times.Once);
        }

        [Fact]
        public async Task LogoutAsync_ShouldReturnFalse_WhenTokenDoesNotExist()
        {
            //Create empty token list
            var mockContext = CreateMockContext(tokens: new List<RefreshToken>());
            var service = new AuthService(mockContext.Object);

            var result = await service.LogoutAsync("non-existing-token");

            Assert.False(result.Success);
            Assert.Equal("Incorrect token", result.Message);
        }
    }
}
