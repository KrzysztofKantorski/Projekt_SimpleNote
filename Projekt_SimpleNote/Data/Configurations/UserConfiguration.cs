using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Projekt_SimpleNote.Entities;

namespace Projekt_SimpleNote.Data.Configurations
{
    public class UserConfiguration: IEntityTypeConfiguration<User>
    {
        public void Configure(EntityTypeBuilder<User> builder)
        {
            builder.ToTable("Users");

            builder.HasKey(u => u.Id);

            builder.Property(u => u.Username)
                .IsRequired();

            builder.Property(u => u.IsActive)
                .IsRequired();

            builder.HasIndex(u => u.Username)
                .IsUnique();

            builder.Property(u => u.PasswordHash)
                .IsRequired();

            builder.Property(u => u.Role)
                .IsRequired()
                .HasMaxLength(20)
                .HasDefaultValue("User");

            //Many-to-Many relation, cascade delete
            builder.HasMany(u => u.SavedNotes)
                .WithMany(n => n.SavedByUsers)
                .UsingEntity<Dictionary<string, object>>(
                    "SavedNotes",
                    j => j.HasOne<Note>().WithMany().HasForeignKey("NoteId").OnDelete(DeleteBehavior.Cascade),
                    j => j.HasOne<User>().WithMany().HasForeignKey("UserId").OnDelete(DeleteBehavior.Cascade)
                );

        }
    }
}
