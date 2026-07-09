using Microsoft.EntityFrameworkCore;
using Projekt_SimpleNote.Dto.Comments;
using Projekt_SimpleNote.Entities;
using SimpleNote_IntegrationTests.Helpers;
using System.Net;
using System.Net.Http.Json;

namespace SimpleNote_IntegrationTests
{
    public class CommentsControllerTests: BaseIntegrationTest
    {
        public CommentsControllerTests(CustomWebApplicationFactory factory) : base(factory)
        {
        }



        [Fact]
        public async Task GetNoteComments_ShouldReturnOkAndCommentsWithReplies_WhenValid() {

            //Create test data
            
            var user = DbContext.CreateTestUser(role: "User");

            var note = DbContext.CreateTestNote(
                title: "Test note",
                content: "Test note content",
                user: user,
                subject: new Subject
                {
                    Name = "Test subject"
                }
            );

            var comment = DbContext.CreateTestComment(
                content: "Test comment",
                user: user,
                note: note
            );

            var reply = DbContext.CreateTestComment(
                content: "Test comment reply",
                parentComment: comment,
                note: note,
                user: user
            );

            await DbContext.SaveChangesAsync();

            Client.AuthenticateAs(user);

            var url = $"/api/notes/{note.Id}/comments";

            var response = await Client.GetAsync(url);

            //Check status code
            Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        }



        [Fact]
        public async Task GetNoteComments_ShouldReturnBadRequest_WhenNoteIsNotPublic() 
        {
            //Create test data
            var user_1 = DbContext.CreateTestUser(username: "user1", role: "User");
            var user_2 = DbContext.CreateTestUser(username: "user2", role: "User");

            var note = DbContext.CreateTestNote(
                title: "Test note",
                content: "Test note content",
                user: user_2,
                isPublic: false,
                subject: new Subject
                {
                    Name = "Test subject"
                }
            );

            await DbContext.SaveChangesAsync();

            Client.AuthenticateAs(user_1);

            var url = $"/api/notes/{note.Id}/comments";

            var response = await Client.GetAsync(url);

            //Check status code
            Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
        }



        [Fact]
        public async Task AddNoteComment_ShouldReturnCreated_WhenValid() 
        {
            //Create test data
            var user = DbContext.CreateTestUser(role: "User");
        
            var note = DbContext.CreateTestNote(
               title: "Test note",
               content: "Test note content",
               user: user,
               isPublic: false,
               subject: new Subject
               {
                   Name = "Test subject"
               }
            );

            var comment = new CreateCommentDto
            (
               Content: "Test comment",
               ParentCommentId: null
            );

            await DbContext.SaveChangesAsync();

            Client.AuthenticateAs(user);

            var url = $"/api/notes/{note.Id}/comments";

            var response = await Client.PostAsJsonAsync(url, comment);

            Assert.Equal(HttpStatusCode.NoContent, response.StatusCode);


            //Verify that comment was added
            var commentInDb = await DbContext.Comments
                .AsNoTracking()
                .FirstOrDefaultAsync(c => c.NoteId == note.Id);

            Assert.NotNull(commentInDb);
            Assert.Equal(comment.Content, commentInDb.Content);
            Assert.Equal(user.Id, commentInDb.UserId);
            Assert.Equal(note.Id, commentInDb.NoteId);
        }



        [Fact]
        public async Task AddNoteComment_ShouldReturnBadRequest_WhenParentCommentDoesNotExist() 
        {
            var user = DbContext.CreateTestUser(role: "User");
      
            var note = DbContext.CreateTestNote(
               title: "Test note",
               content: "Test note content",
               user: user,
               isPublic: false,
               subject: new Subject
               {
                   Name = "Test subject"
               }
            );

            var comment = new CreateCommentDto
            (
                 Content: "Test comment",
                 ParentCommentId: 99
            );


            await DbContext.SaveChangesAsync();

            Client.AuthenticateAs(user);

            var url = $"/api/notes/{note.Id}/comments";

            var response = await Client.PostAsJsonAsync(url, comment);

            Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);

            //Verify that comment was not added
            var commentInDb = await DbContext.Comments
                .AsNoTracking()
                .FirstOrDefaultAsync(c => c.NoteId == note.Id);

            Assert.Null(commentInDb);
        }



        [Fact]
        public async Task DeleteNoteComment_ShouldReturnNoContent_WhenValid() 
        {
            var user = DbContext.CreateTestUser(role: "User");

            var note = DbContext.CreateTestNote(
                title: "Test note",
                content: "Test note content",
                user: user,
                isPublic: false,
                subject: new Subject
                {
                    Name = "Test subject"
                }
             );

            var comment = DbContext.CreateTestComment(
                content: "Test comment",
                user: user,
                note: note
            );

            await DbContext.SaveChangesAsync();

            Client.AuthenticateAs(user);

            var url = $"/api/notes/{note.Id}/comments/{comment.Id}";

            var response = await Client.DeleteAsync(url);

            Assert.Equal(HttpStatusCode.NoContent, response.StatusCode);

            //Check if comment was deleted
            var deletedComment = await DbContext.Comments
                .AsNoTracking()
                .FirstOrDefaultAsync(c => c.NoteId == note.Id);

            Assert.Null(deletedComment);
        }



        [Fact]
        public async Task DeleteNoteComment_ShouldReturnForbidden_WhenUserIsNotCommentAuthor() 
        {
            var user_1 = DbContext.CreateTestUser(username: "user1", role: "User");
            var user_2 = DbContext.CreateTestUser(username: "user2", role: "User");


            var note = DbContext.CreateTestNote(
               title: "Test note",
               content: "Test note content",
               user: user_2,
               subject: new Subject
               {
                   Name = "Test subject"
               }
            );

            var comment = DbContext.CreateTestComment(
               content: "Test comment",
               user: user_2,
               note: note
           );


            await DbContext.SaveChangesAsync();

            Client.AuthenticateAs(user_1);

            var url = $"/api/notes/{note.Id}/comments/{comment.Id}";

            var response = await Client.DeleteAsync(url);

            Assert.Equal(HttpStatusCode.Forbidden, response.StatusCode);

            //Check if comment was deleted
            var commentInDb = await DbContext.Comments
                .AsNoTracking()
                .FirstOrDefaultAsync(c => c.NoteId == note.Id);

            Assert.NotNull(commentInDb);
        }
    }
}
