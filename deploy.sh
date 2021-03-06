#!/usr/bin/env bash
# author: owen-carter
# what  : init the develop or production env
#       : pull the latest source code,then build them

appName="ng-zorro-admin"
repoUrl="https://github.com/owen-carter/ng-zorro-admin.git"
localRepoPath='~/workspace/'
publishPath="/usr/share/nginx/html/patent/"

function initEnvironment(){
    echo "=======install node========"
    rpm -ivh http://mirrors.ustc.edu.cn/fedora/epel/6/x86_64/epel-release-6-8.noarch.rpm
    sync
    yum install git -y
    curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.2/install.sh | bash
    . ~/.bashrc
    nvm --version
    if [ $? -eq 0 ];then
    echo "install nvm is success"
    fi
    # 安装node7
    nvm install 7
    node -v
    if [ $? -eq 0 ];then
    echo "install node is success"
    fi
    # 永久设置npm源为淘宝源
    npm config set registry http://registry.npm.taobao.org
    npm install -g cnpm --registry=https://registry.npm.taobao.org
    # 更新npm
    cnpm install npm -g
    cnpm install -g @angular/cli
    cnpm install PM2 gulp mocha karma jsmine nightwatch jshint node-gyp webpack less babel express-generator -g
    cd ${localRepoPath}
    git clone ${repoUrl}
    cd ${localRepoPath}
    cnpm install
    npm run test
    deployApp
}

function installNginx(){
    echo "start install nginx..."
    yum -y install nginx
    service nginx start
    curl 127.0.0.1
    cat -n /etc/nginx/conf.d/default.conf
}


function installDependencies(){
    echo ""
}


function deployApp(){
    git pull origin master
    cnpm install
    npm run build
    rm -rf ${publishPath}"**"
    cp  -R -f -v ./dist/* ${publishPath}
    systemctl restart nginx.service
    if [[ $? == 0 ]];
    then
        echo "restart nginx success"
    fi
}


cmdList=( "initEnvironment" "deployApp" "installNginx" "installDependencies" "exit" )
window="whiptail"
window="dialog"
OPTION=$(${window} --title "owen-carter deploy Menu Dialog" --menu "Choose your event" 15 40 12 \
"0" "init the environment" \
"1" "deploy the app again" \
"2" "install Nginx" \
"3" "install Dependencies" \
"4" "exit"  3>&1 1>&2 2>&3)

exitStatus=$?
if [ ${exitStatus} = 0 ]; then
    echo "Your chosen option: #${OPTION} - ${cmdList[OPTION]}"
    ${cmdList[OPTION]}
else
    echo "You chose Cancel."
fi

exit 0