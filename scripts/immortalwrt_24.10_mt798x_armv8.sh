#!/bin/bash

# 1. 修改默认 IP
sed -i '/lan)/s/192\.168\.[0-9.]*/10.31.2.251/' package/base-files/files/bin/config_generate

# 2.移除要替换的包
rm -rf feeds/luci/themes/luci-theme-argon
rm -rf feeds/luci/applications/luci-app-argon-config
rm -rf feeds/luci/applications/luci-app-openclash
rm -rf feeds/luci/applications/luci-app-passwall
rm -rf feeds/packages/lang/golang
rm -rf feeds/packages/net/{xray-core,v2ray-geodata,sing-box,chinadns-ng,dns2socks,hysteria,ipt2socks,microsocks,naiveproxy,shadowsocks-libev,shadowsocks-rust,shadowsocksr-libev,simple-obfs,tcping,trojan-plus,tuic-client,v2ray-plugin,xray-plugin,geoview,shadow-tls}
#rm -rf feeds/luci/applications/luci-app-netdata

# 3. 增强版稀疏克隆函数 (参数1是分支名, 参数2是仓库地址, 参数3是子目录，同一个仓库下载多个文件夹直接在后面跟文件名或路径，空格分开)
function git_sparse_clone() {
  branch="$1" repourl="$2" && shift 2
  repodir=$(echo $repourl | awk -F '/' '{print $(NF)}')
  git clone --depth=1 -b $branch --single-branch --filter=blob:none --sparse $repourl
  cd $repodir
  git sparse-checkout set $@
  for sub in $@; do
    target="../package/$(basename $sub)"
    [ -d "$target" ] && rm -rf "$target"
    mv -f "$sub" ../package/
  done
  cd .. && rm -rf $repodir
}

# 4. 更新 golang 1.25 版本
git clone --depth=1 -b 25.x https://github.com/sbwml/packages_lang_golang feeds/packages/lang/golang

# 5. 主题与常规插件
# 添加argon主题
git clone --depth=1 -b master https://github.com/jerrykuku/luci-theme-argon package/luci-theme-argon
git clone --depth=1 -b master https://github.com/jerrykuku/luci-app-argon-config package/luci-app-argon-config
# 添加Lucky
git clone --depth=1 -b main https://github.com/gdy666/luci-app-lucky package/lucky
# 添加系统高级设置
git clone --depth=1 -b main https://github.com/sirpdboy/luci-app-advancedplus package/luci-app-advancedplus
# 添加nikki
#git clone --depth=1 -b main https://github.com/nikkinikki-org/OpenWrt-nikki package/OpenWrt-nikki
# 添加Passwall 及其依赖
git clone --depth=1 -b main https://github.com/Openwrt-Passwall/openwrt-passwall-packages package/passwall-packages
git clone --depth=1 -b main https://github.com/Openwrt-Passwall/openwrt-passwall package/luci-app-passwall
#git_sparse_clone main https://github.com/Openwrt-Passwall/openwrt-passwall2 package/luci-app-passwall2
# 添加ssrplus
#git clone --depth=1 -b master https://github.com/fw876/helloworld package/luci-app-ssr-plus
# 添加中文版netdata
#git clone --depth=1 -b master https://github.com/sirpdboy/luci-app-netdata package/luci-app-netdata
# 添加应用管理
#git clone --depth=1 -b master https://github.com/destan19/OpenAppFilter package/OpenAppFilter
# 添加momo
#git clone --depth=1 -b main https://github.com/nikkinikki-org/OpenWrt-momo package/OpenWrt-momo

# 6. 定制插件克隆 (iStore 特殊处理)
# 添加openclash
#git_sparse_clone master https://github.com/vernesong/OpenClash luci-app-openclash
# 添加taskplan定时设置插件
git_sparse_clone main https://github.com/sirpdboy/luci-app-taskplan luci-app-taskplan
# 添加设备关机功能
#git_sparse_clone master https://github.com/sirpdboy/luci-app-poweroffdevice luci-app-poweroffdevice
# 添加istore
git_sparse_clone main https://github.com/linkease/istore-ui app-store-ui
git_sparse_clone main https://github.com/linkease/istore luci
# 特别注意：iStore 的目录在仓库里叫 luci，移动到 package 后我们给它改个名防止冲突
[ -d package/luci ] && mv package/luci package/luci-app-istore

# 7. 修复与优化编译环境
# 禁用 Rust 的 LLVM 编译，节省 10GB+ 空间和大量时间
#if [ -f feeds/packages/lang/rust/Makefile ]; then
#    sed -i 's/ci-llvm=true/ci-llvm=false/g' feeds/packages/lang/rust/Makefile
#fi

# 9. 其他
