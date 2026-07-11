using Microsoft.EntityFrameworkCore;
using Projekt_SimpleNote.Dto.Auth;
using Projekt_SimpleNote.Entities;
using SimpleNote_IntegrationTests.Helpers;
using System.Net;
using System.Net.Http.Json;

namespace SimpleNote_IntegrationTests
{
    public class AuthControllerTests: BaseIntegrationTest
    {
        public AuthControllerTests(CustomWebApplicationFactory factory) : base(factory)
        {
        }

        [Fact]
        public async Task Register_ShouldReturnCreated_AndSaveUserInDb_WhenValid()
        {
            var registerDto = new RegisterDto(
                Username: "user",
                Password: "Password123!" 
            );

            var url = "/api/auth/register";

            var response = await Client.PostAsJsonAsync(url, registerDto);

            Assert.Equal(HttpStatusCode.Created, response.StatusCode);

            //Check if user was saved in db
            var userInDb = await DbContext.Users.FirstOrDefaultAsync(u => u.Username == registerDto.Username);
            Assert.NotNull(userInDb);

            //Check is password was hashed
            Assert.NotEqual("Password123!", userInDb.PasswordHash); 

            //Verify password hash
            Assert.True(BCrypt.Net.BCrypt.Verify("Password123!", userInDb.PasswordHash));
        }



        [Fact]
        public async Task Register_ShouldReturnBadRequest_WhenUsernameAlreadyExists()
        {
            var existingUser = DbContext.CreateTestUser("ExistingUser");
            await DbContext.SaveChangesAsync();

            var registerDto = new RegisterDto(
               Username: "ExistingUser",
               Password: "Password123!"
           );

            var url = "/api/auth/register";

            var response = await Client.PostAsJsonAsync(url, registerDto);

            Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
        }



        [Fact]
        public async Task Login_ShouldReturnOk_AndSetCookie_WhenCredentialsAreValid()
        {
            var user = DbContext.CreateTestAuthUser("user", "Password123!");

            await DbContext.SaveChangesAsync();

            var loginDto = new LoginDto
            (
                Username: "user",
                Password: "Password123!" 
            );

            var url = "/api/auth/login";

            var response = await Client.PostAsJsonAsync(url, loginDto);

            Assert.Equal(HttpStatusCode.OK, response.StatusCode);

            //Check if tokens were returned
            var result = await response.Content.ReadFromJsonAsync<LoginResponseMock>();
            Assert.NotNull(result);
            Assert.NotNull(result.Tokens);
            Assert.NotNull(result.Tokens.AccessToken);
            Assert.NotNull(result.Tokens.RefreshToken);

            //Check if refresh token was created
            var tokenInDb = await DbContext.RefreshTokens.FirstOrDefaultAsync(rt => rt.UserId == user.Id);
            Assert.NotNull(tokenInDb);
            Assert.Equal(result.Tokens.RefreshToken, tokenInDb.Token);

            //Check if cookie was set
            Assert.True(response.Headers.Contains("Set-Cookie"));
            var cookie = response.Headers.GetValues("Set-Cookie").FirstOrDefault();
            Assert.Contains("refreshToken=", cookie);
        }






        [Fact]
        public async Task Login_ShouldReturnUnauthorized_WhenUserIsBanned()
        {
            var bannedUser = DbContext.CreateTestAuthUser(
                username: "BannedUser",
                passwordHash: "Password123!",
                isActive: false
            );

            await DbContext.SaveChangesAsync();

            var loginDto = new LoginDto ( Username: "BannedUser", Password: "Password123" );
            var url = "/api/auth/login";

            var response = await Client.PostAsJsonAsync(url, loginDto);

            Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
        }



        [Fact]
        public async Task Refresh_ShouldReturnOk_AndNewTokens_WhenRefreshTokenIsValid()
        {
            var user = DbContext.CreateTestAuthUser("user");
           
            DbContext.CreateTestRefreahToken(user: user);
            await DbContext.SaveChangesAsync();

            var refreshDto = new RefreshTokenRequestDto ( RefreshToken: "dummy-token");
            var url = "/api/auth/refresh";

            var response = await Client.PostAsJsonAsync(url, refreshDto);

            Assert.Equal(HttpStatusCode.OK, response.StatusCode);

            //Old token must be revoked
            var revokedTokenInDb = await DbContext.RefreshTokens.AsNoTracking().FirstOrDefaultAsync(t => t.Token == "dummy-token");
            Assert.NotNull(revokedTokenInDb.RevokedAt); 

            //New token was generated
            var newTokensCount = await DbContext.RefreshTokens.CountAsync(t => t.UserId == user.Id && t.RevokedAt == null);
            Assert.Equal(1, newTokensCount);
        }


        [Fact]
        public async Task Refresh_ShouldReturnUnauthorized_WhenRefreshTokenIsExpired()
        {
            var user = DbContext.CreateTestUser();
            
            var expiredToken = DbContext.CreateTestRefreahToken(
                user: user, 
                expiresAt: DateTime.UtcNow.AddDays(-1)
            );
            await DbContext.SaveChangesAsync();

            var refreshDto = new RefreshTokenRequestDto ( RefreshToken: "expired-token" );
            var url = "/api/auth/refresh";
            var response = await Client.PostAsJsonAsync(url, refreshDto);

            Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
        }


        [Fact]
        public async Task Logout_ShouldReturnOk_AndRevokeToken_WhenValid()
        {
            // Arrange
            var user = DbContext.CreateTestUser();
            
            var tokenToRevoke = DbContext.CreateTestRefreahToken(
                user: user,
                expiresAt: DateTime.UtcNow.AddDays(7),
                token: "token-to-logout"
            );

            await DbContext.SaveChangesAsync();

            Client.AuthenticateAs(user);

            var logoutDto = new RefreshTokenRequestDto( RefreshToken: "token-to-logout" );
            var url = "/api/auth/logout";

            var response = await Client.PostAsJsonAsync(url, logoutDto);

            Assert.Equal(HttpStatusCode.OK, response.StatusCode);

            //Check if revokedAt was updated
            var revokedTokenInDb = await DbContext.RefreshTokens.AsNoTracking().FirstOrDefaultAsync(t => t.Token == "token-to-logout");
            Assert.NotNull(revokedTokenInDb);
            Assert.NotNull(revokedTokenInDb.RevokedAt); 

            //Check if cookie was deleted
            Assert.True(response.Headers.Contains("Set-Cookie"));
            var cookie = response.Headers.GetValues("Set-Cookie").FirstOrDefault();
            Assert.Contains("refreshToken=", cookie);
            Assert.Contains("expires=", cookie.ToLower()); 
        }
        private class LoginResponseMock
        {
            public string Message { get; set; }
            public TokenResponseDto Tokens { get; set; } 
        }
    }
}
