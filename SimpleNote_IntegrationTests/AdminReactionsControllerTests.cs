using Microsoft.EntityFrameworkCore;
using Projekt_SimpleNote.Dto.Admin;
using Projekt_SimpleNote.Dto.Pagination;
using Projekt_SimpleNote.Entities;
using SimpleNote_IntegrationTests.Helpers;
using System.Net;
using System.Net.Http.Json;

namespace SimpleNote_IntegrationTests
{
    public class AdminReactionsControllerTests : BaseIntegrationTest
    {
        public AdminReactionsControllerTests(CustomWebApplicationFactory factory) : base(factory)
        {
        }



        //Get reaction types as admin
        [Fact]
        public async Task GetReactionsAsAdmin_ShouldReturnOkAndReactionsList_WhenUserIsAdmin()
        {
            //Create test data
            var testUser = new User
            {
                Username = "TestAdmin",
                Role = "Admin"
            };
            for (int i = 0; i < 10; i++)
            {
                var reactionType = new ReactionType
                {
                    Name = $"ReactionType{i}",
                    IconUrl = $"http://example.com/icon{i}.png"
                };
                DbContext.ReactionTypes.Add(reactionType);
            }
            DbContext.Users.Add(testUser);
            await DbContext.SaveChangesAsync();

            Client.AuthenticateAs(testUser);

            var url = "/api/admin/reactions?pageNumber=2&PageSize=5";

            //Send request
            var response = await Client.GetAsync(url);

            //verify status code
            Assert.Equal(HttpStatusCode.OK, response.StatusCode);

            //Get JSON response message
            var pagedResult = await response.Content.ReadFromJsonAsync<PagedResult<ReactionTypeDto>>();

            //Verify response content
            Assert.NotNull(pagedResult);
            Assert.Equal(10, pagedResult.TotalCount);

            //Verify pagination
            Assert.Equal(2, pagedResult.TotalPages);
            Assert.Equal(2, pagedResult.CurrentPage);
            Assert.Equal(5, pagedResult.PageSize);
            Assert.Equal(5, pagedResult.Items.Count());
        }




        //Get reaction types as regular user
        [Fact]
        public async Task GetReactionsAsRegularUser_ShouldReturnForbidden_WhenUserIsNotAdmin()
        {
            //Create test data
            var testUser = new User
            {
                Username = "TestUser",
                Role = "User"
            };
            DbContext.Users.Add(testUser);
            await DbContext.SaveChangesAsync();

            Client.AuthenticateAs(testUser);
            var url = "/api/admin/reactions?pageNumber=1&PageSize=5";

            //Send request
            var response = await Client.GetAsync(url);

            //Verify status code
            Assert.Equal(HttpStatusCode.Forbidden, response.StatusCode);
        }



        //Create new reaction type as admin
        [Fact]
        public async Task CreateReactionTypeAsAdmin_ShouldReturnCreated_WhenUserIsAdmin()
        {
            //Create test data
            var testUser = new User
            {
                Username = "TestAdmin",
                Role = "Admin"
            };

            var newReactionType = new CreateReactionTypeDto
            (
                Name: "NewReaction",
                IconUrl: "http://example.com/newicon.png"
            );

            //Save data
            DbContext.Users.Add(testUser);
            await DbContext.SaveChangesAsync();
            Client.AuthenticateAs(testUser);

            var url = "/api/admin/reactions";

            //Send request
            var response = await Client.PostAsJsonAsync(url, newReactionType);

            //Verify status code
            Assert.Equal(HttpStatusCode.Created, response.StatusCode);

            //Find the created reaction type in the database
            var createdReactionType = await DbContext.ReactionTypes.FirstOrDefaultAsync(rt => rt.Name == newReactionType.Name);

            //Verify that the reaction type was created
            Assert.NotNull(createdReactionType);

        }



        //Add reaction type when it already exists
        [Fact]
        public async Task CreateReactionTypeAsAdmin_ShouldReturnBadRequest_WhenReactionAlerdyExists()
        {
            var testUser = new User
            {
                Username = "TestAdmin",
                Role = "Admin"
            };

            var existingReactionType = new ReactionType
            {
                Name = "ExistingReaction",
                IconUrl = "http://example.com/existingicon.png"
            };

            var newReactionType = new CreateReactionTypeDto
            (
                Name: "ExistingReaction",
                IconUrl: "http://example.com/existingicon.png"
            );

            //Save data
            DbContext.Users.Add(testUser);
            DbContext.ReactionTypes.Add(existingReactionType);
            await DbContext.SaveChangesAsync();

            Client.AuthenticateAs(testUser);

            var url = "/api/admin/reactions";

            //Send request
            var response = await Client.PostAsJsonAsync(url, newReactionType);

            //Verify status code
            Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);

