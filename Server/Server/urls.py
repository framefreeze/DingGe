"""Server URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/1.9/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  url(r'^$', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  url(r'^$', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.conf.urls import url, include
    2. Add a URL to urlpatterns:  url(r'^blog/', include('blog.urls'))
"""
from django.conf.urls import url
from django.contrib import admin
from DinggeServer import views as DSV
urlpatterns = [
    url(r'^admin/', admin.site.urls),
    url(r'^index',DSV.index),
    url(r'^mark', DSV.mark),
    url(r'^upload',DSV.upload),
    #url(r'^test1',DSV.test),

    url(r'^test1',DSV.test1),
    url(r'^test2',DSV.test2),
    url(r'^test3',DSV.test3),
    url(r'',DSV.index)
#    url(r'upload'),
#    url(r'evaluate'),
#    url(r'pic')
]
