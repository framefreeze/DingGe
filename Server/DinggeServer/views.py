import random
from django.shortcuts import render
from django.http import HttpResponse
from django import template
#from PIL import ImageFile
from PIL import Image
from django.views.decorators.csrf import csrf_exempt
from . import forms as DSF
from . import models as DSM
from django.db import connection
#from DinggeServer.forms import testPicInfo
# Create your views here.
def index(req):
    return render(req,'index.html',locals())
def mark(req):
    if req.method == 'POST':
        form = DSF
    cursor = connection.cursor()
    cursor.execute('select count(*) from DinggeServer_picinfo;')
    row = cursor.fetchone()
    p = row[0]
    rndId = random.randint(1,p)

    return render(req,'mark.html',{'markPic':"pic/"+str(rndId)+".jpg"})

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
            emps = DSM.PicInfo.objects.all()
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
            #pic.show()
            #print(pic.getpixel())
            x = pic.size[0]
            y = pic.size[1]
            #(x,y)=pic.
            hw = DSM.PicInfo.objects.create(ImgH=y,ImgW=x)

            # getpixel()
            #print(x)
            #print(y)
            #pic.save()
            emps = DSM.PicInfo.objects.values('id','ImgH','ImgW')
            cursor = connection.cursor()
            cursor.execute('select count(*) from DinggeServer_picinfo;')
            row = cursor.fetchone()
            p = row[0]
            print(row)
            print(p)
            #imgName = str(p)+".png"
            imgName = "DinggeServer/static/pic/"+str(p)+".jpg"
            pic.save(imgName)#这个代码已经实现了 还差一个路径 由于static/pic已经有文件了 所以没再更改 正式上线的时候就好了
            #p = DSM.testSQl.objects.raw('select count(id) from DinggeServer_testsql;')
            #print(p)
            return render(req,'testSQL.html',{'emps':emps})
    else:
        form=DSF.PicForm(req.POST,req.FILES)
    return render(req,'upload.html',{'form':form})
