from django.conf.urls import patterns, include, url
from django.contrib import admin
from dingge.views import *
urlpatterns = patterns('',
    # Examples:
    # url(r'^$', 'mysite.views.home', name='home'),
    # url(r'^blog/', include('blog.urls')),

    url(r'^admin/', include(admin.site.urls)),
    url(r'^upload',upload),
    url(r'^marking',marking),
    url(r'^learn',learn),
    url(r'^test.html',testH),
    url(r'^test/',test),
    url(r'^$',index),
)
