# Use the official MongoDB 8.0- image as the base image
FROM mongo:8.0

# Copy an initialization script (optional) to create databases or users
COPY init-mongo.js /docker-entrypoint-initdb.d/

# Expose the default MongoDB port
EXPOSE 27017

# Default command with log path
CMD ["mongod"]