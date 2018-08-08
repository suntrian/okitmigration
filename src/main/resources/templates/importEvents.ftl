<html>
<head>
    <#assign basepath="${request.getContextPath()}">
    <title>项目日志数据导入</title>
    <script src="${basepath}/js/jquery-3.3.1.min.js"></script>
    <script src="${basepath}/js/jstree.min.js"></script>
    <script src="${basepath}/js/my.js"></script>
    <link rel="stylesheet" href="${basepath}/css/style.css">
    <link rel="stylesheet" href="${basepath}/css/my.css">
</head>
<body>

<div class="wrap">
    <div>
        <h1>项目日志数据导入</h1>
        <h3>使用说明</h3>
        <ul>
            <li>请选择项目日志标准设置的对应关系</li>
            <li>显示格式为[ID]Name，左侧为源系统的标准，右侧为目标系统的标准</li>
            <li>若两边ID与名称一致，可不选择</li>
        </ul>
    </div>
    <div>
        <div class="title clear"><span>选择日志类型映射关系</span></div>
        <div class="fixwidth" id="srcmemorabiliatype"></div>
        <div class="fixwidth" id="destmemorabiliatype"></div>
    </div>
    <div>
        <div class="title clear"><span>选择日志等级映射关系</span></div>
        <div class="fixwidth" id="srceventslevel"></div>
        <div class="fixwidth" id="desteventslevel"></div>
    </div>
    <div class="bottom">
        <div class="right">
            <a id="a" href="javascript:void(0);" onclick="doImport()">开始导入</a>
        </div>
    </div>
</div>

<script>
    $(document).ready(function () {
        achieveData("${basepath}/project/events/memorabiliaType/src", $("#srcmemorabiliatype"), "id", "name");
        achieveData("${basepath}/project/events/memorabiliaType/dest", $("#destmemorabiliatype"), "id", "name");
        achieveData("${basepath}/project/events/eventsLevel/src", $("#srceventslevel"), "id", "name");
        achieveData("${basepath}/project/events/eventsLevel/dest", $("#desteventslevel"), "id", "name");

        bindSrcClick($("#srcmemorabiliatype"), $("#destmemorabiliatype"));
        bindSrcClick($("#srceventslevel"), $("#desteventslevel"));

        bindDestClick($("#srcmemorabiliatype"), $("#destmemorabiliatype"),  "${basepath}/project/events/memorabiliaType");
        bindDestClick($("#srceventslevel"), $("#desteventslevel"),          "${basepath}/project/events/eventsLevel");
    });
    function doImport() {
        if ($("#a").html() === "下一步") {
            window.location.href = "${basepath}/next";
            return
        }
        $.ajax({
            url: '${basepath}/project/events/doimport',
            async: false, 
            success: function (result) {
                alert("项目日志导入成功");
                $("#a").html("下一步");
            },
            error: function (result) {
                alert("项目日志导入失败：" + JSON.stringify(result));
            }
        })
    }
</script>
</body>
</html>