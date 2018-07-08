<html>
<head>
    <#assign basepath="${request.getContextPath()}">
    <title>计划任务数据导入</title>
    <script src="${basepath}/js/jquery-3.3.1.min.js"></script>
    <script src="${basepath}/js/jstree.min.js"></script>
    <script src="${basepath}/js/my.js"></script>
    <link rel="stylesheet" href="${basepath}/css/style.css">
    <link rel="stylesheet" href="${basepath}/css/my.css">
</head>
<body>

<div class="wrap">
    <div>
        <h1>计划任务数据导入</h1>
        <h3>使用说明</h3>
        <ul>
            <li></li>
        </ul>
    </div>
    <div>
        <div class="clear title"><span>选择计划任务类型映射关系</span></div>
        <div id="srctasktype" class="fixwidth"></div>
        <div id="desttasktype" class="fixwidth"></div>
    </div>
    <div>
        <div class="clear title"><span>选择计划任务状态映射关系</span></div>
        <div id="srctaskstatus" class="fixwidth"></div>
        <div id="desttaskstatus" class="fixwidth"></div>
    </div>
    <div>
        <div class="clear title"><span>选择计划任务日志类型映射关系</span></div>
        <div id="srctasklogtype" class="fixwidth"></div>
        <div id="desttasklogtype" class="fixwidth"></div>
    </div>
    <div>
        <div class="clear title"><span>选择计划任务验收满意度映射关系</span></div>
        <div id="srctasksatisfaction" class="fixwidth"></div>
        <div id="desttasksatisfaction" class="fixwidth"></div>
    </div>
    <div>
        <div class="clear title"><span>选择计划任务重要度映射关系</span></div>
        <div id="srctaskimportant" class="fixwidth"></div>
        <div id="desttaskimportant" class="fixwidth"></div>
    </div>
    <div>
        <div class="clear title"><span>选择计划任务类别映射关系</span></div>
        <div id="srctaskcategory" class="fixwidth"></div>
        <div id="desttaskcategory" class="fixwidth"></div>
    </div>
    <div class="clear"></div>
    <div class="bottom">
        <div class="right">
            <a id="a" href="javascript:void(0);" onclick="doImport()">开始导入</a>
        </div>
    </div>
</div>

<script>
    $(document).ready(function () {
        achieveData("${basepath}/project/task/taskType/src", $("#srctasktype"), "id", "name");
        achieveData("${basepath}/project/task/taskType/dest", $("#desttasktype"), "id", "name");
        achieveData("${basepath}/project/task/taskStatus/src", $("#srctaskstatus"), "id", "name");
        achieveData("${basepath}/project/task/taskStatus/dest", $("#desttaskstatus"), "id", "name");
        achieveData("${basepath}/project/task/taskImportant/src", $("#srctaskimportant"), "id", "name");
        achieveData("${basepath}/project/task/taskImportant/dest", $("#desttaskimportant"), "id", "name");
        achieveData("${basepath}/project/task/taskLogType/src", $("#srctasklogtype"), "id", "name");
        achieveData("${basepath}/project/task/taskLogType/dest", $("#desttasklogtype"), "id", "name");
        achieveData("${basepath}/project/task/taskSatisfaction/src", $("#srctasksatisfaction"), "id", "name");
        achieveData("${basepath}/project/task/taskSatisfaction/dest", $("#desttasksatisfaction"), "id", "name");
        achieveData("${basepath}/project/task/taskCategory/src", $("#srctaskcategory"), "id", "name");
        achieveData("${basepath}/project/task/taskCategory/dest", $("#desttaskcategory"), "id", "name");

        bindSrcClick($("#srctasktype"), $("#desttasktype"));
        bindSrcClick($("#srctaskstatus"), $("#desttaskstatus"));
        bindSrcClick($("#srctasklogtype"), $("#desttasklogtype"));
        bindSrcClick($("#srctaskimportant"), $("#desttaskimportant"));
        bindSrcClick($("#srctasksatisfaction"), $("#desttasksatisfaction"));
        bindSrcClick($("#srctaskcategory"), $("#desttaskcategory"));

        bindDestClick($("#srctasktype"), $("#desttasktype"), "${basepath}/project/task/taskType");
        bindDestClick($("#srctaskstatus"), $("#desttaskstatus"), "${basepath}/project/task/taskStatus");
        bindDestClick($("#srctasklogtype"), $("#desttasklogtype"), "${basepath}/project/task/taskLogType");
        bindDestClick($("#srctaskimportant"), $("#desttaskimportant"), "${basepath}/project/task/taskImportant");
        bindDestClick($("#srctasksatisfaction"), $("#desttasksatisfaction"), "${basepath}/project/task/taskSatisfaction");
        bindDestClick($("#srctaskcategory"), $("#desttaskcategory"), "${basepath}/project/task/taskCategory");

    });
    function doImport() {
        if ($("#a").html() == "下一步") {
            window.location.href = "${basepath}/next";
            return;
        }
        $.ajax({
            url: "${basepath}/project/task/doimport",
            async: false,
            success: function (result) {
                if (!result.success){
                    alert("计划任务导入失败，失败原因：" + result.data);
                    return;
                }
                alert("计划任务导入成功");
                $("#a").html("下一步");
            },
            error: function (result) {
                alert("计划任务导入失败：" + JSON.stringify(result));
            }
        })
    }
</script>
</body>
</html>