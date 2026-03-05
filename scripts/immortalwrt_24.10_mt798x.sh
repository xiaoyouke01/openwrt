#!/bin/bash

# 1. 修改默认 IP
sed -i 's/192.168.1.1/192.168.100.252/g' package/base-files/files/bin/config_generate

# 2.移除要替换的包
rm -rf feeds/luci/themes/luci-theme-argon
rm -rf feeds/luci/applications/luci-app-argon-config
rm -rf feeds/luci/applications/luci-app-openclash
rm -rf feeds/luci/applications/luci-app-passwall
rm -rf feeds/packages/lang/golang
rm -rf feeds/packages/net/{xray-core,v2ray-geodata,sing-box,chinadns-ng,dns2socks,hysteria,ipt2socks,microsocks,naiveproxy,shadowsocks-libev,shadowsocks-rust,shadowsocksr-libev,simple-obfs,tcping,trojan-plus,tuic-client,v2ray-plugin,xray-plugin,geoview,shadow-tls}

# 3. 增强版稀疏克隆函数 (参数1是分支名, 参数2是仓库地址, 参数3是子目录，同一个仓库下载多个文件夹直接在后面跟文件名或路径，空格分开)
function git_sparse_clone() {
  branch="$1" repourl="$2" && shift 2
  repodir=$(echo $repourl | awk -F '/' '{print $(NF)}')
  git clone --depth=1 -b $branch --single-branch --filter=blob:none --sparse $repourl
  cd $repodir
  git sparse-checkout set $@
  for sub in $@; do
    # 修复：如果目标已存在，先删除再移动，防止产生 package/xxx/xxx 嵌套
    target="../package/$(basename $sub)"
    [ -d "$target" ] && rm -rf "$target"
    mv -f "$sub" ../package/
  done
  cd .. && rm -rf $repodir
}

# 4. 更新 golang 1.25 版本
git clone --depth=1 -b 25.x https://github.com/sbwml/packages_lang_golang feeds/packages/lang/golang

# 5. 主题与常规插件
git clone --depth=1 -b master https://github.com/jerrykuku/luci-theme-argon package/luci-theme-argon
git clone --depth=1 -b master https://github.com/jerrykuku/luci-app-argon-config package/luci-app-argon-config
git clone --depth=1 -b main https://github.com/gdy666/luci-app-lucky package/lucky
git clone --depth=1 -b main https://github.com/sirpdboy/luci-app-advancedplus package/luci-app-advancedplus

# 6. 定制插件克隆 (iStore 特殊处理)
git_sparse_clone main https://github.com/sirpdboy/luci-app-taskplan luci-app-taskplan
git_sparse_clone main https://github.com/linkease/istore-ui app-store-ui
# 特别注意：iStore 的目录在仓库里叫 luci，移动到 package 后我们给它改个名防止冲突
git_sparse_clone main https://github.com/linkease/istore luci
[ -d package/luci ] && mv package/luci package/luci-app-istore

# 7. Passwall 及其依赖
git clone --depth=1 -b main https://github.com/Openwrt-Passwall/openwrt-passwall-packages package/openwrt-passwall-packages
git_sparse_clone main https://github.com/Openwrt-Passwall/openwrt-passwall luci-app-passwall

# 8. 修复与优化编译环境
# 禁用 Rust 的 LLVM 编译，节省 10GB+ 空间和大量时间
if [ -f feeds/packages/lang/rust/Makefile ]; then
    sed -i 's/ci-llvm=true/ci-llvm=false/g' feeds/packages/lang/rust/Makefile
fi

# 9. 最后的清理：移除重复的依赖索引防止报错
