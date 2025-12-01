# PostgreSQL Database Container
FROM postgres:16

# Set environment variables (these will be overridden by docker-compose)
ENV POSTGRES_DB=healthcare
ENV POSTGRES_USER=healthuser
ENV POSTGRES_PASSWORD=healthpass

# Copy initialization scripts
COPY init.sql /docker-entrypoint-initdb.d/

# Expose PostgreSQL port
EXPOSE 5432
