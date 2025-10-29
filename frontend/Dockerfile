# Use a lightweight Node image
FROM node:20-alpine

WORKDIR /app

# Copy dependency files and install
COPY package*.json ./
RUN npm install

# Copy all project files
COPY . .

# ARG to set environment mode (default: production)
ARG VITE_MODE=production
ENV VITE_MODE=$VITE_MODE

# Copy the correct .env file into place based on VITE_MODE
# (This is optional; Vite can also pick up .env files automatically)
RUN if [ -f ".env.$VITE_MODE" ]; then cp .env.$VITE_MODE .env; fi

# Build the app (VITE_MODE is injected, VITE_BACKEND_URL will be picked from env)
RUN npm run build

# Expose the port Vite preview will run on
EXPOSE 5173

# Start the preview server (production-like)
CMD ["npm", "run", "preview", "--", "--host", "0.0.0.0", "--port", "5173"]
