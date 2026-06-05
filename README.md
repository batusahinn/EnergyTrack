# EnergyTrack

A full-stack energy consumption monitoring system built with **ASP.NET Core Web API** and **Flutter**. Devices report energy readings to the REST API; an anomaly detection service automatically raises alerts when readings spike beyond normal levels.

Built as a portfolio project for an IQB Solutions job application.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Backend API | ASP.NET Core Web API (.NET 10) |
| Database | PostgreSQL 16 (Docker) |
| ORM | Entity Framework Core 10 + Npgsql |
| Auth | JWT Bearer Tokens + BCrypt |
| Mobile | Flutter 3.44 (Android & iOS) |
| State | Provider |
| Charts | fl_chart |
| Container | Docker + docker-compose |

---

## Features

- **JWT Authentication** — register, login, all API routes protected
- **Device Management** — CRUD for energy monitoring devices (electricity, gas, water, solar)
- **Readings** — time-series energy readings per device with unit tracking
- **Anomaly Detection** — automatically creates an `Alert` when a reading exceeds 2× the 10-reading rolling average
- **Alerts** — queryable per device, dismissible from the mobile app
- **Flutter Mobile App** — login, dashboard, device list with live charts, alert management

---

## Project Structure

```
EnergyTrack/
├── backend/                        # ASP.NET Core Web API
│   ├── Controllers/                # Auth, Devices, Readings, Alerts
│   ├── Data/AppDbContext.cs        # EF Core DbContext
│   ├── Migrations/                 # EF Core migrations
│   ├── Models/                     # Device, Reading, Alert, User
│   ├── Repositories/               # Repository pattern interfaces + implementations
│   ├── Services/
│   │   ├── AuthService.cs          # Register / login / JWT generation
│   │   └── AnomalyService.cs       # Spike detection → auto-alert
│   └── Program.cs
├── mobile/                         # Flutter app
│   └── lib/
│       ├── main.dart
│       ├── models/                 # Device, Reading, Alert
│       ├── services/api_service.dart
│       └── screens/
│           ├── login_screen.dart
│           ├── dashboard_screen.dart
│           ├── devices_screen.dart  # includes fl_chart line graph
│           └── alerts_screen.dart
├── docker-compose.yml
└── CLAUDE.md
```

---

## Getting Started

### Prerequisites

- [.NET 10 SDK](https://dotnet.microsoft.com/download)
- [Docker Desktop](https://www.docker.com/products/docker-desktop)
- [Flutter 3.44+](https://flutter.dev/docs/get-started/install)
- Android emulator or physical device

### 1. Start the database

```bash
docker compose up -d
```

### 2. Run EF Core migrations

```bash
cd backend
dotnet ef database update
```

### 3. Start the API

```bash
dotnet run --launch-profile http
# Listening on http://localhost:5113
```

### 4. Run the Flutter app

```bash
cd mobile
flutter run
```

> The app targets `10.0.2.2:5113` — the Android emulator's alias for `localhost`. For a physical device, update `_baseUrl` in `lib/services/api_service.dart` to your machine's local IP.

---

## API Reference

Base URL: `http://localhost:5113/api/v1`

### Auth (public)

| Method | Endpoint | Body |
|---|---|---|
| `POST` | `/auth/register` | `{ username, password }` |
| `POST` | `/auth/login` | `{ username, password }` → `{ token }` |

All routes below require `Authorization: Bearer <token>`.

### Devices

| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/devices` | List all devices |
| `GET` | `/devices/{id}` | Get device by ID |
| `POST` | `/devices` | Create device `{ name, location, type }` |
| `PUT` | `/devices/{id}` | Update device |
| `DELETE` | `/devices/{id}` | Delete device (cascades readings + alerts) |

### Readings

| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/readings` | All readings |
| `GET` | `/readings/{id}` | Reading by ID |
| `GET` | `/readings/device/{deviceId}` | Readings for a device |
| `POST` | `/readings` | Record reading `{ deviceId, value, unit, timestamp? }` |
| `DELETE` | `/readings/{id}` | Delete reading |

> Posting a reading triggers `AnomalyService` — if the value exceeds 2× the rolling average of the last 10 readings, an alert is created automatically.

### Alerts

| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/alerts` | All alerts |
| `GET` | `/alerts/{id}` | Alert by ID |
| `GET` | `/alerts/device/{deviceId}` | Alerts for a device |
| `POST` | `/alerts` | Create alert manually `{ deviceId, message, timestamp? }` |
| `DELETE` | `/alerts/{id}` | Dismiss alert |

---

## Anomaly Detection

`AnomalyService` runs on every new reading:

1. Fetches the **last 10 readings** for the device (excluding the new one)
2. Requires **≥ 3 readings** as a baseline — skips silently otherwise
3. If `newValue > 2 × average`, creates an alert:

```
Anomaly detected: 350.00 kWh is 3.5x the 5-reading average of 100.00 kWh.
```

---

## Environment

API configuration lives in `backend/appsettings.json`:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Host=localhost;Port=5432;Database=energytrack;Username=postgres;Password=postgres"
  },
  "Jwt": {
    "Key": "your-secret-key-min-32-chars",
    "Issuer": "EnergyTrack.API",
    "Audience": "EnergyTrack.Client"
  }
}
```

> Change `Jwt:Key` before deploying to production.
