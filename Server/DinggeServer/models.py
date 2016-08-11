from django.db import models
#from PIL import Image
from django.contrib import admin
# Create your models here.

#class picture(models.Model):
    #pic = models.ImageField(upload_to='/static/')

class PicInfo(models.Model):
    ImgH = models.IntegerField()
    ImgW = models.IntegerField()
    id = models.AutoField(primary_key=True)

class markData(models.Model):
    picId = models.ForeignKey('PicInfo',to_field="id")
    mainStX = models.IntegerField()
    mainStY = models.IntegerField()
    mainEdX = models.IntegerField()
    mainEdY = models.IntegerField()
    Score = models.IntegerField()
    markId = models.AutoField(primary_key=True)
