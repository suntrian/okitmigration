<html>
<head>
    <#assign basepath="${request.getContextPath()}">
    <title>测试管理数据导入</title>
    <script src="${basepath}/js/jquery-3.3.1.min.js"></script>
    <script src="${basepath}/js/jstree.min.js"></script>
    <script src="${basepath}/js/my.js"></script>
    <link rel="stylesheet" href="${basepath}/css/style.css">
    <link rel="stylesheet" href="${basepath}/css/my.css">
</head>
<body>

    <div class="wrap">
        <div>
            <h1>测试管理数据导入</h1>
            <h3>使用说明</h3>
            <ul>
                <li></li>
            </ul>
        </div>
        <div>
            <div class="clear title"><span>选择测试活动级别映射关系</span></div>
            <div id="srctestactivitylevel" class="fixwidth"></div>
            <div id="desttestactivitylevel" class="fixwidth"></div>
        </div>
        <div>
            <div class="clear title"><span>选择测试活动状态映射关系</span></div>
            <div id="srctestactivitystatus" class="fixwidth"></div>
            <div id="desttestactivitystatus" class="fixwidth"></div>
        </div>
        <div>
            <div class="clear title"><span>选择测试阶段状态映射关系</span></div>
            <div id="srcteststagecategory" class="fixwidth"></div>
            <div id="destteststagecategory" class="fixwidth"></div>
        </div>
        <div>
            <div class="clear title"><span>选择测试类型映射关系</span></div>
            <div id="srctesttype" class="fixwidth"> </div>
            <div id="desttesttype" class="fixwidth"></div>
        </div>
        <div >
            <div class="clear title"><span>选择测试优先级映射关系</span></div>
            <div id="srctestcasepriority" class="fixwidth"></div>
            <div id="desttestcasepriority" class="fixwidth"></div>
        </div>
        <div>
            <div class="clear title"><span>选择测试状态映射关系</span></div>
            <div id="srctestcasestatus" class="fixwidth"></div>
            <div id="desttestcasestatus" class="fixwidth"></div>
        </div>
        <div>
            <div class="clear title"><span>选择测试方法映射关系</span></div>
            <div id="srctestmethod" class="fixwidth"></div>
            <div id="desttestmethod" class="fixwidth"></div>
        </div>
        <div>
            <div class="clear title"><span>选择映射关系</span></div>
            <div id="srctestrule" class="fixwidth"></div>
            <div id="desttestrule" class="fixwidth"></div>
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
        achieveData("${basepath}/project/test/testActivityLevel/src", $("#srctestactivitylevel"), "id", "name");
        achieveData("${basepath}/project/test/testActivityLevel/dest", $("#desttestactivitylevel"), "id", "name");
        achieveData("${basepath}/project/test/testActivityStatus/src", $("#srctestactivitystatus"), "id", "name");
        achieveData("${basepath}/project/test/testActivityStatus/dest", $("#desttestactivitystatus"), "id", "name");
        achieveData("${basepath}/project/test/testStageCategory/src", $("#srcteststagecategory"), "id", "name");
        achieveData("${basepath}/project/test/testStageCategory/dest", $("#destteststagecategory"), "id", "name");
        achieveData("${basepath}/project/test/testType/src", $("#srctesttype"), "id", "name");
        achieveData("${basepath}/project/test/testType/dest", $("#desttesttype"), "id", "name");
        achieveData("${basepath}/project/test/testCaseStatus/src", $("#srctestcasestatus"), "id", "name");
        achieveData("${basepath}/project/test/testCaseStatus/dest", $("#desttestcasestatus"), "id", "name");
        achieveData("${basepath}/project/test/testCasePriority/src", $("#srctestcasepriority"), "id", "name");
        achieveData("${basepath}/project/test/testCasePriority/dest", $("#desttestcasepriority"), "id", "name");
        achieveData("${basepath}/project/test/testRule/src", $("#srctestrule"), "id", "name");
        achieveData("${basepath}/project/test/testRule/dest", $("#desttestrule"), "id", "name");
        achieveData("${basepath}/project/test/testMethod/src", $("#srctestmethod"), "id", "name");
        achieveData("${basepath}/project/test/testMethod/dest", $("#desttestmethod"), "id", "name");


        bindSrcClick($("#srctestactivitylevel"), $("#desttestactivitylevel"));
        bindSrcClick($("#srctestactivitystatus"), $("#desttestactivitystatus"));
        bindSrcClick($("#srcteststagecategory"), $("#destteststagecategory"));
        bindSrcClick($("#srctesttype"), $("#desttesttype"));
        bindSrcClick($("#srctestmethod"), $("#desttestmethod"));
        bindSrcClick($("#srctestrule"), $("#desttestrule"));
        bindSrcClick($("#srctestcasestatus"), $("#desttestcasestatus"));
        bindSrcClick($("#srctestcasepriority"), $("#desttestcasepriority"));

        bindDestClick($("#srctestactivitylevel"), $("#desttestactivitylevel"), "${basepath}/project/test/testActivityLevel");
        bindDestClick($("#srctestactivitystatus"), $("#desttestactivitystatus"), "${basepath}/project/test/testActivityStatus");
        bindDestClick($("#srcteststagecategory"), $("#destteststagecategory"), "${basepath}/project/test/testStageCategory");
        bindDestClick($("#srctesttype"), $("#desttesttype"), "${basepath}/project/test/testType");
        bindDestClick($("#srctestmethod"), $("#desttestmethod"), "${basepath}/project/test/testMethod");
        bindDestClick($("#srctestrule"), $("#desttestrule"), "${basepath}/project/test/testRule");
        bindDestClick($("#srctestcasestatus"), $("#desttestcasestatus"), "${basepath}/project/test/testCaseStatus");
        bindDestClick($("#srctestcasepriority"), $("#desttestcasepriority"), "${basepath}/project/test/testCasePriority");

    });
    function doImport() {
        if ($("#a").html() == "下一步") {
            window.location.href = "${basepath}/next";
            return;
        }
        $.ajax({
            url: "${basepath}/project/test/doimport",
            async: false,
            success: function (result) {
                alert("测试数据导入成功");
                $("#a").html("下一步");
            },
            error: function (result) {
                alert("测试数据导入失败" + JSON.stringify(result));
            }
        })
    }

</script>
</body>
</html>