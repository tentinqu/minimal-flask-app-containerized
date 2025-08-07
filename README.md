# Minimal Flask App in Docker — With Healthchecks 

This is a minimal Flask web app containerized using Docker — simple in purpose, but rich in learning. From `COPY` quirks to unexpected container health issues, this README documents the final working setup and the debugging process that led here. Note that the original repository does not have healthcheck mechanisms, but is added here. 

[Minimal SS](https://github.com/tentinqu/minimal-flask-app-containerized/blob/master/minimal-flask-screesnshots/3.png)

---

## Project Structure

```
.
├── main.py
└── Dockerfile
```

---

## `main.py`

```python
from flask import Flask

app = Flask(__name__)

@app.route('/')
def hello():
    return 'Hello from Dockerized Flask!'

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
```

---

## Dockerfile (Final Version)

```dockerfile
FROM python:3.9-slim

# Set working directory
WORKDIR /app

# Copy the application code
COPY main.py .

# Install dependencies
RUN pip install Flask && apt update && apt install -y curl

# Expose the port Flask runs on
EXPOSE 5000

# Add healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
  CMD curl -f http://localhost:5000/ || exit 1

# Start the app
CMD ["python", "main.py"]
```

> **Note:** The `HEALTHCHECK` functionality was not part of the original repository. It was added manually, along with debugging steps to ensure it worked correctly.

---

## Building & Running

### Build the Docker image

```bash
docker build -t flask-min .
```

### Run the container

```bash
docker run -d -p 5000:5000 flask-min
```

Visit [http://localhost:5000](http://localhost:5000) to test the app.

---

## Healthcheck Debugging: Ensuring Container Availability

Originally, the container appeared "unhealthy" despite the app functioning correctly.

### The Dockerfile line:

```dockerfile
HEALTHCHECK CMD curl -f http://localhost:5000/ || exit 1
```

### The error encountered:

```bash
/bin/sh: 1: curl: not found
```

This occurred because the base image `python:3.9-slim` does **not** include `curl` by default.

### The resolution:

Add the following line to install `curl`:

```dockerfile
RUN apt update && apt install -y curl
```

With this addition, the healthcheck began to pass and the container reported as **healthy**.

---

## Verifying Health Status

To inspect the container’s health:

```bash
docker inspect <container_id>
```

Look for the following section in the output:

```json
"Health": {
  "Status": "healthy",
  "FailingStreak": 0,
  ...
}
```

If `curl` is missing or misconfigured, the container will appear as `unhealthy`.

---

## Additional Notes

- **Why `curl` over `wget`?**  
  `curl` offers a more straightforward exit code behavior ideal for healthchecks.

- **Why use `0.0.0.0` in Flask?**  
  This makes the app accessible externally from within the container.

---

## Commands Reference

### Build

```bash
docker build -t flask-min .
```

### Run

```bash
docker run -d -p 5000:5000 flask-min
```

### Logs

```bash
docker logs <container_id>
```

### Inspect

```bash
docker inspect <container_id>
```

---

## Cleanup Commands

```bash
docker ps -a                # list containers
docker stop <container_id>  # stop a container
docker rm <container_id>    # remove a container
docker images               # list images
docker rmi flask-min        # remove the image
```

---

## Lessons Learned

- `COPY` can precede `WORKDIR` as Docker resolves absolute paths.
- Always verify whether base images contain necessary tools like `curl`.
- Use `docker exec -it <id> /bin/bash` for root shell access inside a container.
- Prefer `CMD ["python", "main.py"]` over shell-form commands for stability.

---

## Summary

What began as a minimal Flask app evolved into a learning exercise in Docker layering, healthchecks, and container debugging. By incorporating a custom healthcheck and resolving base image limitations, the final result is a more reliable and production-aware container.

Based On [AlexRazor1337's Repo](https://github.com/AlexRazor1337/flask-docker-minimal)
