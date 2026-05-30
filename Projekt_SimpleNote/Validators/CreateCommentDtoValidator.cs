using FluentValidation;
using Projekt_SimpleNote.Dto.Interactions;

namespace Projekt_SimpleNote.Validators
{
    public class CreateCommentDtoValidator : AbstractValidator<CreateCommentDto>
    {
        public CreateCommentDtoValidator() 
        {
            RuleFor(x => x.Content)
               .MaximumLength(200).WithMessage("Incorrect title");
        }
    }
}
    