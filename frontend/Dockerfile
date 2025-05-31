# Stage 1: Build the Node JS application
FROM node:23.11.1-alpine AS builder

WORKDIR /app

# Copy package.json and package-lock.json and install dependencies
COPY package*.json ./

RUN npm install

# Copy the rest of the application code
COPY index.* .
COPY src/ src/
COPY public/ public/
COPY vite.config.mjs .

CMD ["sh"]