namespace Projekt_SimpleNote.Entities
{
    public class NoteReaction
    {
        public long Id { get; set; } 

        public long NoteId { get; set; }
        public Note Note { get; set; } = null!;

        public long UserId { get; set; }
        public User User { get; set; } = null!;

        public long ReactionTypeId { get; set; }
        public ReactionType ReactionType { get; set; } = null!;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}
