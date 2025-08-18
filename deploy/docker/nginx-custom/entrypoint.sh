#!/bin/sh
set -e

# Replace environment variables in the Nginx template file
# The variables to substitute are now explicitly listed in a more robust way.
# The $$ is required to make envsubst treat the string as a variable
# and not just a literal value.
envsubst '$SERVER_NAME $INTERNAL_SERVER_NAME $INTERNAL_SERVER_PORT' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf

# Execute the main Nginx command
exec "$@"