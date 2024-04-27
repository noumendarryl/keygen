# Use an official Ubuntu runtime as a parent image
FROM ubuntu:latest

# Set the working directory to /app
WORKDIR /app

# Install necessary dependencies
RUN apt-get update && \
    apt-get install -y curl git unzip xz-utils zip libglu1-mesa lib32stdc++6 && \
    rm -rf /var/lib/apt/lists/*

# Install Flutter SDK
RUN git clone https://github.com/flutter/flutter.git -b stable --depth 1 && \
        flutter precache

# Add Flutter binary to PATH
ENV PATH="$PATH:/usr/local/flutter/bin"

# Run flutter doctor to download additional components
RUN flutter doctor

# Copy the pubspec.yaml file and get the dependencies
COPY pubspec.yaml .
RUN flutter pub get

# Copy the rest of the app code
COPY . .

# Build the app
RUN flutter build linux --release

# Expose the default Flutter port
# EXPOSE 8080

# Set the entrypoint to run the app
ENTRYPOINT ["./build/linux/release/bundle/keygen"]
