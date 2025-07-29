# Start from a more recent Python version. Python 3.6 is End-of-Life and outdated.
# Python 3.8 is a better minimum, or even 3.9/3.10 if QATrack+ supports it.
# Let's use 3.8 as discussed for better compatibility with newer packages.
FROM python:3.8

RUN echo 'deb http://apt-archive.postgresql.org/pub/repos/apt/ stretch-pgdg main' > /etc/apt/sources.list.d/pgdg.list
# Or use the more dynamic one you commented out for non-stretch versions if needed:
# RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ $(grep -oP 'VERSION_CODENAME=\K\w+' /etc/os-release)-pgdg main' > /etc/apt/sources.list.d/pgdg.list
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN apt-get update && apt-get install -y \
    cron postgresql-client-10 cifs-utils dos2unix chromium \
    && rm -rf /var/lib/apt/lists/*

# Create a non-privileged user and group (good security practice)
ARG UID=1000
ARG GID=1000
RUN groupadd -g $GID qatrackplus && useradd -u $UID -g qatrackplus -ms /bin/bash qatrackplus

RUN touch /root/.is_inside_docker

# Set the working directory for the application
WORKDIR /usr/src/qatrackplus

# --- CRITICAL CHANGES BELOW ---

# Copy *only* the requirements files first to leverage Docker's build cache.
# If only requirements change, this layer rebuilds, otherwise, it uses the cache.
COPY requirements/ /usr/src/qatrackplus/requirements/

# Install all Python dependencies into the container's environment.
# This ensures Django, psycopg2, gunicorn, and black are installed during the image build.
# You might need to adjust the black version in your requirements file first if 23.1.0 is truly unavailable.
RUN pip install --no-cache-dir -r requirements/base.txt \
                               -r requirements/postgres.txt \
                               -r requirements/docker.txt

# Copy the rest of the application code into the image.
# Do this *after* installing dependencies, so code changes don't invalidate the pip install layer.
COPY . /usr/src/qatrackplus

# Ensure the entrypoint script (init.sh) is executable and has correct line endings
RUN dos2unix deploy/docker/init.sh && chmod +x deploy/docker/init.sh

# Switch to the non-privileged user. All subsequent commands and the application will run as this user.
USER qatrackplus

# Define the command that will run when the container starts.
# This replaces the 'command:' entry in your docker-compose.yml for this service.
CMD ["/usr/src/qatrackplus/deploy/docker/init.sh"]