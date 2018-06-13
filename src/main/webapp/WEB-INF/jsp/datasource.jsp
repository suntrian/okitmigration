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
    <link rel="stylesheet" href="https://unpkg.com/element-ui/lib/theme-chalk/index.css">
    <script src="//unpkg.com/vue/dist/vue.js"></script>
    <script src="https://unpkg.com/element-ui/lib/index.js"></script>
    <title>第二步</title>
    <style>
        @import url("//unpkg.com/element-ui@2.4.1/lib/theme-chalk/index.css");
        .el-row {
            margin-bottom: 20px;
        &:last-child {
             margin-bottom: 0;
         }
        }
        .el-col {
            border-radius: 4px;
        }
        .bg-purple-dark {
            background: #99a9bf;
        }
        .bg-purple {
            background: #d3dce6;
        }
        .bg-purple-light {
            background: #e5e9f2;
        }
        .grid-content {
            border-radius: 4px;
            min-height: 36px;
        }
        .row-bg {
            padding: 10px 0;
            background-color: #f9fafc;
        }

        .wrap {
            width: 768px;
            margin: 0 auto;
        }
    </style>
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

        <div style="height: 300px;">
            <el-steps direction="vertical" :active="1">
                <el-step title="步骤 1"></el-step>
                <el-step title="步骤 2"></el-step>
                <el-step title="步骤 3" description="这是一段很长很长很长的描述性文字"></el-step>
            </el-steps>
        </div>
        <el-button style="margin-top: 12px;" @click="next">下一步</el-button>
    </div>


    <script>
        new Vue().$mount('#app');
        data = function () {
            return {
                active: 0
            };
        };
        next = function () {
            if (this.active++ > 2) this.active = 0;
        }
    </script>
</body>
</html>
