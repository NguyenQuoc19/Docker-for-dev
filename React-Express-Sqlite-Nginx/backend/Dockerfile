# Stage 1: Build the Node JS application
FROM node:23.11.1-alpine AS build

# Install SQLite
RUN apk add --no-cache sqlite

WORKDIR /app

# Copy package.json and package-lock.json and install dependencies
COPY app/package*.json ./
RUN npm install

# Copy the rest of the application code
COPY app/ .

# Build the application
# RUN npm run start

# Stage 2: Run the application
FROM node:23.11.1-alpine

WORKDIR /app

# Copy only the necessary files from the build stage
COPY --from=build /app/node_modules/ ./node_modules/
COPY --from=build /app .

# ENV NODE_ENV=$NODE_ENV
# ENV PORT=$PORT

# Expose the application port
EXPOSE $PORT

# Default command to run the application
CMD ["npm", "run", "start"]