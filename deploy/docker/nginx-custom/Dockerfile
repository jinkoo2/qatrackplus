# Use the official Nginx image as the base
FROM nginx:alpine

# Install envsubst, which is needed to replace variables in the template
RUN apk add --no-cache gettext

# Remove the default Nginx configuration file
RUN rm /etc/nginx/conf.d/default.conf

# Copy the custom template and entrypoint script into the container
COPY nginx.conf.template /etc/nginx/conf.d/default.conf.template
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

# Make the entrypoint script executable
RUN chmod +x /usr/local/bin/entrypoint.sh

# Set the entrypoint to our custom script
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# The default command will run Nginx
CMD ["nginx", "-g", "daemon off;"]