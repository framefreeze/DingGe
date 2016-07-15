from django.db import models
from PIL import Image
# Create your models here.

class picture(models.Model):
    pic = models.ImageField(upload_to='/static/')