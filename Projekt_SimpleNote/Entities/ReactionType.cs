namespace Projekt_SimpleNote.Entities
{
    public class ReactionType
    {
        public long Id { get; set; }
        public string Name { get; set; } = string.Empty; 
        public string IconUrl { get; set; } = string.Empty;
        public ICollection<NoteReaction> Reactions { get; set; } = new List<NoteReaction>();
    }
}
