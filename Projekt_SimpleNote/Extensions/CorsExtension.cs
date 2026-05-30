namespace Projekt_SimpleNote.Extensions
{
    public static class CorsExtension
    {
        public static IServiceCollection AddCorsConfiguration(this IServiceCollection services) {

            services.AddCors(options =>
            {
                options.AddPolicy("AdminPanelPolicy", 
                policy =>
                {
                    policy.WithOrigins(
                        "http://localhost:3000"
                    )
                    .AllowAnyHeader()
                    .AllowAnyMethod()
                    .AllowCredentials();
                });
            });
            return services;
        }
    }
}
