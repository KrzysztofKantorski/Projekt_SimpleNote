using Moq;
using Projekt_SimpleNote.Data;
using Projekt_SimpleNote.Entities;
using Projekt_SimpleNote.Services;
using MockQueryable.Moq;
using Projekt_SimpleNote.Dto.Pagination;

namespace Projekt_SimpleNote.Tests
{
    public class AdminCommentsServiceTests
    {
        //mocking db context
        private Mock<ApplicationDbContext> CreateMockContextWithComments(List<Comment> commentsData)
        {
            //Create a mock DbSet for Comments
            var mockDbSet = commentsData.BuildMockDbSet();

            var mockContext = new Mock<ApplicationDbContext>();

            //Setup the Comments DbSet to return the mock data
            mockContext.Setup(c => c.Comments).Returns(mockDbSet.Object);

            return mockContext;
        }


        //Test for GetAllCommentsAsync method
        [Fact]
        public async Task GetAllCommentsAsync_ShouldReturnOnlyVisibleParentComments()
        {

            //Create paginarionParams object
            var paginationParams = new PaginationParamsDto(1, 10);

            //create test user
            var user = new User { Id = 1, Username = "TestUser" };

            //create test comment data
            var commentsData = new List<Comment>
            {
                //Main, visible comment
                new Comment
                {
                    Id = 1,
                    Content = "Visible Parent",
                    IsHiddenByAdmin = false,
                    ParentCommentId = null,
                    CreatedAt = DateTime.UtcNow,
                    User = user,
                    Replies = new List<Comment>()
                },

                //Main, hidden comment
                new Comment {
                    Id = 2,
                    Content = "Hidden Parent",
                    IsHiddenByAdmin = true,
                    ParentCommentId = null,
                    CreatedAt = DateTime.UtcNow,
                    User = user,
                    Replies = new List<Comment>()
                },

                //Reply to visible comment
                new Comment 
                { 
                    Id = 3, 
                    Content = "Reply", 
                    IsHiddenByAdmin = false, 
                    ParentCommentId = 1, 
                    CreatedAt = DateTime.UtcNow, 
                    User = user 
                }
            };

            //Create mock context with test data
            var mockContext = CreateMockContextWithComments(commentsData);

            //Create service instance with mocked context
            var service = new AdminCommentsService(mockContext.Object);

            //Call service method
            var result = await service.GetAllCommentsAsync(paginationParams);

            var resultList = result.Items.ToList();

            Assert.Single(resultList);

            //Verify that only the visible parent comment is returned
            Assert.Equal("Visible Parent", resultList.First().Content);

            //Verify pagination
            Assert.Equal(1, result.TotalCount); 
            Assert.Equal(1, result.CurrentPage);
            Assert.Equal(10, result.PageSize);
            Assert.Equal(1, result.TotalPages);
        }


        //Test for DeleteCommentAsync method when comment exists
        // - should hide comment and its replies

        [Fact]
        public async Task DeleteCommentAsync_ShouldHideCommentAndReplies_WhenCommentExists()
        {

            var commentId = 1L;

            //Creact test reply to comment
            var reply = new Comment 
            { 
                Id = 2, 
                ParentCommentId = commentId, 
                IsHiddenByAdmin = false 
            };

            //Create parent comment and add reply to it
            var parentComment = new Comment
            {
                Id = commentId,
                IsHiddenByAdmin = false,
                Replies = new List<Comment> { reply }
            };

            //Empty db with parent comment and reply
            var commentsData = new List<Comment> { parentComment };

            var mockContext = CreateMockContextWithComments(commentsData);

            //service method
            var service = new AdminCommentsService(mockContext.Object);


            var result = await service.DeleteCommentAsync(commentId);

            Assert.True(result.Success);

            //Chech if parent comment got hidden flag
            Assert.True(parentComment.IsHiddenByAdmin);

            //Check if flag is added to reply
            Assert.True(reply.IsHiddenByAdmin);

            //Check db changes
            mockContext.Verify(m => m.SaveChangesAsync(It.IsAny<CancellationToken>()), Times.Once());
        }


        //Test for DeleteCommentAsync method when comment does not exist
        [Fact]
        public async Task DeleteCommentAsync_ShouldReturnFalse_WhenCommentDoesNotExist()
        {
            //Empty db
            var commentsData = new List<Comment>();

            var mockContext = CreateMockContextWithComments(commentsData);

            //service method
            var service = new AdminCommentsService(mockContext.Object);

            //Try to delete non-existing comment
            var result = await service.DeleteCommentAsync(999);

            Assert.False(result.Success);
            Assert.Equal("Comment not found", result.Message);

            //Verify db
            mockContext.Verify(m => m.SaveChangesAsync(It.IsAny<CancellationToken>()), Times.Never());
        }
    }
}
