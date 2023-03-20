FROM gcc as builder
WORKDIR /app
COPY hello.c ./
RUN gcc hello.c -o hello

FROM scratch
COPY --from=builder /app/hello /
CMD ["/hello"]
