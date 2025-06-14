# Use a base image with Ubuntu as the foundation
FROM ubuntu:22.04

# Set environment variables to avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive
ENV ANDROID_HOME=/opt/android-sdk
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:/root/.nvm/versions/node/v20.18.0/bin

# Install dependencies
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    git \
    curl \
    openjdk-17-jdk \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js using NVM
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash \
    && . /root/.nvm/nvm.sh \
    && nvm install 20 \
    && nvm use 20 \
    && npm install -g npm@10.8.2

# Install Android SDK
RUN mkdir -p $ANDROID_HOME/cmdline-tools \
    && wget -q https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O /tmp/cmdline-tools.zip \
    && unzip /tmp/cmdline-tools.zip -d $ANDROID_HOME/cmdline-tools \
    && mv $ANDROID_HOME/cmdline-tools/cmdline-tools $ANDROID_HOME/cmdline-tools/latest \
    && rm /tmp/cmdline-tools.zip \
    && yes | $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager --licenses \
    && $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"

# Set working directory
WORKDIR /app

# Copy project files (will be mounted in CI)
COPY . .

# Install Capacitor CLI globally
RUN npm install -g @capacitor/cli

CMD ["/bin/bash"]