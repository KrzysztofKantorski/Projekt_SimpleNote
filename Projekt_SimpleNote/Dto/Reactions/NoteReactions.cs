namespace Projekt_SimpleNote.Dto.Reactions
{
    public record NoteReactionSummaryDto(
         long ReactionTypeId,
         string Name,
         string IconUrl,
         int Count,
         bool ReactedByCurrentUser 
    );
}
