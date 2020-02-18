# systemdによる起動
rootユーザでは，サーバの起動時にnomnichiが起動する．
非ルートユーザでは，下記のsystemdの設定を行ったユーザでログインした際にnomnichiが起動する．
以上から，rootユーザで設定するのが好ましい．

## 設定
+ 以下のコマンドを実行し適切な場所にファイルを配置する．
  + rootユーザ
    ```
    $ sudo cp systemd_conf/root/nomnichi.service /etc/systemd/system/nomnichi.service
    $ sudo cp systemd_conf/root/nomnichi_env /etc/default/nomnichi_env
    ```
  + 非rootユーザ
    ```
    $ cp systemd_conf/user/nomnichi.service ~/.config/systemd/user/nomnichi.service
    $ cp systemd_conf/user/nomnichi_env ~/.config/systemd/user/nomnichi_env
    ```
   
+ コピーした`nomnichi.service`について，以下の項目を環境に合わせて設定する．
  ```
  10 WorkingDirectory=/home/nomlab/nomnichi
  11 ExecStart=/bin/sh -c 'exec /home/nomlab/nomnichi/exe/nomnichi >> /var/log/nomnichi.log 2>&1'
  12 User=nomlab
  13 Group=nomlab
  ```

+ コピーした`nomnichi_env`について，PATHを環境に合わせて設定する．

## 実行
+ 以下のコマンドを実行することでnomnichiを起動できる．
  + rootユーザ
    ```
    $ sudo systemctl start nomnichi
    ```
  + 非rootユーザ
    ```
    $ systemctl --user start nomnichi
    ```
    
+ 以下のコマンドを実行することでnomnichiを停止できる．
  + rootユーザ
    ```
    $ sudo systemctl stop nomnichi
    ```
    
  + 非rootユーザ
    ```
    $ systemctl --user stop nomnichi
    ```
