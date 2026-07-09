using Microsoft.EntityFrameworkCore;
using Projekt_SimpleNote.Dto.Admin;
using Projekt_SimpleNote.Dto.Pagination;
using Projekt_SimpleNote.Entities;
using SimpleNote_IntegrationTests.Helpers;
using System.Net;
using System.Net.Http.Json;
using System.Runtime.ConstrainedExecution;

namespace SimpleNote_IntegrationTests
{
    public class AdminUsersControllerTests: BaseIntegrationTest
    {
        public AdminUsersControllerTests(CustomWebApplicationFactory factory): base(factory)
        { 
        }



        //Get users as admin
        [Fact]
        public async Task GetUsers_ShouldReturnOkAndUsers_WhenUserIsAdmin()
        {
            
            var admin = DbContext.CreateTestUser(role: "Admin");

            //Create test users
            for (int i = 0; i < 10; i++)
            {
                DbContext.CreateTestUser(username: $"user_{i}", role: "User");
            }

            //Save data
            await DbContext.SaveChangesAsync();

            Client.AuthenticateAs(admin);

            var url = "api/admin/users?PageNumber=2&PageSize=5";

            var response = await Client.GetAsync(url);

            //Check status code
            Assert.Equal(HttpStatusCode.OK, response.StatusCode);

            //Read JSON response
            var result = await response.Content.ReadFromJsonAsync<PagedResult<UserDetailsAdminDto>>();

            Assert.Equal(11, result.TotalCount);

            //Verify pagination
            Assert.Equal(3, result.TotalPages);
            Assert.Equal(2, result.CurrentPage);
            Assert.Equal(5, result.PageSize);
            Assert.Equal(5, result.Items.Count());

        }



        //Get users without authorization
        [Fact]
        public async Task GetUsers_ShouldReturnUnAuthorized_WhenUserIsNotLoggedIn()
        {
            var url = "api/admin/users?PageNumber=2&PageSize=5";

            var response = await Client.GetAsync(url);

            //Check status code
            Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
        }



        //Get users as regular user
        [Fact]
        public async Task GetUsers_ShouldReturnForbidden_WhenRegularUser()
        {
           
            var regularUser = DbContext.CreateTestUser(role: "User");

            //Save data
            await DbContext.SaveChangesAsync();

            Client.AuthenticateAs(regularUser);

            var url = "api/admin/users?PageNumber=2&PageSize=5";

            var response = await Client.GetAsync(url);

            //Check status code
            Assert.Equal(HttpStatusCode.Forbidden, response.StatusCode);
        }



        //Get user details as admin
        [Fact]
        public async Task GetUserDetails_ShouldReturnOkAndInfo_WhenUserIsAdmin()
        {
            var admin = DbContext.CreateTestUser(role: "Admin");

            var regularUser = DbContext.CreateTestUser(username: "regularUser", role: "User");

            var subject = DbContext.CreateTestSubject(name: "Test subject");


            //Create test data for user details

            for (int i = 0; i < 5; i++) {

                var note = DbContext.CreateTestNote(
                    user: regularUser,
                    content: $"Test note_{i}",
                    subject: subject,
                    title: $"Test title_{i}"
                );

                var comment = DbContext.CreateTestComment(
                    user: regularUser,
                    note: note,
                    content: $"Test comment_{i}"
                );

                DbContext.CreateTestNoteReaction(
                    user: regularUser,
                    note: note,
                    reactionType: new ReactionType
                    {
                        Name = $"Reaction_{i}",
                        IconUrl = "http://example.com/existingicon.png"
                    }
                );
            }

            await DbContext.SaveChangesAsync();

            Client.AuthenticateAs(admin);

            var url = $"api/admin/users/{regularUser.Id}";

            var response = await Client.GetAsync(url);

            //Check status code
            Assert.Equal(HttpStatusCode.OK, response.StatusCode);

            var jsonResponse = await response.Content.ReadFromJsonAsync<UserDetailsAdminDto>();

            //Check user details
            Assert.Equal("regularUser", jsonResponse.Username);
            Assert.Equal(5, jsonResponse.TotalNotes);
            Assert.Equal(5, jsonResponse.TotalComments);
            Assert.Equal(5, jsonResponse.TotalReactions);
        }



        //Ban user as admin
        [Fact]
        public async Task BanUser_ShouldReturnNoContentAndBanUser_WhenUserIsAdmin() 
        {
           
            var admin = DbContext.CreateTestUser(role: "Admin");

            var userToBan = DbContext.CreateTestUser(username: "UserToBan", role: "User");
           
            var refreshToken = DbContext.CreateTestRefreahToken(user: userToBan);

            await DbContext.SaveChangesAsync();


            Client.AuthenticateAs(admin);

            var url = $"/api/admin/users/{userToBan.Id}/ban";

            var response = await Client.PatchAsync(url, null);

            Assert.Equal(HttpStatusCode.NoContent, response.StatusCode);

            //Check if user is banned
            var bannedUserInDb = await DbContext.Users
               .AsNoTracking()
               .Include(u => u.RefreshTokens) 
               .FirstOrDefaultAsync(u => u.Id == userToBan.Id);

            Assert.NotNull(bannedUserInDb);

            //Check isActive flag
            Assert.False(bannedUserInDb.IsActive);

            //Check if token was deleted
            Assert.Empty(bannedUserInDb.RefreshTokens);
        }


        //Ban another admin
        [Fact]
        public async Task BanUser_ShouldReturnBadRequest_WhenAdminBansAnotherAdmin() 
        {
            var admin = DbContext.CreateTestUser(role: "Admin");

            var adminToBan = DbContext.CreateTestUser(username: "AdminToBan", role: "Admin");

            var refreshToken = DbContext.CreateTestRefreahToken(user: adminToBan);

            await DbContext.SaveChangesAsync();


            Client.AuthenticateAs(admin);

            var url = $"/api/admin/users/{adminToBan.Id}/ban";

            var response = await Client.PatchAsync(url, null);

            Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);

            //Verify that admin user was not banned
            var bannedUserInDb = await DbContext.Users
               .AsNoTracking()
               .Include(u => u.RefreshTokens)
               .FirstOrDefaultAsync(u => u.Id == adminToBan.Id);

            Assert.NotNull(bannedUserInDb);

            //Check isActive flag
            Assert.True(bannedUserInDb.IsActive);

            //Check if token was deleted
            Assert.NotNull(bannedUserInDb.RefreshTokens);
        }
    }
}
