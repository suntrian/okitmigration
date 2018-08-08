<html>
<head>
    <#assign basepath="${request.getContextPath()}">
    <title>第二步</title>
    <script src="${basepath}/js/jquery-3.3.1.min.js"></script>
    <link rel="stylesheet" href="${basepath}/css/my.css">
    <style>
        td {
            padding: 0;
        }
        tr > td {
            width: 150px;
        }
        td + td {
            width: 250px;
        }
        input {
            width: inherit;
        }
    </style>
</head>
<body>
<div class="wrap">
    <div>
        <h2>设置数据库连接参数</h2>
    </div>
    <div id="src" class="fixwidth">
        <table>
            <tr>
                <td>源数据库地址：</td>
                <td><input id="src_url" type="text" placeholder="源数据库连接地址" value="${datasource.src.url!}"></td>
            </tr>
            <tr>
                <td>源数据库用户名：</td>
                <td><input id="src_user" type="text" placeholder="源数据库用户名" value="${datasource.src.username!}"></td>
            </tr>
            <tr>
                <td>源数据库密码： </td>
                <td><input id="src_password" type="text" placeholder="源数据库密码" value="${datasource.src.password!}"></td>
            </tr>
        </table>
        <div class="right">
            <input id="src_check" type="button" onclick="testConnection(0)" value="测试连接并保存参数">
        </div>
    </div>
    <div id="dest" class="fixwidth">
        <table>
            <tr>
                <td>目标数据库地址：</td>
                <td><input id="dest_url" type="text" placeholder="源数据库连接地址" value="${datasource.dest.url!}"></td>
            </tr>
            <tr>
                <td>目标数据库用户名：</td>
                <td><input id="dest_user" type="text" placeholder="源数据库用户名" value="${datasource.dest.username!}"></td>
            </tr>
            <tr>
                <td>目标数据库密码： </td>
                <td><input id="dest_password" type="text" placeholder="源数据库密码" value="${datasource.dest.password!}"></td>
            </tr>
        </table>
        <div class="right">
            <input id="dest_check" type="button" onclick="testConnection(1)" value="测试连接并保存参数">
        </div>
    </div>
    <div class="clear"></div>
    <div class="bottom">
        <div class="right">
            <a href="${basepath}/step3" >下一步</a>
        </div>
    </div>
</div>
<script>
    function testConnection(pos) {
        var source = pos===0?"src":"dest";
        $.ajax({
            url: "${basepath}/datasource/" + source,
            type: "POST",
            data: {
                url: $("#" + source + "_url").val(),
                username: $("#" + source + "_user").val(),
                password: $("#"+ source + "_password").val()
            },
            success: function (result) {
                alert("连接成功");
            },
            error: function (result) {
                alert("连接失败");
            }
        })
    }
</script>
</body>
</html>