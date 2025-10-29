FROM node:20-alpine

WORKDIR /app

# Copy dependencies and install
COPY package*.json ./
RUN npm install

# Copy all files (including .env for build-time vars)
COPY . .

# Build the app with environment variables available at build time
RUN npm run build

# Expose the default Vite port
EXPOSE 5173

# Start the Vite preview server with host binding (more suitable for production)
CMD ["npm", "run", "preview", "--", "--host", "0.0.0.0", "--port", "5173"]