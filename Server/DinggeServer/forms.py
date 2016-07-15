from django import forms
from . import models
class PicForm(forms.Form):
    pic = forms.ImageField()
    #pic = models.picture()
    #pic = forms.ImageField()
    #t = forms.CharField(label="b",max_length=100)