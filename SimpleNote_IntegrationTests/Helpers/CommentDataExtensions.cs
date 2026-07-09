using Projekt_SimpleNote.Data;
using Projekt_SimpleNote.Entities;

namespace SimpleNote_IntegrationTests.Helpers
{
    public static class CommentDataExtensions
    {
        public static Comment CreateTestComment(
            this ApplicationDbContext context,
            User user,
            Note note,
            string content = "Test comment",
            Comment ?parentComment = null
            ) 
        {
            var testComment = new Comment
            {
                Content = content,
                User = user,
                Note = note,
                ParentComment = parentComment,
                CreatedAt = DateTime.UtcNow
            };

            context.Comments.Add(testComment);

            return testComment;

        }
    }
}
