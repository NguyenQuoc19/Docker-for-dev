# Stage 1: Build the Node JS application
FROM node:23.11.1-alpine AS builder

WORKDIR /app

# Copy package.json and package-lock.json and install dependencies
COPY app/package*.json ./

RUN npm install

# Copy the rest of the application code
COPY app/index.* .
COPY app/src/ src/
COPY app/public/ public/
COPY app/vite.config.js .

CMD ["sh"]