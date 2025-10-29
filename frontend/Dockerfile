# Use lightweight Node image
FROM node:20-alpine

WORKDIR /app

# Copy dependencies and install
COPY package*.json ./
RUN npm install

# Copy all files
COPY . .

# Build arguments and environment
ARG VITE_BACKEND_URL
ENV VITE_BACKEND_URL=$VITE_BACKEND_URL

# Inject backend URL dynamically
RUN echo "VITE_BACKEND_URL=${VITE_BACKEND_URL}" > .env && npm run build

# Expose port
EXPOSE 5173

# Serve the built app (production-like)
CMD ["npm", "run", "preview", "--", "--host", "0.0.0.0", "--port", "5173"]
