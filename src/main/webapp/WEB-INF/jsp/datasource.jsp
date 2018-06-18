<%--
  Created by IntelliJ IDEA.
  User: Administrator
  Date: 2018/6/12
  Time: 12:40
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>第二步</title>

</head>
<body>
    <div id="app" class="wrap">
        <form method="post" target="_self">
            <el-row :gutter="20">
                <el-col :span="5"><div class="grid-content bg-purple">源数据库连接地址：</div></el-col>
                <el-col :span="7"><div class="grid-content bg-purple"><input type="text" name="src_url" id="src_url" /></div></el-col>
                <el-col :span="5"><div class="grid-content bg-purple">目标数据库连接地址：</div></el-col>
                <el-col :span="7"><div class="grid-content bg-purple"><input type="text" name="dest_url" id="dest_url" /></div></el-col>
            </el-row>
            <el-row :gutter="20">
                <el-col :span="5"><div class="grid-content bg-purple">源数据库：</div></el-col>
                <el-col :span="7"><div class="grid-content bg-purple"><input type="text" name="src_database" id="src_database"></div></el-col>
                <el-col :span="5"><div class="grid-content bg-purple">目标数据库：</div></el-col>
                <el-col :span="7"><div class="grid-content bg-purple"><input type="text" name="dest_database" id="dest_database"></div></el-col>
            </el-row>
            <el-row :gutter="20">
                <el-col :span="5"><div class="grid-content bg-purple">源数据库用户名：</div></el-col>
                <el-col :span="7"><div class="grid-content bg-purple"><input type="text" name="src_username" id="src_username"></div></el-col>
                <el-col :span="5"><div class="grid-content bg-purple">目标数据库用户名：</div></el-col>
                <el-col :span="7"><div class="grid-content bg-purple"><input type="text" name="dest_username" id="dest_username"></div></el-col>
            </el-row>
            <el-row :gutter="20">
                <el-col :span="5"><div class="grid-content bg-purple">源数据库密码：</div></el-col>
                <el-col :span="7"><div class="grid-content bg-purple"><input type="text" name="src_password" id="src_password"></div></el-col>
                <el-col :span="5"><div class="grid-content bg-purple">目标数据库密码：</div></el-col>
                <el-col :span="7"><div class="grid-content bg-purple"><input type="text" name="dest_password" id="dest_password"></div></el-col>
            </el-row>

            <input type="submit" value="下一步">
        </form>

    </div>

</body>
</html>
