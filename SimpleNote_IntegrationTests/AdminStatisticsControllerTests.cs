using Projekt_SimpleNote.Dto.Statistics;
using Projekt_SimpleNote.Entities;
using SimpleNote_IntegrationTests.Helpers;
using System.Net;
using System.Net.Http.Json;

namespace SimpleNote_IntegrationTests
{
    public class AdminStatisticsControllerTests: BaseIntegrationTest
    {
        public AdminStatisticsControllerTests(CustomWebApplicationFactory factory) : base(factory)
        {
        }

        //Get dashboard statistics as admin
        [Fact]
        public async Task GetDashboardStatistics_ShouldReturnOkAndStatistics_WhenUserIsAdmin()
        {
            //Create test data
            var testUser = new User
            {
                Username = "TestAdmin",
                Role = "Admin"
            };

            //Save data
            DbContext.Users.Add(testUser);
            await DbContext.SaveChangesAsync();

            //Generate JWT token
            Client.AuthenticateAs(testUser);

            var url = "/api/admin/stats";

            //Send request
            var response = await Client.GetAsync(url);

            //Assert response
            Assert.Equal(HttpStatusCode.OK, response.StatusCode);

            var result = await response.Content.ReadFromJsonAsync<DashboardStatsDto>();
            Assert.NotNull(result);
        }



        //Get dashboard statistics as regular user
        [Fact]
        public async Task GetDashboardStatistics_ShouldReturnForbidden_WhenUserIsNotAdmin()
        {
            //Create test data
            var testUser = new User
            {
                Username = "TestUser",
                Role = "User"
            };

            //Save data
            DbContext.Users.Add(testUser);
            await DbContext.SaveChangesAsync();

            //Generate JWT token
            Client.AuthenticateAs(testUser);

            var url = "/api/admin/stats";

            //Send request
            var response = await Client.GetAsync(url);

            //Check status code
            Assert.Equal(HttpStatusCode.Forbidden, response.StatusCode);
        }
    }
}
