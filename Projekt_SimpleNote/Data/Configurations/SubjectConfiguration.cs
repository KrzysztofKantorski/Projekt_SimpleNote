using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Projekt_SimpleNote.Entities;

namespace Projekt_SimpleNote.Data.Configurations
{
    public class SubjectConfiguration : IEntityTypeConfiguration<Subject>
    {
        public void Configure(EntityTypeBuilder<Subject> builder)
        {
            builder.ToTable("Subjects");

            builder.HasKey(s => s.Id);

            builder.Property(s => s.Name)
                .IsRequired();

            //Subjects must have unique names
            builder.HasIndex(s => s.Name)
                .IsUnique();
        }
    }
}
