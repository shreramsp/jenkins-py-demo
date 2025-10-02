# tiny runtime image
FROM python:3.13-alpine
WORKDIR /app
COPY . .
# no extra deps; stdlib only
EXPOSE 8000
CMD ["python", "-m", "http.server", "8000"]
