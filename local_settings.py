SECRET_KEY = 'MY_UNSAFE_DEFAULT'
TIME_ZONE = 'Europe/Paris'
## FS
CONTENT_DIR = '/usr/share/graphite-web/webapp/content'
GRAPHITE_ROOT = '/usr/share/graphite-web'
STORAGE_DIR = '/var/lib/graphite-web'
WHISPER_DIR = '/var/lib/carbon/whisper'

CARBONLINK_HOSTS = ["carbon:7002","carbon:7012"]

DATABASES = {
    'default': {
        'NAME': '/var/lib/graphite-web/graphite.db',
        'ENGINE': 'django.db.backends.sqlite3',
        'USER': '',
        'PASSWORD': '',
        'HOST': '',
        'PORT': ''
    }
}
