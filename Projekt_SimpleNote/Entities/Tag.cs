namespace Projekt_SimpleNote.Entities
{
    public class Tag
    {
        public long Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public ICollection<Note> Notes { get; set; } = new List<Note>();
    }
}
