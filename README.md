# bash
个人收集整理的脚本，通过主菜单调用，方便快速部署

```
curl -sL https://bash.15099.net | bash
```

## 部署

```
docker run -d --name bash -p 90:80 lihaixin/bash
```

## 应用场景

1. 更换系统（linux换其他版本、灌爱快系统、一键物理机安装armbian）
2. Linux初始化（升级、repo、时区、时间、主机名等）
3. Docker环境初始化（版本、代理、日志等设置）
4. Portainer中文图像界面安装（agent安装、edge安装）
5. bench压力测试

## 后续操作

通过脚本运行后，后续操作都是在Portainer界面上操作

