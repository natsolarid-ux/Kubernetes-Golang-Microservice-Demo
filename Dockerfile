# Build stage
FROM golang:1.21-alpine AS builder

WORKDIR /app

# Copy go mod file
COPY go.mod ./

# Download dependencies without checksum validation
ENV GOFLAGS="-mod=mod"
RUN go mod download

# Copy source code
COPY . .

# Build the application
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main .

# Make binary executable
RUN chmod +x main

# Final stage
FROM alpine:latest

RUN apk --no-cache add ca-certificates

WORKDIR /root/

# Copy the binary from builder with executable permissions
COPY --from=builder --chmod=0755 /app/main .

# Expose port
EXPOSE 8080

# Run the application
CMD ["./main"]
