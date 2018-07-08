<html>
<head>
    <#assign basepath="${request.getContextPath()}">
    <title>使用说明</title>
    <script src="${basepath}/js/jquery-3.3.1.min.js"></script>
    <link rel="stylesheet" href="${basepath}/css/my.css">
</head>
<body>
    <div class="wrap">
        <div class="clear"></div>
        <div>
            <h1>
                使用说明
            </h1>
            <div>
                <ol>
                    <li>本工具用于实施oKit系统数据迁移，迁移工作包括三部分</li>
                    <ul>
                        <li>svn配置库迁移</li>
                        <li>文件迁移</li>
                        <li>数据库数据迁移</li>
                    </ul>
                    <li>实施数据库迁移前，需先完成svn配置库的迁移和文件的迁移</li>
                    <li>svn配置库迁移方法： 将源系统安装目录下svn/data目录下的所有文件夹及文件拷贝到迁移的目标系统相应目录下，目标目录下不得存在同名目录</li>
                    <li>文件迁移方法： 将源系统上传目录upload目录下的所有文件夹及文件拷贝到目标系统相应目录下，若目标目录下存在同名目录则合并</li>
                    <li>数据库数据迁移，请点击<a href="${basepath}/step3">下一步</a></li>
                    <li>若本次数据迁移为全新环境的迁移或需要重新迁移数据，请勾选<input id="clear" type="checkbox"  />清除缓存</li>
                </ol>
            </div>
            <div>
                <ul>
                    <li>
                        因系统管理实体较多，实体之间关联关系较为复杂，且包含扩展字段，可配置标准表等原因，有可能因两边系统存在配置不同等原因导致迁移失败，当失败时需手动分析解决。
                        某一实体导入失败一般不会影响其他实体的导入。
                    </li>
                </ul>
            </div>

        </div>
        <div class="clear"></div>
        <div class="next">
            <a  href="javascript:void(0);" onclick="next()">下一步</a>
        </div>
    </div>
<script>
    function next() {
        if ($("#clear")[0].checked == true) {
            $.ajax({
                url: "${basepath}/project/clear",
                success: function (result) {
                    window.location.href = "${basepath}/step2";
                }
            })
        } else {
            window.location.href = "${basepath}/step2";
        }

    }
</script>
</body>
</html>