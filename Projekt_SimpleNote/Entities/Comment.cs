namespace Projekt_SimpleNote.Entities
{
    public class Comment
    {
        public long Id { get; set; }
        public long NoteId { get; set; }
        public Note Note { get; set; } = null!;
        public long UserId { get; set; }
        public User User { get; set; } = null!;
        public long? ParentCommentId { get; set; }
        public Comment? ParentComment { get; set; }
        public ICollection<Comment> Replies { get; set; } = new List<Comment>();
        public string Content { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public bool IsHiddenByAdmin { get; set; } = false;
    }
}
