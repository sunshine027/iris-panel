#!/bin/bash

# NOTE: You need to install libraries for python-ldap from INSTALL first!

# Installs development dependancies for the IRIS project
# Syncs and migrates databases and generates some test data
# After running this script you should be able to log in with
# AdminUser:password, StaffUser:password and NormalUser:password credentials

if ! which virtualenv; then
    echo "Please install Python virtualenv"
    exit 1
fi

BASEPATH=`dirname "$(readlink -f "$0")"`/..

cd $BASEPATH
virtualenv virtualenv
source virtualenv/bin/activate
pip install -r requirements.txt
python setup.py build
python setup.py install
python iris/manage.py syncdb --noinput
python iris/manage.py migrate

echo "
import os
from datetime import datetime

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'iris.core.settings')

from django.contrib.auth.models import User
from iris.core.models import Submission, SubmissionGroup
from django.contrib.auth.models import User
from iris.core.models import Domain, SubDomain, SubDomainRole, DomainRole, UserProfile

# Create different user types for testing
NORMAL_USER, _ = User.objects.get_or_create(username='NormalUser',
        first_name='Normal', last_name='User', email='normal.user@foo.bar')
NORMAL_USER.set_password('password')
NORMAL_USER.save()

STAFF_USER, _ = User.objects.get_or_create(username='StaffUser',
        first_name='Staff', last_name='User', email='staff.user@foo.bar')
STAFF_USER.is_staff = True
STAFF_USER.set_password('password')
STAFF_USER.save()

ADMIN_USER, _ = User.objects.get_or_create(username='AdminUser',
        first_name='Admin', last_name='User', email='admin.user@foo.bar')
ADMIN_USER.is_superuser = True
ADMIN_USER.is_staff = True
ADMIN_USER.set_password('password')
ADMIN_USER.save()

MAINTAINER, _ = User.objects.get_or_create(username='SecurityMaintainer',
        first_name='Sec', last_name='Mai', email='security.maintainer@foo.bar')
MAINTAINER.is_staff = True
MAINTAINER.set_password('password')
MAINTAINER.save()

# Create some domain specific roles and users
SECURITY, _ = Domain.objects.get_or_create(name='Security')
MAINTAINERS, _ = DomainRole.objects.get_or_create(
    name='Security maintainers', role='MAINTAINER', domain=SECURITY)
MAINTAINERS.user_set.add(MAINTAINER)
MAINTAINERS.user_set.add(ADMIN_USER)

SUBSECURITY, _ = SubDomain.objects.get_or_create(name='Subsecurity', domain=SECURITY)
ARCHITECTS, _ = SubDomainRole.objects.get_or_create(
    name='SubSecurity architects', role='ARCHITECT', subdomain=SUBSECURITY)
ARCHITECTS.user_set.add(ADMIN_USER)

S1, _ = Submission.objects.get_or_create(
        name='Test submission 1',
        commit='12345',
        datetime=datetime.now(),
        status='SUBMITTED',
        comment='This is an automatically generated test submission')

S2, _ = Submission.objects.get_or_create(
        name='Test submission 2',
        commit='12345',
        datetime=datetime.now(),
        status='SUBMITTED',
        comment='This is an automatically generated test submission')

SG1, _ = SubmissionGroup.objects.get_or_create(
        name='Test submission group 1',
        author=STAFF_USER,
        datetime=datetime.now(),
        status='SUBMITTED')

SG1.submissions.add(S1)
SG1.submissions.add(S2)

S3, _ = Submission.objects.get_or_create(
        name='Test submission 3',
        commit='12345',
        datetime=datetime.now(),
        status='SUBMITTED',
        comment='This is an automatically generated test submission')

SG2, _ = SubmissionGroup.objects.get_or_create(
        name='Test submission group 1',
        author=STAFF_USER,
        datetime=datetime.now(),
        status='SUBMITTED')

SG2.submissions.add(S3)"|python

python iris/manage.py runserver
