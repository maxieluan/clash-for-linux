## 做的修改

1. 把update config从start.sh中分离出来，放到update.sh中。
2. 微调调整一些脚本。
3. 删除了restart.sh，因为..个人用不到
4. 考虑到网络不好的情况，可以用其他渠道下载clash.yaml，拷贝进temp文件夹，用manual_update_config.sh更新
5. yacd ui里没有修改mode的api，增加脚本change_mode.sh以修改mode
6. by default，使用mixed_port 7890
7. 这fork主要是为了在wsl2中使用，start.sh会输出wsl2在宿主机中的ip

## 使用方法
1. git clone repository
2. 添加`.env`，修改密码和clash url
3. run `update_config.sh` 或拷贝clash.yaml进temp文件夹，run `manual_update_config.sh`
4. run `start.sh`，按照提示操作
5. 可以使用`change_mode.sh`查看当前mode或修改mode

## sample env
```bash
# Clash 订阅地址
export CLASH_URL=''
export SECRET=''
```

## untrack file.
一些数据不应该被同步在git上，所以在新clone的repo中，需要run `untrack.sh`. 