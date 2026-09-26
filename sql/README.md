项目使用 MySQL8.0  
csv导入时需提前上传至mysql部署的服务器  
CSV 导入：  
容器启动参数需要将宿主机目录绑定到：  
/var/lib/mysql-files/（也可部署到其他位置，在sql文件中更改相应位置即可）  
例如：/root/olist_data:/var/lib/mysql-files  
文件必须位于 MySQL 容器内的 /var/lib/mysql-files/ 目录。  
