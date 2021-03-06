# -*- coding: utf-8 -*-

# This file is part of IRIS: Infrastructure and Release Information System
#
# Copyright (C) 2013 Intel Corporation
#
# IRIS is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# version 2.0 as published by the Free Software Foundation.

"""
API URL configuration for the iris-packagedb project.

Permittable URLs and views accessible through REST API are defined here.
"""

# pylint: disable=C0103

from django.conf.urls import patterns, url, include

from iris.packagedb.apiviews import (
    DomainViewSet, GitTreeViewSet, PackageViewSet, ProductViewSet)


list_domains = DomainViewSet.as_view({
    'get': 'list'
})
get_domain = DomainViewSet.as_view({
    'get': 'retrieve'
})

list_gittrees = GitTreeViewSet.as_view({
    'get': 'list'
})
get_gittree = GitTreeViewSet.as_view({
    'get': 'retrieve'
})

list_packages = PackageViewSet.as_view({
    'get': 'list'
})
get_package = PackageViewSet.as_view({
    'get': 'retrieve'
})

list_products = ProductViewSet.as_view({
    'get': 'list'
})
get_product = ProductViewSet.as_view({
    'get': 'retrieve'
})

urlpatterns = patterns(
    'iris.packagedb.apiviews',
    url(r'^domains/$', list_domains, name='domains_list'),
    url(r'^domains/(?P<name>[\w&/ ]+)/$', get_domain, name='domain_detail'),
    url(r'^gittrees/$', list_gittrees, name='gittrees_list'),
    url(r'^gittrees/(?P<gitpath>[\w/_-]+)/$',
        get_gittree, name='gittree_detail'),
    url(r'^packages/$', list_packages, name='packages_list'),
    url(r'^packages/(?P<name>[\w.-]+)/$', get_package, name='package_detail'),
    url(r'^products/$', list_products, name='products_list'),
    url(r'^products/(?P<name>[\w:]+)/$', get_product, name='product_detail'),
    url(r'^api-auth/', include('rest_framework.urls',
        namespace='rest_framework')),
)
