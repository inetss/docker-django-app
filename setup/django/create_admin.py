import manage, django, os

if django.VERSION >= (1,7):
	django.setup()

if django.VERSION >= (1,5):
	from django.contrib.auth import get_user_model
	User = get_user_model()
else:
	from django.contrib.auth.models import User

if not User.objects.exists():
	admin = User(is_staff=True, is_superuser=True, **{User.USERNAME_FIELD: os.getenv("DJANGO_ADMIN_USERNAME", "admin")})
	admin.set_password(os.getenv("DJANGO_ADMIN_PASSWORD", "admin"))
	admin.save()
