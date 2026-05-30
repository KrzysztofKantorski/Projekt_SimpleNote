namespace Projekt_SimpleNote.Entities
{
    public class Note
    {
        public long Id { get; set; }
        public long UserId { get; set; }
        public User User { get; set; } = null!;
        public long? SubjectId { get; set; } 
        public Subject? Subject { get; set; }
        public string Title { get; set; } = string.Empty;
        public string Content { get; set; } = string.Empty; 
        public bool IsPublic { get; set; } = false;
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime? UpdatedAt { get; set; }
        public ICollection<Comment> Comments { get; set; } = new List<Comment>();
        public ICollection<NoteReaction> Reactions { get; set; } = new List<NoteReaction>();
        public ICollection<Tag> Tags { get; set; } = new List<Tag>();
        public ICollection<User> SavedByUsers { get; set; } = new List<User>();
    }
}
