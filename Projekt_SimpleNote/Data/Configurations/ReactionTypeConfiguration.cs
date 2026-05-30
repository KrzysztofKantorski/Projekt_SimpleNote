using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Projekt_SimpleNote.Entities;

namespace Projekt_SimpleNote.Data.Configurations
{
    public class ReactionTypeConfiguration: IEntityTypeConfiguration<ReactionType>
    {
        public void Configure(EntityTypeBuilder<ReactionType> builder) {

            builder.ToTable("ReactionTypes");

            builder.HasKey(rt => rt.Id);

            builder.Property(rt => rt.Name)
                .IsRequired();

            builder.Property(rt => rt.IconUrl)
                .IsRequired();

            builder.HasIndex(rt => rt.Name)
                .IsUnique();
        }
    }
}
