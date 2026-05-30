using System.Xml.Linq;

namespace Projekt_SimpleNote.Entities
{
    public class User
    {
        public long Id { get; set; }
        public string Username { get; set; } = string.Empty;
        public string PasswordHash { get; set; } = string.Empty;
        public string Role { get; set; } = "User";
        public bool IsActive { get; set; } = true;
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public ICollection<RefreshToken> RefreshTokens { get; set; } = new List<RefreshToken>();
        public ICollection<Note> MyNotes { get; set; } = new List<Note>();
        public ICollection<Comment> Comments { get; set; } = new List<Comment>();
        public ICollection<NoteReaction> Reactions { get; set; } = new List<NoteReaction>();
        public ICollection<Note> SavedNotes { get; set; } = new List<Note>();
    }
}
