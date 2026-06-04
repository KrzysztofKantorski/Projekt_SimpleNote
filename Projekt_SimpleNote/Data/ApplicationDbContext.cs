using Microsoft.EntityFrameworkCore;
using Projekt_SimpleNote.Entities;

namespace Projekt_SimpleNote.Data
{
    public class ApplicationDbContext: DbContext
    {
        public ApplicationDbContext(DbContextOptions options) : base(options)
        {
        }

        protected ApplicationDbContext()
        {
        }

        //Db sets
        public virtual DbSet<User> Users { get; set; } = null!;
        public virtual DbSet<Note> Notes { get; set; } = null!;
        public virtual DbSet<Subject> Subjects { get; set; } = null!;
        public virtual DbSet<Tag> Tags { get; set; } = null!;
        public virtual DbSet<RefreshToken> RefreshTokens { get; set; } = null!;
        public virtual DbSet<Comment> Comments { get; set; } = null!;
        public virtual DbSet<ReactionType> ReactionTypes { get; set; } = null!;
        public virtual DbSet<NoteReaction> NoteReactions { get; set; } = null!;

        protected override void OnModelCreating(ModelBuilder modelBuilder) {

            //Use rules from Configurations
            modelBuilder.ApplyConfigurationsFromAssembly(typeof(ApplicationDbContext).Assembly);

        }
    }
}
