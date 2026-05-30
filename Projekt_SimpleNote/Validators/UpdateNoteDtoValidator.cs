using FluentValidation;
using Projekt_SimpleNote.Dto.Notes;

namespace Projekt_SimpleNote.Validators
{
    public class UpdateNoteDtoValidator : AbstractValidator<UpdateNoteDto>
    {
        public UpdateNoteDtoValidator()
        {
            RuleFor(x => x.Title)
                .NotEmpty().WithMessage("Note title is required")
                .MinimumLength(3).WithMessage("Incorrect title")
                .MaximumLength(50).WithMessage("Incorrect title");

            RuleFor(x => x.Content)
                .NotEmpty().WithMessage("Note content is required")
                .MaximumLength(5000).WithMessage("Incorrext note content");

            RuleFor(x => x.IsPublic)
               .NotNull().WithMessage("You must specify note type");

            RuleFor(x => x.SubjectName)
               .MaximumLength(50).WithMessage("Incorrext subject name");

            RuleForEach(x => x.TagNames).NotNull().WithMessage("Incorrect tags");
        }
    }
}
