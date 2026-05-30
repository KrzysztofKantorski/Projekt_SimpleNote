using FluentValidation;
using Projekt_SimpleNote.Dto.Auth;

namespace Projekt_SimpleNote.Validators
{
    public class LoginDtoValidator : AbstractValidator<LoginDto>
    {
        public LoginDtoValidator()
        {
            RuleFor(x => x.Username)
                .NotEmpty().WithMessage("Username is required")
                .MinimumLength(3).WithMessage("Incorrect username")
                .MaximumLength(50).WithMessage("Incorrect username");
            RuleFor(x => x.Password)
                .NotEmpty().WithMessage("Password is required.");
        }
    }
}
