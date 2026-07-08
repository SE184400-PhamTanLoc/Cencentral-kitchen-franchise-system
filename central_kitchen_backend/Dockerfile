FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 8080

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy csproj files and restore as distinct layers
COPY ["Central_kitchen_API/Central_kitchen_API.csproj", "Central_kitchen_API/"]
COPY ["Central_kitchen_Services/Central_kitchen_Services.csproj", "Central_kitchen_Services/"]
COPY ["Central_kitchen_Repositories/Central_kitchen_Repositories.csproj", "Central_kitchen_Repositories/"]
RUN dotnet restore "Central_kitchen_API/Central_kitchen_API.csproj"

# Copy everything else and build
COPY . .
WORKDIR "/src/Central_kitchen_API"
RUN dotnet build "Central_kitchen_API.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "Central_kitchen_API.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Central_kitchen_API.dll"]
