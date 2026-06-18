using DotNetEnv;
using FluentValidation;
using Projekt_SimpleNote.Dto.Admin;
using Projekt_SimpleNote.Dto.Auth;
using Projekt_SimpleNote.Dto.Comments;
using Projekt_SimpleNote.Dto.Notes;
using Projekt_SimpleNote.Extensions;
using Projekt_SimpleNote.Middleware;
using Projekt_SimpleNote.Services;
using Projekt_SimpleNote.Services.Interfaces;
using Projekt_SimpleNote.Validators;
using Scalar.AspNetCore;
Env.Load();

var builder = WebApplication.CreateBuilder(args);
builder.WebHost.UseUrls("http://0.0.0.0:5168");
builder.Services.AddDatabaseConfiguration(builder.Configuration);


//Global exception handler
builder.Services.AddExceptionHandler<GlobalExceptionHandler>();
builder.Services.AddProblemDetails();

builder.Services.AddCorsConfiguration();
builder.Services.AddControllers();


builder.Services.AddEndpointsApiExplorer();
//Validators
builder.Services.AddScoped<IValidator<RegisterDto>, RegisterDtoValidator>();
builder.Services.AddScoped<IValidator<RegisterDto>, RegisterDtoValidator>();
builder.Services.AddScoped<IValidator<LoginDto>, LoginDtoValidator>();
builder.Services.AddScoped<IValidator<CreateNoteDto>, CreateNoteDtoValidator>();
builder.Services.AddScoped<IValidator<UpdateNoteDto>, UpdateNoteDtoValidator>();
builder.Services.AddScoped<IValidator<CreateCommentDto>, CreateCommentDtoValidator>();
builder.Services.AddScoped<IValidator<CreateReactionTypeDto>, CreateReactionTypeDtoValidator>();
builder.Services.AddScoped<IValidator<SubjectRequestDto>, SubjectRequestDtoValidator>();


//Services
builder.Services.AddScoped<IAuthService, AuthService>();
builder.Services.AddScoped<IUserService, UserService>();
builder.Services.AddScoped<INotesService, NotesService>();
builder.Services.AddScoped<IDictionaryService, DictionaryService>();
builder.Services.AddScoped<ICommunityService, CommunityService>();
builder.Services.AddScoped<ISavedNotesService, SavedNotesService>();
builder.Services.AddScoped<ICommentsService, CommentsService>();
builder.Services.AddScoped<IReactionsService, ReactionsService>();
builder.Services.AddScoped<IAdminUsersService, AdminUsersService>();
builder.Services.AddScoped<IAdminReactionsService, AdminReactionsSerwice>();
builder.Services.AddScoped<IAdminSubjectsService, AdminSubjectsService>();
builder.Services.AddScoped<IAdminCommentsService, AdminCommentsService>();
builder.Services.AddScoped<IAdminStatisticsService, AdminStatisticsService>();



builder.Services.AddOpenApiConfiguration();
builder.Services.AddJwtConfiguration();




var app = builder.Build();


if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
    app.MapScalarApiReference();
}

app.UseExceptionHandler();

app.UseHttpsRedirection();

app.UseCors("AdminPanelPolicy");

app.UseAuthentication();

app.UseAuthorization();

app.UseMiddleware<UserContextMiddleware>();

app.MapControllers();

app.Run();
