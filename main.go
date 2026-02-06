package main

import (
"encoding/json"
"log"
"net/http"
"os"
"sync"
"time"

"github.com/prometheus/client_golang/prometheus"
"github.com/prometheus/client_golang/prometheus/promhttp"
)

// Metrics
var (
httpRequestsTotal = prometheus.NewCounterVec(
prometheus.CounterOpts{
Name: "http_requests_total",
Help: "Total number of HTTP requests",
},
[]string{"method", "endpoint", "status"},
)

httpRequestDuration = prometheus.NewHistogramVec(
prometheus.HistogramOpts{
Name:    "http_request_duration_seconds",
Help:    "HTTP request latency",
Buckets: prometheus.DefBuckets,
},
[]string{"method", "endpoint"},
)

dataPointsIngested = prometheus.NewCounter(
prometheus.CounterOpts{
Name: "data_points_ingested_total",
Help: "Total number of data points ingested",
},
)
)

func init() {
prometheus.MustRegister(httpRequestsTotal)
prometheus.MustRegister(httpRequestDuration)
prometheus.MustRegister(dataPointsIngested)
}

// DataPoint represents ingested data
type DataPoint struct {
Timestamp time.Time              `json:"timestamp"`
Source    string                 `json:"source"`
Metrics   map[string]interface{} `json:"metrics"`
}

// In-memory storage (for demo purposes)
type DataStore struct {
mu     sync.RWMutex
points []DataPoint
}

var store = &DataStore{
points: make([]DataPoint, 0),
}

// Health check handler
func healthHandler(w http.ResponseWriter, r *http.Request) {
start := time.Now()

w.Header().Set("Content-Type", "application/json")
w.WriteHeader(http.StatusOK)
json.NewEncoder(w).Encode(map[string]interface{}{
"status":  "healthy",
"version": "1.0.0",
"uptime":  time.Since(startTime).Seconds(),
})

duration := time.Since(start).Seconds()
httpRequestDuration.WithLabelValues(r.Method, "/health").Observe(duration)
httpRequestsTotal.WithLabelValues(r.Method, "/health", "200").Inc()
}

// Ready check handler
func readyHandler(w http.ResponseWriter, r *http.Request) {
w.Header().Set("Content-Type", "application/json")
w.WriteHeader(http.StatusOK)
json.NewEncoder(w).Encode(map[string]string{
"status": "ready",
})

httpRequestsTotal.WithLabelValues(r.Method, "/ready", "200").Inc()
}

// Ingest data handler
func ingestHandler(w http.ResponseWriter, r *http.Request) {
start := time.Now()

if r.Method != http.MethodPost {
http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
httpRequestsTotal.WithLabelValues(r.Method, "/ingest", "405").Inc()
return
}

var dataPoint DataPoint
if err := json.NewDecoder(r.Body).Decode(&dataPoint); err != nil {
http.Error(w, "Invalid JSON", http.StatusBadRequest)
httpRequestsTotal.WithLabelValues(r.Method, "/ingest", "400").Inc()
return
}

// Set timestamp if not provided
if dataPoint.Timestamp.IsZero() {
dataPoint.Timestamp = time.Now()
}

// Store data point
store.mu.Lock()
store.points = append(store.points, dataPoint)
// Keep only last 1000 points for demo
if len(store.points) > 1000 {
store.points = store.points[len(store.points)-1000:]
}
store.mu.Unlock()

dataPointsIngested.Inc()

w.Header().Set("Content-Type", "application/json")
w.WriteHeader(http.StatusCreated)
json.NewEncoder(w).Encode(map[string]interface{}{
"status":    "success",
"timestamp": dataPoint.Timestamp,
"source":    dataPoint.Source,
})

duration := time.Since(start).Seconds()
httpRequestDuration.WithLabelValues(r.Method, "/ingest").Observe(duration)
httpRequestsTotal.WithLabelValues(r.Method, "/ingest", "201").Inc()
}

// Retrieve data handler
func dataHandler(w http.ResponseWriter, r *http.Request) {
start := time.Now()

store.mu.RLock()
points := make([]DataPoint, len(store.points))
copy(points, store.points)
store.mu.RUnlock()

w.Header().Set("Content-Type", "application/json")
json.NewEncoder(w).Encode(map[string]interface{}{
"count": len(points),
"data":  points,
})

duration := time.Since(start).Seconds()
httpRequestDuration.WithLabelValues(r.Method, "/data").Observe(duration)
httpRequestsTotal.WithLabelValues(r.Method, "/data", "200").Inc()
}

var startTime time.Time

func main() {
startTime = time.Now()

port := os.Getenv("PORT")
if port == "" {
port = "8080"
}

// API routes
http.HandleFunc("/health", healthHandler)
http.HandleFunc("/ready", readyHandler)
http.HandleFunc("/ingest", ingestHandler)
http.HandleFunc("/data", dataHandler)

// Prometheus metrics endpoint
http.Handle("/metrics", promhttp.Handler())

log.Printf("Starting server on port %s...", port)
log.Printf("Endpoints available:")
log.Printf("  - GET  /health  - Health check")
log.Printf("  - GET  /ready   - Readiness check")
log.Printf("  - POST /ingest  - Ingest data points")
log.Printf("  - GET  /data    - Retrieve stored data")
log.Printf("  - GET  /metrics - Prometheus metrics")

if err := http.ListenAndServe(":"+port, nil); err != nil {
log.Fatal(err)
}
}
