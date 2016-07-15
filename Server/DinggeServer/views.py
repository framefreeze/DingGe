from django.shortcuts import render
from django.http import HttpResponse
from django import template
from PIL import ImageFile
from PIL import Image
from django.views.decorators.csrf import csrf_exempt
from . import forms as DSF
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
def test(req):
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
            pic.show()
            pic.save('test2.png')
            return render(req, 'mark.html', locals())
        print(2)
    else:
        print(3)
        form = DSF.PicForm()
    return render(req,'test.html',{'form':form})

