# Use a Python 3.8 base image, suitable for QATrack+
FROM python:3.8

# Set environment variables to prevent Python from writing .pyc files and to buffer stdout/stderr
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Install system dependencies required for QATrack+
# build-essential for compiling Python packages (e.g., psycopg2)
# libpq-dev for PostgreSQL client libraries
# postgresql-client for pg_isready and other client tools (NEW)
# git for cloning git-based Python dependencies
# dos2unix for converting script line endings
# chromium for Selenium testing (if needed later)
# cron for cron jobs (if re-enabled later)
RUN apt-get update && apt-get install -y \
    build-essential libpq-dev postgresql-client git dos2unix chromium cron \
    && rm -rf /var/lib/apt/lists/*

# Create a non-privileged user and group (good security practice)
ARG UID=1000
ARG GID=1000
RUN groupadd -g $GID qatrackplus && useradd -u $UID -g $GID -ms /bin/bash qatrackplus

RUN touch /root/.is_inside_docker

# Set the working directory inside the container
WORKDIR /usr/src/qatrackplus

# Copy only the requirements files first to leverage Docker's build cache.
# If only requirements change, this layer rebuilds, otherwise, it uses the cache.
COPY requirements/ /usr/src/qatrackplus/requirements/

# Install all Python dependencies
# This includes base requirements, postgres-specific, and docker-specific (like django-redis)
RUN pip install --no-cache-dir -r requirements/base.txt \
                               -r requirements/postgres.txt \
                               -r requirements/docker.txt

# Copy the rest of the application code into the image.
# Do this *after* installing dependencies, so code changes don't invalidate the pip install layer.
COPY . /usr/src/qatrackplus

# Ensure the initialization script has correct line endings and is executable
RUN dos2unix deploy/docker/init.sh && chmod +x deploy/docker/init.sh

# Change ownership of the static and media directories to the qatrackplus user.
# This is crucial because these directories are mounted as volumes, and their
# permissions might default to root, preventing the non-privileged qatrackplus user from writing to them.
RUN chown -R qatrackplus:qatrackplus /usr/src/qatrackplus/static /usr/src/qatrackplus/media

# Switch to the non-privileged user. All subsequent commands and the application will run as this user.
USER qatrackplus

# Define the command that will run when the container starts.
# This points to our initialization script.
CMD ["/usr/src/qatrackplus/deploy/docker/init.sh"]
