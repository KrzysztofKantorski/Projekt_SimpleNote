using Microsoft.EntityFrameworkCore;
using Projekt_SimpleNote.Entities;

namespace Projekt_SimpleNote.Data
{
    public class ApplicationDbContext: DbContext
    {
        public ApplicationDbContext(DbContextOptions options) : base(options)
        {
        }

        //Db sets
        public DbSet<User> Users { get; set; } = null!;
        public DbSet<Note> Notes { get; set; } = null!;
        public DbSet<Subject> Subjects { get; set; } = null!;
        public DbSet<Tag> Tags { get; set; } = null!;
        public DbSet<RefreshToken> RefreshTokens { get; set; } = null!;
        public DbSet<Comment> Comments { get; set; } = null!;
        public DbSet<ReactionType> ReactionTypes { get; set; } = null!;
        public DbSet<NoteReaction> NoteReactions { get; set; } = null!;

        protected override void OnModelCreating(ModelBuilder modelBuilder) {

            //Use rules from Configurations
            modelBuilder.ApplyConfigurationsFromAssembly(typeof(ApplicationDbContext).Assembly);

        }
    }
}
