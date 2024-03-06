# Use the official Composer image as a parent image
FROM composer:1.8

# Update/upgrade apk
RUN apk update
RUN apk upgrade

# Make the Terminus directory
RUN mkdir -p /usr/local/share/terminus

# Install Terminus 3.x with Composer
RUN /usr/bin/env COMPOSER_BIN_DIR=/usr/local/bin composer -n --working-dir=/usr/local/share/terminus require pantheon-systems/terminus:"^3"
