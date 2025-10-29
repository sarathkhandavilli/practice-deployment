// Prefer explicit env when provided
let resolvedBackendUrl = import.meta.env.VITE_BACKEND_URL;

if (!resolvedBackendUrl) {
  const isProduction = (import.meta?.env?.PROD)
    || (import.meta?.env?.MODE === "production")
    || (import.meta?.env?.VITE_MODE === "production");

  const protocol = typeof window !== "undefined" && window.location?.protocol
    ? window.location.protocol
    : "http:";

  const backendHost = isProduction ? "0.0.0.0" : "localhost";
  const backendPort = import.meta?.env?.VITE_BACKEND_PORT || ""; // e.g. 8000

  const portSegment = backendPort ? `:${backendPort}` : "";
  resolvedBackendUrl = `${protocol}//${backendHost}${portSegment}`;
}

const API_URL = resolvedBackendUrl;
export default API_URL;