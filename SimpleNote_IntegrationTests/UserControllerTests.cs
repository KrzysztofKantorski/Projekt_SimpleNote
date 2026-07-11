using Projekt_SimpleNote.Dto.Users;
using SimpleNote_IntegrationTests.Helpers;
using System.Net;
using System.Net.Http.Json;

namespace SimpleNote_IntegrationTests
{
    public class UserControllerTests: BaseIntegrationTest
    {
        public UserControllerTests(CustomWebApplicationFactory factory) : base(factory) 
        {
        }


        [Fact]
        public async Task GetUserProfile_ShouldReturnOkAndUser() 
        {
            var user = DbContext.CreateTestUser("user");

            await DbContext.SaveChangesAsync();

            var url = "api/users/me";

            Client.AuthenticateAs(user);

            var response = await Client.GetAsync(url);

            Assert.Equal(HttpStatusCode.OK, response.StatusCode);

            var result = await response.Content.ReadFromJsonAsync<UserProfileDto>();

            Assert.NotNull(result);
            Assert.Equal(user.Id, result.Id);
        }


        

        [Fact]
        public async Task GetUserProfile_ShouldReturnUnAuthorized_WhenUserNotAuthorized()
        {
            var user = DbContext.CreateTestUser("user");

            await DbContext.SaveChangesAsync();

            var url = "api/users/me";

            var response = await Client.GetAsync(url);

            Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
        }
    }
}
