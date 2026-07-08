using Microsoft.EntityFrameworkCore;
using Projekt_SimpleNote.Dto.Comments;
using Projekt_SimpleNote.Dto.Pagination;
using Projekt_SimpleNote.Entities;
using SimpleNote_IntegrationTests.Helpers;
using System.Net;
using System.Net.Http.Json;


namespace SimpleNote_IntegrationTests
{
    public class AdminCommentsControllerTests : BaseIntegrationTest
    {
        public AdminCommentsControllerTests(CustomWebApplicationFactory factory) : base(factory)
        {
            
        }


        //Get comments as admin
        [Fact]
        public async Task GetComments_ShouldReturnOkAndCommentsList_WhenUserIsAdmin()
        {
            //Create test data
            var testUser = new User
            {
                Username = "TestAdmin",
                Role = "Admin"
            };

            var testNote = new Note
            {
                Title = "Test note",
                Content = "Note content",
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
            Assert.Equal(HttpStatusCode.OK, response.StatusCode);

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


        //Get comments as regular user
        [Fact]
        public async Task GetComments_ShouldReturnForbidden_WhenUserIsNotAdmin() 
        { 
            //create regular user
            var user = new User
            {
                Username = "RegularUser",
                Role = "User"
            };

            //Save user
            DbContext.Users.Add(user);
            await DbContext.SaveChangesAsync();

            //Authenticate as regular user
            Client.AuthenticateAs(user);

            var url = "/api/admin/comments?pageNumber=1&PageSize=10";

            //Send request
            var response = await Client.GetAsync(url);

            //Chech status code
            Assert.Equal(HttpStatusCode.Forbidden, response.StatusCode);
        }




        //Delete comment as admin
        [Fact]
        public async Task DeleteComment_ShouldHideCommentAndReplies_WhenUserIsAdmin()
        {
            var testUser = new User 
            {
                Username = "TestAdmin",
                Role = "Admin" 
            };

            var testNote = new Note
            {
                Title = "Test note for deletion",
                Content = "Note content",
                User = testUser
            };

            var parentComment = new Comment
            {
                Content = "Parent comment",
                User = testUser,
                Note = testNote,
                CreatedAt = DateTime.UtcNow
            };


            var replyComment = new Comment
            {
                Content = "Reply comment",
                User = testUser,
                Note = testNote,
                ParentComment = parentComment,
                CreatedAt = DateTime.UtcNow
            };

            //Save data
            DbContext.Comments.AddRange(parentComment, replyComment);
            await DbContext.SaveChangesAsync();

            Client.AuthenticateAs(testUser);

            var url = $"/api/admin/comments/{parentComment.Id}";

            //Send request
            var response = await Client.DeleteAsync(url);

            //Check status code
            Assert.Equal(HttpStatusCode.NoContent, response.StatusCode);

            //Verify that comments are in db
            var parentCommentInDb = await DbContext.Comments.AsNoTracking().FirstOrDefaultAsync(c => c.Id == parentComment.Id);
            var replyCommentInDb = await DbContext.Comments.AsNoTracking().FirstOrDefaultAsync(c => c.Id == replyComment.Id);

            Assert.NotNull(parentCommentInDb);
            Assert.NotNull(replyCommentInDb);

            //Verify that comments are hidden
            Assert.True(parentCommentInDb.IsHiddenByAdmin);
            Assert.True(replyCommentInDb.IsHiddenByAdmin);
        }



        //Delete comment that does not exist
        [Fact]
        public async Task DeleteComment_ShouldReturnBadRequest_WhenCommentDoesNotExist()
        {
            var testUser = new User 
            {
                Username = "TestAdmin",
                Role = "Admin" 
            };

            DbContext.Users.Add(testUser);
            await DbContext.SaveChangesAsync();

            Client.AuthenticateAs(testUser);

            //Try to delete comment with id that does not exist
            var commentId = 999;
            var url = $"/api/admin/comments/{commentId}";

            var response = await Client.DeleteAsync(url);

            //Check status code
            Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
        }

    }
}