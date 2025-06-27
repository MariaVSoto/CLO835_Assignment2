# Stage 1: Use an official Node.js image as a builder
FROM node:18-alpine AS builder

# Set the working directory inside the container
WORKDIR /usr/src/app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install only the production dependencies
RUN npm install --only=production

# ---

# Stage 2: Create the final, smaller production image
FROM node:18-alpine

# Set the working directory
WORKDIR /usr/src/app

# Copy the installed dependencies from the 'builder' stage
COPY --from=builder /usr/src/app/node_modules ./node_modules

# Copy the application source code
COPY index.js .

# Expose the port the app runs on
EXPOSE 8080

# The command to run when the container starts
CMD [ "node", "index.js" ]