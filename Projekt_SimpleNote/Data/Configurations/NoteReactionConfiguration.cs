using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Projekt_SimpleNote.Entities;

namespace Projekt_SimpleNote.Data.Configurations
{
    public class NoteReactionConfiguration: IEntityTypeConfiguration<NoteReaction>
    {
        public void Configure(EntityTypeBuilder<NoteReaction> builder) {

            builder.ToTable("NoteReactions");

            builder.HasKey(nr => nr.Id);

            //Delete note reaction when not is deleted
            builder.HasOne(nr => nr.Note)
                .WithMany(n => n.Reactions)
                .HasForeignKey(nr => nr.NoteId)
                .OnDelete(DeleteBehavior.Cascade);


            builder.HasOne(nr => nr.User)
                .WithMany(u => u.Reactions)
                .HasForeignKey(nr => nr.UserId)
                .OnDelete(DeleteBehavior.Restrict);

            builder.HasOne(nr => nr.ReactionType)
                .WithMany(rt => rt.Reactions)
                .HasForeignKey(nr => nr.ReactionTypeId)
                .OnDelete(DeleteBehavior.Restrict);

            //Each reaction type can be added to note only once
            builder.HasIndex(nr => new { nr.NoteId, nr.UserId, nr.ReactionTypeId })
                .IsUnique();
        }
    }
}
