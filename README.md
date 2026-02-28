# Auth0 Service – Rails App

This Rails application provides an integration with the Auth0 authentication service.  
It allows authentication and authorization using Auth0 as the identity provider.

---

## 🚀 Running the Application

The project is fully containerized using Docker.

To build and start the application, run:

```bash
docker compose up -d --build
```

This command will:

Build the Docker images
Start all required services
Run the app in detached mode

To stop the services:

```bash
docker compose down
```

Before running the application, you must define the following environment variables:

| Variable              | Description                                      |
| --------------------- | ------------------------------------------------ |
| `AUTH0_CLIENT_ID`     | The Client ID provided by Auth0                  |
| `AUTH0_CLIENT_SECRET` | The Client Secret provided by Auth0              |
| `AUTH0_DOMAIN`        | Your Auth0 domain (e.g. `your-tenant.auth0.com`) |
| `AUTH0_AUDIENCE`      | The API audience configured in Auth0             |
