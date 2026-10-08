FROM rust:slim-bookworm AS builder

WORKDIR /nmsr/

RUN apt-get update -y && apt-get --no-install-recommends install git libssl-dev pkg-config -y

COPY . .

RUN cargo build --release --bin nmsr-aas --features ears --package nmsr-aas

FROM rust:slim-bookworm

RUN apt-get update -y && apt-get --no-install-recommends install mesa-vulkan-drivers -y

WORKDIR /nmsr/

COPY --from=builder /nmsr/target/release/nmsr-aas /nmsr/nmsr-aas

ENV NMSR_USE_SMAA=1
ENV NMSR_SAMPLE_COUNT=1
ENV WGPU_BACKEND=vulkan
ENV RUST_BACKTRACE=1

RUN chmod +x /nmsr/nmsr-aas

EXPOSE 8080

# config.toml is gitignored, mount it: -v ./config.toml:/nmsr/config.toml
CMD /nmsr/nmsr-aas -c config.toml
