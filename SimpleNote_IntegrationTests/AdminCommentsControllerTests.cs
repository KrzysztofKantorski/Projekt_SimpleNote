using Projekt_SimpleNote.Dto.Comments;
using Projekt_SimpleNote.Dto.Pagination;
using Projekt_SimpleNote.Entities;
using System.Net.Http.Json;
using SimpleNote_IntegrationTests.Helpers;


namespace SimpleNote_IntegrationTests
{
    public class AdminCommentsControllerTests : BaseIntegrationTest
    {
        public AdminCommentsControllerTests(CustomWebApplicationFactory factory) : base(factory)
        {
            
        }

        [Fact]
        public async Task GetComments_ShouldReturnOkAndCommentsList_WhenUserIsAdmin()
        {
            //Create test data
            var testUser = new User
            {
                Username = "CommentAuthor",
                Role = "Admin"
            };

            var testNote = new Note
            {
                Title = "Testowa Notatka",
                Content = "Treść notatki",
                User = testUser
            };

            //Create test comments
            for (int i = 0; i < 15; i++)
            {
                DbContext.Comments.Add(new Comment
                {
                    Content = $"Test comment {i + 1}",
                    User = testUser,
                    CreatedAt = DateTime.UtcNow,
                    Note = testNote
                });
            }

            //Save data
            await DbContext.SaveChangesAsync();

            //Generate JWT token
            Client.AuthenticateAs(testUser);

            var url = "/api/admin/comments?pageNumber=1&PageSize=10";

            //Send request
            var response = await Client.GetAsync(url);

            //Verify status code
            Assert.Equal(System.Net.HttpStatusCode.OK, response.StatusCode);

            //Get JSON response message
            var pagedResult = await response.Content.ReadFromJsonAsync<PagedResult<CommentDto>>();

            //Verify response content
            Assert.NotNull(pagedResult);
            Assert.Equal(15, pagedResult.TotalCount);

            //Verify pagination
            Assert.Equal(2, pagedResult.TotalPages);
            Assert.Equal(1, pagedResult.CurrentPage);
            Assert.Equal(10, pagedResult.PageSize);
            Assert.Equal(10, pagedResult.Items.Count());
        }
    }
}