            //Verify that the reaction type was not created again
            var reactionTypesCount = await DbContext.ReactionTypes.CountAsync(rt => rt.Name == newReactionType.Name);

            //There should be only one reaction type with the same name
            Assert.Equal(1, reactionTypesCount);
        }



        [Fact]
        public async Task UpdateReactionTypeAsAdmin_ShouldReturnOk_WhenUserIsAdmin()
        {
            var testUser = new User
            {
                Username = "TestAdmin",
                Role = "Admin"
            };

            var existingReactionType = new ReactionType
            {
                Name = "ExistingReaction",
                IconUrl = "http://example.com/existingicon.png"
            };

            var updatedReactionTypeDto = new CreateReactionTypeDto
            (
               Name: "UpdatedReaction",
               IconUrl: "http://example.com/updatedicon.png"
            );

            //Save data
            DbContext.Users.Add(testUser);
            DbContext.ReactionTypes.Add(existingReactionType);
            await DbContext.SaveChangesAsync();

            Client.AuthenticateAs(testUser);

            var url = $"/api/admin/reactions/{existingReactionType.Id}";

            //Send request
            var response = await Client.PutAsJsonAsync(url, updatedReactionTypeDto);

            //Verify status code
            Assert.Equal(HttpStatusCode.OK, response.StatusCode);

            //Verify that the reaction type was updated in the database
            var updatedReactionTypeInDb = await DbContext.ReactionTypes.AsNoTracking().FirstOrDefaultAsync(rt => rt.Id == existingReactionType.Id);

            Assert.NotNull(updatedReactionTypeInDb);
            Assert.Equal(updatedReactionTypeDto.Name, updatedReactionTypeInDb.Name);
            Assert.Equal(updatedReactionTypeDto.IconUrl, updatedReactionTypeInDb.IconUrl);
        }


        //Delete reaction type as admin
        [Fact]
        public async Task DeleteReactionTypeAsAdmin_ShouldReturnNoContent_WhenUserIsAdmin()
        {
            var testUser = new User
            {
                Username = "TestAdmin",
                Role = "Admin"
            };

            var existingReactionType = new ReactionType
            {
                Name = "ExistingReaction",
                IconUrl = "http://example.com/existingicon.png"
            };

            //Save data
            DbContext.Users.Add(testUser);
            DbContext.ReactionTypes.Add(existingReactionType);
            await DbContext.SaveChangesAsync();

            Client.AuthenticateAs(testUser);

            var url = $"/api/admin/reactions/{existingReactionType.Id}";

            //Send request
            var response = await Client.DeleteAsync(url);

            //Verify status code
            Assert.Equal(HttpStatusCode.NoContent, response.StatusCode);

            //Verify that the reaction type was deleted from the database
            var deletedReactionTypeInDb = await DbContext.ReactionTypes.AsNoTracking().FirstOrDefaultAsync(rt => rt.Id == existingReactionType.Id);
            Assert.Null(deletedReactionTypeInDb);
        }



        //Delete reaction type that is used in notes
        [Fact]
        public async Task DeleteReactionTypeAsAdmin_ShouldReturnBadRequest_WhenReactionIsUsedInNotes()
        {
            var testUser = new User
            {
                Username = "TestAdmin",
                Role = "Admin"
            };

            var existingReactionType = new ReactionType
            {
                Name = "ExistingReaction",
                IconUrl = "http://example.com/existingicon.png"
            };

            var note = new Note
            {
                Title = "Test Note",
                Content = "This is a test note.",
                User = testUser
            };

            var reaction = new NoteReaction
            {
                Note = note,
                ReactionType = existingReactionType,
                User = testUser
            };

            //Save data
            DbContext.Users.Add(testUser);
            DbContext.ReactionTypes.Add(existingReactionType);
            DbContext.Notes.Add(note);
            DbContext.NoteReactions.Add(reaction);

            await DbContext.SaveChangesAsync();

            Client.AuthenticateAs(testUser);

            var url = $"/api/admin/reactions/{existingReactionType.Id}";

            //Send request
            var response = await Client.DeleteAsync(url);

            //Verify status code
            Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);

            //Verify that the reaction type was not deleted from the database
            var reactionTypeInDb = await DbContext.ReactionTypes.AsNoTracking().FirstOrDefaultAsync(rt => rt.Id == existingReactionType.Id);
            Assert.NotNull(reactionTypeInDb);
        }
    }
}
