using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Projekt_SimpleNote.Entities;

namespace Projekt_SimpleNote.Data.Configurations
{
    public class NoteConfiguration: IEntityTypeConfiguration<Note>
    {
        public void Configure(EntityTypeBuilder<Note> builder) {

            builder.ToTable("Notes");

            builder.HasKey(n => n.Id);

            builder.Property(n => n.Title)
                .IsRequired();

            builder.Property(n => n.Content)
                .IsRequired();

            //Cascade delete - when user is deleted, his notes also
            builder.HasOne(n => n.User)
                .WithMany(u => u.MyNotes)
                .HasForeignKey(n => n.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            //Cascade delete - when subject is deleted, change subjectId to Null
            builder.HasOne(n => n.Subject)
                .WithMany(s => s.Notes)
                .HasForeignKey(n => n.SubjectId)
                .OnDelete(DeleteBehavior.SetNull);
        }
    }
}
