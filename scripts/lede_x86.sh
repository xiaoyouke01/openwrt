# File name: x86.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#
# Modify default IP
sed -i 's/192.168.1.1/192.168.100.252/g' package/base-files/files/bin/config_generate
#
########### 设置密码为空（可选） ###########
sed -i 's@.*CYXluq4wUazHjmCDBCqXF*@#&@g' package/lean/default-settings/files/zzz-default-settings

##### 移除要替换的包
# 删除老argon
rm -rf feeds/luci/themes/luci-theme-argon
rm -rf feeds/luci/applications/luci-app-argon-config
# 删除英文版netdata
rm -rf feeds/luci/applications/luci-app-netdata
# 删除低版本golang
#rm -rf feeds/packages/lang/golang
# 删除低版本mosdns
rm -rf feeds/packages/net/v2ray-geodata
rm -rf feeds/packages/utils/v2dat
rm -rf feeds/packages/net/mosdns
rm -rf feeds/luci/applications/luci-app-mosdns
# 删除低版本smartdns
#rm -rf feeds/packages/net/smartdns

###### Git稀疏克隆
# 参数1是分支名, 参数2是仓库地址, 参数3是子目录，同一个仓库下载多个文件夹直接在后面跟文件名或路径，空格分开
function git_sparse_clone() {
  branch="$1" repourl="$2" && shift 2
  git clone --depth=1 -b $branch --single-branch --filter=blob:none --sparse $repourl
  repodir=$(echo $repourl | awk -F '/' '{print $(NF)}')
  cd $repodir && git sparse-checkout set $@
  mv -f $@ ../package
  cd .. && rm -rf $repodir
}

###### 添加新版本golang
#git clone --depth=1 -b 22.x https://github.com/sbwml/packages_lang_golang feeds/packages/lang/golang

###### Themes
# 拉取argon主题
git clone --depth=1 -b 18.06 https://github.com/jerrykuku/luci-theme-argon package/luci-theme-argon
git clone --depth=1 -b 18.06 https://github.com/jerrykuku/luci-app-argon-config package/luci-app-argon-config
#git clone --depth=1 -b master https://github.com/jerrykuku/luci-theme-argon package/luci-theme-argon
#git clone --depth=1 -b master https://github.com/jerrykuku/luci-app-argon-config package/luci-app-argon-config
# 拉取酷猫主题
#git clone --depth=1 -b main https://github.com/sirpdboy/luci-theme-kucat package/luci-theme-kucat

###### 添加额外插件
# 拉取中文版netdata
git clone --depth=1 -b master https://github.com/sirpdboy/luci-app-netdata package/luci-app-netdata
# 添加Lucky
git clone --depth=1 https://github.com/sirpdboy/luci-app-lucky.git package/lucky
# 添加系统高级设置加强版
git clone --depth=1 -b main https://github.com/sirpdboy/luci-app-advancedplus package/luci-app-advancedplus
# 拉取定时设置
git clone --depth=1 https://github.com/sirpdboy/luci-app-autotimeset package/luci-app-autotimeset
# eqosplus定时限速
git clone --depth=1 https://github.com/sirpdboy/luci-app-eqosplus package/luci-app-eqosplus
# 家长控制
git clone --depth=1 -b main https://github.com/sirpdboy/luci-app-parentcontrol package/luci-app-parentcontrol
# 添加ddns-go
git clone --depth=1 https://github.com/sirpdboy/luci-app-ddns-go package/ddns-go
# 设备关机功能
git clone --depth=1 https://github.com/sirpdboy/luci-app-poweroffdevice package/luci-app-poweroffdevice
# 添加MosDNS
git clone --depth=1 -b v5 https://github.com/sbwml/luci-app-mosdns package/mosdns
git clone --depth=1 https://github.com/sbwml/v2ray-geodata package/v2ray-geodata
# 添加SmartDNS
#git clone --depth=1 -b lede https://github.com/pymumu/luci-app-smartdns package/luci-app-smartdns
#git clone --depth=1 https://github.com/pymumu/openwrt-smartdns package/smartdns
# 添加adguardhome,bypass，管控过滤,访问限制，文件管理助手等
git_sparse_clone main https://github.com/kenzok8/small-package luci-app-adguardhome luci-app-bypass luci-app-fileassistant luci-app-filebrowser luci-app-timecontrol luci-app-control-timewol luci-app-control-weburl luci-app-control-webrestriction
# 添加lua-maxminddb
git_sparse_clone master https://github.com/kenzok8/openwrt-packages lua-maxminddb
# 添加istore
git_sparse_clone main https://github.com/linkease/istore-ui app-store-ui
git_sparse_clone main https://github.com/linkease/istore luci
# 添加应用管理
#git clone --depth=1 -b master https://github.com/destan19/OpenAppFilter package/OpenAppFilter
# 添加vssr
#git clone --depth=1 https://github.com/free-diy/luci-app-vssr package/luci-app-vssr

##### 科学上网插件
git clone --depth=1 -b master https://github.com/fw876/helloworld package/luci-app-ssr-plus
git clone --depth=1 -b main https://github.com/xiaorouji/openwrt-passwall-packages package/openwrt-passwall
git clone --depth=1 -b main https://github.com/xiaorouji/openwrt-passwall package/luci-app-passwall
git clone --depth=1 -b main https://github.com/xiaorouji/openwrt-passwall2 package/luci-app-passwall2
git_sparse_clone master https://github.com/vernesong/OpenClash luci-app-openclash
