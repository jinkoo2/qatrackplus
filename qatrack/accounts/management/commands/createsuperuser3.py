import os
from django.core.management.base import BaseCommand
from django.contrib.auth import get_user_model

# Get the Django User model
User = get_user_model()


class Command(BaseCommand):
    """
    Django management command to create a default superuser
    from environment variables, without requiring a TTY.
    """
    help = 'Creates a superuser, and allows password to be provided non-interactively.'

    def add_arguments(self, parser):
        """
        Adds command line arguments for username, email, and password.
        """
        parser.add_argument('--username', dest='username', default=None, help='Specifies the username for the superuser.')
        parser.add_argument('--email', dest='email', default=None, help='Specifies the email for the superuser.')
        parser.add_argument('--password', dest='password', default=None, help='Specifies the password for the superuser.')

    def handle(self, *args, **options):
        """
        Main logic for the command.
        """
        username = options.get('username')
        email = options.get('email')
        password = options.get('password')

        # Check if environment variables are set.
        if not username:
            username = os.getenv("DJANGO_ADMIN_USERNAME")
        if not email:
            email = os.getenv("DJANGO_ADMIN_EMAIL")
        if not password:
            password = os.getenv("DJANGO_ADMIN_PASSWORD")

        if not all([username, email, password]):
            self.stdout.write(
                self.style.WARNING(
                    'Skipping admin creation: username, email, or password are not specified.'
                )
            )
            return

        # Check if a superuser with the given username already exists.
        if User.objects.filter(username=username).exists():
            self.stdout.write(
                self.style.SUCCESS(
                    f'Superuser "{username}" already exists. Skipping creation.'
                )
            )
            return

        # Create the superuser.
        try:
            self.stdout.write(self.style.SUCCESS(f'Creating superuser "{username}"...'))
            User.objects.create_superuser(
                username=username,
                email=email,
                password=password
            )
            self.stdout.write(self.style.SUCCESS(f'Successfully created superuser "{username}".'))
        except Exception as e:
            self.stdout.write(
                self.style.ERROR(f'Failed to create superuser "{username}": {e}')
            )