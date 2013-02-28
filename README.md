git-battlestation
=================

轻便的git伴侣

##安装方法：

1. 安装[node.js](http://nodejs.org/)
2. 通过npm安装git-battlestation：`sudo npm install git-battlestation -g`
3. 关闭占用`tcp 19837` 端口的服务器等
4. 关闭本地的`git-daemon`服务（如果有的话）

##启动方法：

* 临时启动（按`Ctrl + C`退出）：在存放代码仓库的目录的父目录下（如`$ ~/Repositories/`）执行`git battlestation`，然后在浏览器中访问`http://localhost:19837/`便可查看自己的battlestation。

##功能：

### √包含gitweb中的基本功能

同事们可以在web界面中查看你的代码仓库的各种信息。
![demo-gitweb](https://github.com/layerssss/git-battlestation/raw/master/demo-gitweb.png)

### √启动git-daemon

为同事们提供你当前目录下所有代码仓库的只读访问（通过git协议）。
![demo-git-daemon](https://github.com/layerssss/git-battlestation/raw/master/demo-git-daemon.png)

### √查看并比较本地和某一个peer上的分支进展

列出所有其他分支上有的而主分支没有的提交，链接到gitweb上对应的commitdiff，方便地进行代码审核。

![demo-compare](https://github.com/layerssss/git-battlestation/raw/master/demo-compare.png)

### √全局管理peers，并且一键更新到代码仓库的remote

将peers的信息同步到git仓库的remote中，可以方便之后在命令行进行代码合并。
![demo-update-remotes](https://github.com/layerssss/git-battlestation/raw/master/demo-update-remotes.png)
