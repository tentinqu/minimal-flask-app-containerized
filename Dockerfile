FROM python:3.9-slim
WORKDIR /app
COPY main.py .
RUN pip install Flask
RUN apt-get update && apt-get install -y curl
EXPOSE 5000
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
  CMD curl -f http://localhost:5000/ || exit 1
CMD ["python", "main.py"]
