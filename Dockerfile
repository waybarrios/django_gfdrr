FROM python:2.7.9
MAINTAINER Wayner Barrios<waybarrios@gmail.com>
#Source: https://github.com/GeoNode/django-docker
#Thanks to: @ingenieroAriel
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

# This section is borrowed from the official Django image but adds GDAL and others

RUN apt-get update && apt-get install -y\
            build-essential \
            libxml2-dev libxslt1-dev libjpeg-dev gettext git \
            python-dev python-pip\
            python-pillow python-lxml python-psycopg2 python-django python-bs4 \
            python-multipartposthandler transifex-client python-paver python-nose \
            python-django-nose python-gdal python-django-pagination python-django-jsonfield \
            python-django-extensions python-django-taggit python-httplib2 \
            
    --no-install-recommends && rm -rf /var/lib/apt/lists/*

COPY wait-for-postgres.sh /usr/bin/wait-for-postgres
RUN chmod +x /usr/bin/wait-for-postgres

# python-gdal does not seem to work, let's install manually the version that is 
# compatible with the provided libgdal-dev 
RUN pip install GDAL==1.10 --global-option=build_ext --global-option="-I/usr/include/gdal"

# Copy the requirements first to avoid having to re-do it when the code changes. 
# Requirements in requirements.txt are pinned to specific version 
# usually the output of a pip freeze 

COPY requirements.txt /usr/src/app/
RUN pip install --no-cache-dir -r requirements.txt


# Update the requirements from the local env in case they differ from the pre-built ones.
ONBUILD COPY requirements.txt /usr/src/app/
ONBUILD RUN pip install --no-cache-dir -r requirements.txt

ONBUILD COPY . /usr/src/app/
ONBUILD RUN pip install --no-deps --no-cache-dir -e /usr/src/app/

EXPOSE 8000
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
