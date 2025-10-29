# Use lightweight Node image
FROM node:20-alpine

WORKDIR /app

# Copy dependencies and install
COPY package*.json ./
RUN npm install

# Copy all files
COPY . .

# Build-time args for Vite
ARG VITE_MODE=production
ARG VITE_BACKEND_URL
ENV VITE_MODE=$VITE_MODE
ENV VITE_BACKEND_URL=$VITE_BACKEND_URL

# Ensure .env contains VITE_BACKEND_URL before building
RUN sh -lc 'touch .env && grep -q "^VITE_BACKEND_URL=" .env || echo "VITE_BACKEND_URL=${VITE_BACKEND_URL}" >> .env'

# Build
RUN npm run build
# Expose port
EXPOSE 5173

# Serve the built app (production-like)
CMD ["npm", "run", "preview", "--", "--host", "0.0.0.0", "--port", "5173"]
