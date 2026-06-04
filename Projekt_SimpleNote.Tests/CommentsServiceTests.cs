using MockQueryable.Moq;
using Moq;
using Projekt_SimpleNote.Data;
using Projekt_SimpleNote.Dto.Comments;
using Projekt_SimpleNote.Entities;
using Projekt_SimpleNote.Services;

namespace Projekt_SimpleNote.Tests
{
    public class CommentsServiceTests
    {
        private Mock<ApplicationDbContext> CreateMockContext(List<Note>? notes = null, List<Comment>? comments = null, List<User>? users = null)
        {
            var mockContext = new Mock<ApplicationDbContext>();

            if (notes != null)
                mockContext.Setup(c => c.Notes).Returns(notes.BuildMockDbSet().Object);

            if (comments != null)
                mockContext.Setup(c => c.Comments).Returns(comments.BuildMockDbSet().Object);

            if (users != null)
            {
                var mockUsersDbSet = users.BuildMockDbSet();

                mockUsersDbSet.Setup(m => m.FindAsync(It.IsAny<object[]>()))
                              .Returns<object[]>(ids => new ValueTask<User?> (users.FirstOrDefault(u => u.Id == (long)ids[0])));
                mockContext.Setup(c => c.Users).Returns(mockUsersDbSet.Object);
            }

            return mockContext;
        }

        //Check if GetCommentsAsync returns comments for a public note

        [Fact]
        public async Task GetCommentsAsync_ShouldReturnComments_WhenNoteIsPublic()
        {
            // Test data
            var user = new User { Id = 1, Username = "testuser" };
            var note = new Note { Id = 1, IsPublic = true, UserId = 2 };
            var comment = new Comment { Id = 1, NoteId = 1, Content = "Test", User = user, Replies = new List<Comment>() };

            var mockContext = CreateMockContext(new List<Note> { note }, new List<Comment> { comment });
            var service = new CommentsService(mockContext.Object); 

            var result = await service.GetCommentsAsync(1, 99);

            Assert.True(result.Success);
            Assert.Single(result.Comments!);
            Assert.Equal("Test", result.Comments!.First().Content);
        }


        //Check if GetCommentsAsync returns false when the note is private and the user is not the owner
        [Fact]
        public async Task GetCommentsAsync_ShouldReturnFalse_WhenPermissionDenied()
        {
            // Create private note
            var note = new Note { Id = 1, IsPublic = false, UserId = 1 };
            var mockContext = CreateMockContext(notes: new List<Note> { note });
            var service = new CommentsService(mockContext.Object);

            var result = await service.GetCommentsAsync(1, 2);

            Assert.False(result.Success);
            Assert.Equal("Permision denied.", result.Message);
        }

        //Check if CreateCommentAsync adds a comment when the data is valid
        [Fact]
        public async Task CreateCommentAsync_ShouldAddComment_WhenDataIsValid()
        {
            //Create test data
            var user = new User { Id = 1, Username = "testuser" };
            var note = new Note { Id = 1, IsPublic = true };

            var mockContext = CreateMockContext
                (
                    notes: new List<Note> { note }, 
                    users: new List<User> { user }, 
                    comments: new List<Comment>()
                );

            var service = new CommentsService(mockContext.Object);

            //User data from request
            var dto = new CreateCommentDto("New Comment", null);

            var result = await service.CreateCommentAsync(1, 1, dto);

            Assert.True(result.Success);
            Assert.Equal("New Comment", result.Data!.Content);

            //Check if the comment was added to the context and saved
            mockContext.Verify(m => m.Comments.Add(It.IsAny<Comment>()), Times.Once);
            mockContext.Verify(m => m.SaveChangesAsync(It.IsAny<CancellationToken>()), Times.Once);
        }

        //Check if CreateCommentAsync returns false when the parent comment does not exist
        [Fact]
        public async Task CreateCommentAsync_ShouldReturnFalse_WhenParentCommentNotFound()
        {
            //Test data
            var note = new Note { Id = 1, IsPublic = true };
            var mockContext = CreateMockContext(notes: new List<Note> { note }, comments: new List<Comment>());
            var service = new CommentsService(mockContext.Object);

            //User data from request with non-existing parent comment id
            var dto = new CreateCommentDto ("Reply", 99 );

            var result = await service.CreateCommentAsync(1, 1, dto);

            Assert.False(result.Success);
            Assert.Equal("Comment does not exist.", result.Message);

            //Check if no comment was added and changes were not saved
            mockContext.Verify(m => m.SaveChangesAsync(It.IsAny<CancellationToken>()), Times.Never);
        }

        //Check if CreateCommentAsync returns false when the parent comment belongs to a different note
        [Fact]
        public async Task CreateCommentAsync_ShouldReturnFalse_WhenParentCommentBelongsToDifferentNote()
        {
            var note = new Note { Id = 1, IsPublic = true };
            var parentComment = new Comment { Id = 1, NoteId = 2 };

            var mockContext = CreateMockContext
                (
                    notes: new List<Note> { note }, 
                    comments: new List<Comment> { parentComment }
                );
            var service = new CommentsService(mockContext.Object);

            var dto = new CreateCommentDto("Reply", 1);

            var result = await service.CreateCommentAsync(1, 1, dto);

            Assert.False(result.Success);
            Assert.Equal("You cant answer to this comment.", result.Message);
        }



        //Check if DeleteCommentAsync removes the comment when the user is the owner
        [Fact]
        public async Task DeleteCommentAsync_ShouldRemoveComment_WhenUserIsOwner()
        {
            //Test data
            var comment = new Comment 
            { 
                Id = 1,
                NoteId = 1, 
                UserId = 1, 
                Replies = new List<Comment>() 
            };

            var mockContext = CreateMockContext(comments: new List<Comment> { comment });
            var service = new CommentsService(mockContext.Object);

            var result = await service.DeleteCommentAsync(noteId: 1, commentId: 1, currentUserId: 1);

            Assert.True(result.Success);

            //Check if the comment was removed from the context
            mockContext.Verify(m => m.Comments.Remove(comment), Times.Once);

            //Check if SaveChangesAsync was called
            mockContext.Verify(m => m.SaveChangesAsync(It.IsAny<CancellationToken>()), Times.Once);
        }

        //Check if DeleteCommentAsync returns false when the user is not the comment owner
        [Fact]
        public async Task DeleteCommentAsync_ShouldReturnFalse_WhenAccessDenied()
        {
            //Test data
            var comment = new Comment { Id = 1, NoteId = 1, UserId = 1 };
            var mockContext = CreateMockContext(comments: new List<Comment> { comment });
            var service = new CommentsService(mockContext.Object);

            var result = await service.DeleteCommentAsync(noteId: 1, commentId: 1, currentUserId: 2);

            Assert.False(result.Success);
            Assert.Equal("Access denied", result.Message);
            mockContext.Verify(m => m.Comments.Remove(It.IsAny<Comment>()), Times.Never);
        }

        //Check if DeleteCommentAsync returns false when the comment does not belong to the note
        [Fact]
        public async Task DeleteCommentAsync_ShouldReturnFalse_WhenCommentBelongsToDifferentNote()
        {
            var comment = new Comment 
            {
                Id = 1, 
                NoteId = 2, 
                UserId = 1 
            };

            var mockContext = CreateMockContext(comments: new List<Comment> { comment });

            var service = new CommentsService(mockContext.Object);

            var result = await service.DeleteCommentAsync(noteId: 1, commentId: 1, currentUserId: 1);

            Assert.False(result.Success);
            Assert.Equal("Comment does not belong to note", result.Message);
        }

    }
}
