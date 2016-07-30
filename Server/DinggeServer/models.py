from django.db import models
#from PIL import Image
from django.contrib import admin
# Create your models here.

#class picture(models.Model):
    #pic = models.ImageField(upload_to='/static/')

class testSQl(models.Model):
    ImgH = models.IntegerField()
    ImgW = models.IntegerField()
    id = models.AutoField(primary_key=True)
