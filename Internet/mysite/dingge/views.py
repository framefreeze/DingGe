from django.shortcuts import render
from django.http import HttpResponse
import os
# Create your views here.
def index(request):
    #return HttpResponse(/root/mysite/learn.html)
    return render(request,'main.html',locals())
def learn(request):
    return render(request,'learn.html',locals())
def upload(request):
    return render(request,'uploadImage.html',locals())
def marking(request):
    return render(request,'marking.html',locals())
def test(request):
    tmp = os.popen('ls')
    t=tmp.read()    
    return HttpResponse(t)
def testH(request):
    return render(request,'test.html',locals())
