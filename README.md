##Frame freeze

这是一款帮助手机相机与单反使用者提高自己美学素养的评分软件，在照相过程中可以给出当前的评分情况，以便用户在使用这款软件时修正自己的不良构图习惯，拍出符合美学构图的照片。同时现版本已支持自动拍照模式，从此不再错过美的瞬间。
---
#定格 摄影辅助系统 ver2.4.0
-------------

> 关于我们，欢迎关注  
  http://www.framefreeze.cn 或者 dingge@ourmail.cn

摄影爱好者的选择，让我们共建一个优秀的摄影App

__全新单反摄影配件以及摄影爱好者社区已经上线！__

####示例:  
<img src="https://github.com/framefreeze/DingGe/raw/Dev/Document/项目图片4.jpg" height=367px weight=205> 
<img src="https://github.com/framefreeze/DingGe/raw/Dev/Document/项目图片5.jpg" height=367px weight=205>
<img src="https://github.com/framefreeze/DingGe/raw/Dev/Document/项目图片6.jpg" height=367px weight=205>


###特性
- 对于美学的构图评分

- 不断改良的机器学习算法

- 多种摄影方式的配合

###原理说明
内核为ver1.0.4版本及更新的PCE_camera

首先我们将照片的美学质量分为不同特征

利用在线评估网站进行数据获取，对于网上进行评价的广大爱好者的评判进行处理，进行机器学习，生成属于PCE_camera自己的评分算法。调用相机情况下，调用生成的评估算法进行打分。


###使用方法
iOS端：

1.下载手机客户端

2.点击相机图标进入摄影界面

3.选择适合当前状态的拍摄模式

单反插件：

现阶段支持Canon摄影接口（USB 2.0及以上）

1.使用定格配件链接USB接口

2.在手机app或电脑BLE上获取实时相机姿态以及评分建议

### 注意事项
使用相机时要注意区分拍照模式

1.不限制主体对象时请勿接触手机当前画面中的明显主体对象，否则会以限定主体模式进行拍照

2.选择自动拍照模式时，请勿停留时间过长，以免生成过多的冗余照片

3.使用单反时，注意手持姿态，防止插件损坏

###TODO

Ver2.4.0已上线，新增功能如下

1.完善了Apple watch拍照功能，远程控制更简便

2.新增单反套件，Canon使用者可以进行USB连接，实时获取姿态

3.定格——摄影爱好者交流社区已经上线，网址为http://Kevinfeng.name 可以与广大爱好者在线互相评价，共同分享美好时刻

4.相片打印机实时链接正在准备中

