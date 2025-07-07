# Use an ARM64 base image
FROM arm64v8/ubuntu:20.04

# Install required dependencies
RUN apt-get update && apt-get install -y \
  curl wget unzip git libgl1-mesa-dev libvirt-daemon-system \
  libvirt-clients bridge-utils qemu-kvm \
  openjdk-17-jdk \
  x11vnc xvfb fluxbox \
  && rm -rf /var/lib/apt/lists/*

# Install Android SDK Command Line Tools
RUN mkdir -p /opt/android-sdk/cmdline-tools && \
  cd /opt/android-sdk/cmdline-tools && \
  curl -o tools.zip https://dl.google.com/android/repository/commandlinetools-linux-10406996_latest.zip && \
  unzip tools.zip && \
  mv cmdline-tools latest && \
  rm tools.zip

# Set environment variables for Android SDK
ENV ANDROID_HOME /opt/android-sdk
ENV PATH ${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/platform-tools:$PATH

# Accept SDK licenses and install required SDK components
RUN mkdir -p ~/.android && touch ~/.android/repositories.cfg && \
  yes | sdkmanager --licenses && \
  sdkmanager --update && \
  sdkmanager "platform-tools" "emulator" "platforms;android-30" "system-images;android-30;google_apis;arm64-v8a"

# Create AVD (Android Virtual Device) for ARM-based system image
RUN echo "no" | avdmanager create avd --name arm-avd --package "system-images;android-30;google_apis;arm64-v8a" --device "pixel" --force

# Expose VNC port for remote access
EXPOSE 6080

# Set up VNC server to display the emulator
CMD ["bash", "-c", "emulator -avd arm-avd -no-audio -no-boot-anim -gpu off & \
x11vnc -forever -usepw -create"]
