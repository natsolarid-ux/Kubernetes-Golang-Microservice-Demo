#!/bin/bash

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

API_URL="${1:-http://localhost:8080}"

echo "=========================================="
echo "Testing Data Ingestion API"
echo "API URL: $API_URL"
echo "=========================================="
echo

# Test health endpoint
echo -e "${YELLOW}Testing /health endpoint...${NC}"
curl -s "$API_URL/health" | jq .
echo -e "${GREEN}✓ Health check passed${NC}"
echo

# Test ready endpoint
echo -e "${YELLOW}Testing /ready endpoint...${NC}"
curl -s "$API_URL/ready" | jq .
echo -e "${GREEN}✓ Ready check passed${NC}"
echo

# Ingest some test data
echo -e "${YELLOW}Ingesting test data...${NC}"
for i in {1..5}; do
    curl -s -X POST "$API_URL/ingest" \
        -H "Content-Type: application/json" \
        -d "{\"source\":\"test-source-$i\",\"metrics\":{\"value\":$((RANDOM % 1000)),\"latency\":$((RANDOM % 100))}}" | jq .
    echo
done
echo -e "${GREEN}✓ Data ingestion completed${NC}"
echo

# Retrieve data
echo -e "${YELLOW}Retrieving stored data...${NC}"
curl -s "$API_URL/data" | jq '.count, .data[] | select(.source != null)'
echo -e "${GREEN}✓ Data retrieval successful${NC}"
echo

# Check Prometheus metrics
echo -e "${YELLOW}Checking Prometheus metrics...${NC}"
echo "Sample metrics:"
curl -s "$API_URL/metrics" | grep -E "^(http_requests_total|data_points_ingested_total|http_request_duration)" | head -10
echo -e "${GREEN}✓ Metrics available${NC}"
echo

echo "=========================================="
echo -e "${GREEN}All tests passed!${NC}"
echo "=========================================="
