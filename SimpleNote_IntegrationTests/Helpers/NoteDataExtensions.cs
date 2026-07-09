using Projekt_SimpleNote.Data;
using Projekt_SimpleNote.Entities;

namespace SimpleNote_IntegrationTests.Helpers
{
    public static class NoteDataExtensions
    {
        public static Note CreateTestNote(
            this ApplicationDbContext context,
            User user,
            Subject ?subject,
            string title = "Test note",
            string content = "Note content",

            bool isPublic = true)
        {
            var testNote = new Note
            {
                Title = title,
                Content = content,
                User = user,
                IsPublic = isPublic,
                Subject = subject,
            };

            context.Notes.Add( testNote );

            return testNote;
        }


        public static NoteReaction CreateTestNoteReaction(
             this ApplicationDbContext context,
             Note note,
             ReactionType reactionType,
             User user) 
        {
            var testNoteReaction = new NoteReaction
            {
                Note = note,
                ReactionType = reactionType,
                User = user
            };

            context.NoteReactions.Add(testNoteReaction);

            return testNoteReaction;
        }
    }
}
