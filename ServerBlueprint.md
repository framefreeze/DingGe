#定格服务器端项目蓝图
##声明
##概述
本文档是整个项目的蓝图指导者定格服务器端项目的开发，定格服务器端是定格项目的核心，连通着所有的定格相关产品。
###用户简介
所有使用定格相关产品的人都将使用定格服务器端，虽然用户不一定直接访问服务器但是他们使用的产品都会自动连接到服务器端进行操作。
###项目目的及目标
- 目的

    使定格所有产品互相连通，让用户自由快速的定格产品，最终提高用户拍照水平

- 目标

    连通所有产品，并使界面方便快速友好

###术语

- __debian__    一个linux系统
- __nginx__     服务器
- __uWSGI__     也是一个服务器用于将python与nginx连接起来
- __django__    python开发网页应用的框架

##系统概述

###作业流程

整个项目分为三部分，前端、后端与算法模块。
前端用于显示功能直接与用户操作
后端用于前端与算法的互通
用户通过网页与前端沟通或者通过其他产品与我们的后端沟通

##系统环境

系统运行环境为debian

服务器环境为django的框架配以nginx及uwsgi

前端环境为html
##功能需求模块
- 后端
    - 上传图片
    - 发送图片
    - 给出分数（调用算法）
    - 接收评分
    - 控制打印机
- 前端
    - 上传图片
    - 展示图片
    - 给出分数
    - 录入评分