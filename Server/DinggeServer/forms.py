from django import forms
from django.forms import Form
from django.forms import ModelForm
from . import models
class PicForm(forms.Form):
    pic = forms.ImageField()
    #pic = models.picture()
    #pic = forms.ImageField()
    #t = forms.CharField(label="b",max_length=100)

class testSql(forms.Form):
    model = models.testSQl

class testPicInfo(ModelForm):
    class Meta:
        model = models.testSQl
        #fields = ['ImgH','ImgW']
        fields = '__all__'
