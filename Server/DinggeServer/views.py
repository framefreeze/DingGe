from django.shortcuts import render
from django.http import HttpResponse
from django import template
#from PIL import ImageFile
from PIL import Image
from django.views.decorators.csrf import csrf_exempt
from . import forms as DSF
from . import models as DSM
#from DinggeServer.forms import testPicInfo
# Create your views here.
def index(req):
    return render(req,'index.html',locals())
def mark(req):
    return render(req,'mark.html',locals())

def upload(req):
    if(req.method == 'POST'):
        return render(req, 'mark.html', locals())
    else:
        form = DSF.PicForm()
        #form = form.label_suffix
    return render(req,'upload.html',{'form':form})

def testz(req):
    #c={}
    #c.update()
    print(1)
    #reqfile = req.FILES["b"]
    #reqfile = req.FILES["b"]
    print(2)
    #if(reqfile ==None):
       # print("file is NONE")
    #img = Image.Image(reqfile)
    print(3)
   # if(img == None):
     #   print("it's NONE")
    #img.show()
    print(4)
    #img.save('test.png')
    return render(req,'mark.html',locals())

def test1(req):
    """
     if req.method == 'POST':
        form = DSF.PicForm()
        print(1)

        picFile = req.FILES["pic"]
        print(picFile == None)
        img = Image.Image(picFile)
        img.show()
        img.save('test1.png')
        return render(req, 'mark.html', locals())
    return render(req,'test.html',{'form':form})
        #form = DSF.PicForm(req.POST)
        #if form.is_valid():
            #return render(req, 'test.html', {'form': form})
            #return render(req,'mark.html',locals())
    #else:
        #form = DSF.PicForm()
    #return render(req,'test.html',{'form':form})
    """
    if req.method == 'POST':
        form = DSF.PicForm(req.POST,req.FILES)
        if form.is_valid():
            print(1)
            pic = Image.open(req.FILES["pic"])
            #pic.show()
            pic.save('test2.png')
            return render(req, 'mark.html', locals())
        print(2)
    else:
        print(3)
        form = DSF.PicForm()
    return render(req,'test.html',{'form':form})

def test2(req):
    if req.method == 'POST':
        form = DSF.testPicInfo(req.POST)
        print(1)
        #print(form.Meta.model.objects.all())

        if form.is_valid():
            print(2)
            form.save()
            #examInfo = form.save()
            #examInfo.save()
            print("saved")
            emps = DSM.testSQl.objects.all()
            return render(req,'testSQL.html',{'emps':emps})
    else:
        form = DSF.testPicInfo()
        #return render(req,'mark.html',locals())
    return render(req,'upload.html',{'form':form})
def test3(req):
    if req.method == 'POST':
        form = DSF.PicForm(req.POST,req.FILES)
        if form.is_valid():
            pic = Image.open(req.FILES["pic"])
            pic.show()
            formInfo = DSM.testSQl
            formInfo.save()
            #pic.save()