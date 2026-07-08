using Microsoft.EntityFrameworkCore;
using Projekt_SimpleNote.Dto.Admin;
using Projekt_SimpleNote.Dto.Pagination;
using Projekt_SimpleNote.Entities;
using SimpleNote_IntegrationTests.Helpers;
using System.Net;
using System.Net.Http.Json;

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
            var admin = new User
            {
                Username = "TestAdmin",
                Role = "Admin"
            };
            DbContext.Users.Add(admin);

            //Create test users

            for (int i = 0; i < 10; i++)
            {
                DbContext.Users.Add
                (
                    new User
                    {
                        Username = $"User_{i}",
                        Role = "User"
                    }
                );
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
            var user = new User
            {
                Username = "TestAdmin",
                Role = "User"
            };

            DbContext.Users.Add(user);

            //Save data
            await DbContext.SaveChangesAsync();

            Client.AuthenticateAs(user);

            var url = "api/admin/users?PageNumber=2&PageSize=5";

            var response = await Client.GetAsync(url);

            //Check status code
            Assert.Equal(HttpStatusCode.Forbidden, response.StatusCode);
        }



        //Get user details as admin
        [Fact]
        public async Task GetUserDetails_ShouldReturnOkAndInfo_WhenUserIsAdmin()
        {
            var admin = new User
            {
                Username = "TestAdmin",
                Role = "Admin"
            };

            DbContext.Users.Add(admin);

            var user = new User
            {
                Username = "TestUser",
                Role = "User"
            };
            DbContext.Users.Add(user);

            var subject = new Subject 
            { 
                Name = "Test subject" 
            };
            DbContext.Subjects.Add(subject);


            //Create test data for user details

            for (int i = 0; i < 5; i++) {

                var note = new Note
                {
                    User = user,
                    Content = $"Test note_{i}",
                    Subject = subject,
                    Title = $"Test title_{i}" 
                };
                DbContext.Notes.Add(note);

                DbContext.Comments.Add(new Comment 
                    { 
                        User = user,
                        Note = note,
                        Content = $"Test comment_{i}"
                    }
                );

                DbContext.NoteReactions.Add(new NoteReaction
                    {
                        User = user,
                        Note = note,
                        ReactionType = new ReactionType
                        {
                            Name = $"Reaction_{i}",
                            IconUrl = "http://example.com/existingicon.png"
                        }
                    }
               );
            }

            await DbContext.SaveChangesAsync();

            Client.AuthenticateAs(admin);

            var url = $"api/admin/users/{user.Id}";

            var response = await Client.GetAsync(url);

            //Check status code
            Assert.Equal(HttpStatusCode.OK, response.StatusCode);

            var jsonResponse = await response.Content.ReadFromJsonAsync<UserDetailsAdminDto>();

            //Check user details
            Assert.Equal("TestUser", jsonResponse.Username);
            Assert.Equal(5, jsonResponse.TotalNotes);
            Assert.Equal(5, jsonResponse.TotalComments);
            Assert.Equal(5, jsonResponse.TotalReactions);
        }



        //Ban user as admin
        [Fact]
        public async Task BanUser_ShouldReturnNoContentAndBanUser_WhenUserIsAdmin() 
        {
            var admin = new User
            {
                Username = "TestAdmin",
                Role = "Admin"
            };

            DbContext.Users.Add(admin);

            var userToBan = new User 
            {
                Username= "TestUser",
                Role= "User",
                IsActive = true
            };
            DbContext.Users.Add(userToBan);

            var refreshToken = new RefreshToken
            {
                User = userToBan,
                Token = "dummy-token",
                ExpiresAt = DateTime.UtcNow.AddDays(7)
            };

            DbContext.RefreshTokens.Add(refreshToken);

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
            var admin = new User
            {
                Username = "TestAdmin",
                Role = "Admin"
            };
            DbContext.Users.Add(admin);


            var adminToBan = new User
            {
                Username = "TestAdminToBan",
                Role = "Admin",
                IsActive = true
            };
            DbContext.Users.Add(adminToBan);


            var refreshToken = new RefreshToken
            {
                User = adminToBan,
                Token = "dummy-token",
                ExpiresAt = DateTime.UtcNow.AddDays(7)
            };

            DbContext.RefreshTokens.Add(refreshToken);

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
