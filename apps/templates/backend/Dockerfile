FROM golang:1.21.4-bookworm as builder

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY *.go ./

RUN GOOS=linux GOARCH=amd64 go build -o server

FROM debian:bookworm-slim

RUN set -x && apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    ca-certificates && \
    rm -rf /var/lib/apt/lists/*

EXPOSE 8080

COPY --from=builder /app/server /app/server

RUN chmod +x /app/server

CMD ["/app/server"]