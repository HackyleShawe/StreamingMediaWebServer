<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%@ page import="java.io.File" %>
<%@ page import="java.io.FileInputStream" %>
<%@ page import="java.util.Properties" %>

<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Arrays" %>
<%@ page import="java.util.stream.Collectors" %>


<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
    <meta name="robots" content="all">
    <meta name="author" content="Hackyle; Kyle Shawe">
    <meta name="reply-to" content="kyleshawe@outlook.com;1617358182@qq.com">
    <meta name="generator" content="Sublime Text 3; VSCode">
    <meta name="copyright" content="Copy Right: 2022 HACKYLE. All rights reserved">
    <meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
    <title>Home - Streaming Media Web Server</title>
    <style type="text/css">
      /*回到顶部*/
      #backToTopBtn {
        z-index: 99;
        width: 40px;
        background-repeat: no-repeat;
        background-position:center;
        position: fixed;
        bottom: 5%;
        right: 2%;
        cursor: pointer;
        display: block;
        color: red;
        font-size: larger;
      }
    </style>
</head>
<body>

    <%
    String projectPath = request.getSession().getServletContext().getRealPath("");
    String path = projectPath + "/WEB-INF/config.properties";

    //从配置文件中读取媒体文件的所在目录
    FileInputStream is = new FileInputStream(path);
    Properties pro = new Properties();
    pro.load(is);
    String mediaPath = pro.getProperty("media-path");

    File mediaPathFile = new File(mediaPath);
    if(!mediaPathFile.exists()) {
      out.println("<h1 style='background-color: red'> Warning: The Media Path is not Exists! </h1>");
      return;
    }

    //收集所有视频文件：K-文件夹名，V-该文件夹下的所有文件
    HashMap<String, List<String>> mp4FilesMap = new HashMap<>();
    collectFile(mediaPath, mediaPathFile, mp4FilesMap);
    if(mp4FilesMap ==null || mp4FilesMap.size()<1) {
      out.println("<h1 style='background-color: red'>Warning: The Media Path is not Exists Files! </h1>");
      return;
    }

    int mp4FileCount = 0;
    for (List<String> ff : mp4FilesMap.values()) {
        mp4FileCount += ff.size();
    }
 
    //根目录
    application.setAttribute("mediaRoot", mediaPath);
    //视频总数
    application.setAttribute("mp4FileCount", mp4FileCount);
    //将视频文件放入域对象
    application.setAttribute("mp4FilesMap", mp4FilesMap);
    %>

    <%!
    //递归收集路径（mediaPath）下的所有文件存于fileMap中
    public void collectFile(String mediaPath, File file, Map<String, List<String>> fileMap) {
        if(!file.exists()) {
            return;
        }

        //收集文件
        File[] files = file.listFiles(File::isFile);
        if(files != null && files.length > 0) {
            String name = file.getAbsolutePath().replace(File.separator, "/");
            List<String> collect = Arrays.stream(files).map(ff -> ff.getName()).collect(Collectors.toList());
            fileMap.put(name.replace(mediaPath, ""), collect);
        }

        //收集文件夹
        File[] dirs = file.listFiles(File::isDirectory);
        if(dirs == null || dirs.length < 1) {
            return;
        }
        //递归收集文件夹下的子文件、文件夹
        for (File dir : dirs) {
            collectFile(mediaPath, dir, fileMap);
        }
    }
    %>

    <!-- 在本页面，根据关键字进行搜索 -->
    <div>
      <input type="text" placeholder="请输入关键字，不支持分词搜索" size="25" id="searchInput">
      <button type="button" id="searchBtn">搜索</button>

      &emsp;&emsp;<a href="shutdown.jsp"><b>--关机--</b></a>
      <!-- <a href="shutdown.jsp?control=cancel"><b>--取消关机--</b></a> -->
    </div>

    <div>
        Total：${mp4FileCount} 
    </div>

    <%-- Map的遍历 --%>
    <c:forEach items="${mp4FilesMap}" var="entry">
        <h3>${entry.key}</h3>
        <%-- List的遍历 --%>
        <c:forEach items="${entry.value}" var="name" varStatus="varSta">
            <p>No.${varSta.count}
               <a href="delete.jsp?dir=${entry.key}&name=${name}"><b>删除</b></a>
               <a href="rename.jsp?dir=${entry.key}&name=${name}"><b>重命名</b></a>
               <a target="_blank" href="/media${entry.key}/${name}">${name}</a>
            </p>
        </c:forEach>
    </c:forEach>

    <div id="backToTopBtn" title="回到顶部" onclick="topFunction()">TOP</div>

</body>
<script type="text/javascript">
    document.getElementById("searchBtn").onclick = function () {
      console.log(document.getElementById("searchInput"))
      console.log(document.getElementById("searchInput").value)

      toFind(document.getElementById("searchInput").value)
    }
    function toFind(keyword) {
        if(keyword === null || keyword === '' || keyword === undefined) {
            return
        }

        //模拟调用浏览器的Ctrl+F查找功能
        //https://developer.mozilla.org/zh-CN/docs/Web/API/Window/find
        // window.find(aString, aCaseSensitive, aBackwards, aWrapAround,
        //     aWholeWord, aSearchInFrames, aShowDialog);
        // aString：将要搜索的字符串
        // aCaseSensitive：布尔值，如果为true,表示搜索是区分大小写的。
        // aBackwards：布尔值。如果为true, 表示搜索方向为向上搜索。
        // aWrapAround：布尔值。如果为true, 表示为循环搜索。
        window.find(keyword, false, false, true)
    }

    /**
     * 回到顶部
     */
    function topFunction() {
        document.body.scrollTop = 0;
        document.documentElement.scrollTop = 0;
    }
</script>
</html>