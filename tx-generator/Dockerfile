FROM golang:1.24-alpine3.20 AS builder

WORKDIR /build

COPY go.mod .
RUN go mod download
COPY . .
RUN go build -o app main.go

FROM alpine:3.20
COPY --from=builder /build/app /build/app
ENTRYPOINT ["/build/app"]