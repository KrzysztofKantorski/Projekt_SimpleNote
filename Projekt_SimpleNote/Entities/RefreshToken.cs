namespace Projekt_SimpleNote.Entities
{
    public class RefreshToken
    {
        public long Id { get; set; }
        public string Token { get; set; } = string.Empty;
        public DateTime ExpiresAt { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime? RevokedAt { get; set; } 
        public long UserId { get; set; }
        public User User { get; set; } = null!;
    }
}
