using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Projekt_SimpleNote.Entities;

namespace Projekt_SimpleNote.Data.Configurations
{
    public class TagConfiguration: IEntityTypeConfiguration<Tag>
    {
        public void Configure(EntityTypeBuilder<Tag> builder) {

            builder.ToTable("Tags");

            builder.HasKey(t => t.Id);

            builder.Property(t => t.Name)
                .IsRequired();

            //Tag name must be unique
            builder.HasIndex(t => t.Name)
                .IsUnique();

            //Many-to-Many relation - cascade delete
            builder.HasMany(t => t.Notes)
                .WithMany(n => n.Tags)
                .UsingEntity<Dictionary<string, object>>(
                    "NoteTags",
                    j => j.HasOne<Note>().WithMany().HasForeignKey("NoteId").OnDelete(DeleteBehavior.Cascade),
                    j => j.HasOne<Tag>().WithMany().HasForeignKey("TagId").OnDelete(DeleteBehavior.Cascade)
                );
        }
    }
}
