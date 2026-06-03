using FluentValidation;
using Projekt_SimpleNote.Dto.Admin;

namespace Projekt_SimpleNote.Validators
{
    public class SubjectRequestDtoValidator : AbstractValidator<SubjectRequestDto>
    {
        public SubjectRequestDtoValidator()
        {
            RuleFor(x => x.Name)
                .NotEmpty().WithMessage("Subject name is required.")
                .MinimumLength(3).WithMessage("Incorrect subject name.")
                .MaximumLength(100).WithMessage("Incorrect subject name");
        }
    }
}
