# hadoopstudy project source

## mapreduce的程序示例
项目下有WordCount的事例程序     WordCount.java     
KPIPV的事例程序  KPIPV.java     

## 本次使用的开发环境是IntelliJ IDEA    
导入maven项目,导入的时候选择pom.xml   
导入之后,配置下Artifacts 在里面选择new一个Jar,把当前的项目打包.   

## 运行jar   
将当前编译好的jar放到服务器上.   
scp -r testhadoopstudy.jar  app-admin@serviceip:~/    (放到服务器上的目录下)     
执行Mapreduce    
hadoop jar ~/testhadoopstudy.jar /input  /output  (input是需要分析的文件目录, output是分析出来之后的文件目录)   






