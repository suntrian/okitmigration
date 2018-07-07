<html>
<head>
    <#assign basepath="${request.getContextPath()}">
    <title>风险管理数据导入</title>
    <script src="${basepath}/js/jquery-3.3.1.min.js"></script>
    <script src="${basepath}/js/jstree.min.js"></script>
    <script src="${basepath}/js/my.js"></script>
    <link rel="stylesheet" href="${basepath}/css/style.css">
    <link rel="stylesheet" href="${basepath}/css/my.css">

</head>
<body>

<div class="wrap">
    <div>
        <h1>风险管理数据导入</h1>
        <h3>使用说明</h3>
        <ul>
            <li></li>
        </ul>
    </div>
    <div>
        <div class="clear title"><span>选择风险属性映射关系</span></div>
        <div class="fixwidth" id="srcriskcolumn"></div>
        <div class="fixwidth" id="destriskcolumn"></div>
    </div>
    <div>
        <div class="clear title"><span>选择风险处置方法映射关系</span></div>
        <div class="fixwidth" id="srcriskdisposemethod"></div>
        <div class="fixwidth" id="destriskdisposemethod"></div>
    </div>
    <div>
        <div class="title clear"><span>选择风险处置状态映射关系</span></div>
        <div class="fixwidth" id="srcriskdisposestatus"></div>
        <div class="fixwidth" id="destriskdisposestatus"></div>
    </div>
    <div>
        <div class="clear title"><span>选择风险类别映射关系</span></div>
        <div class="fixwidth" id="srcriskcategory"></div>
        <div class="fixwidth" id="destriskcategory"></div>
    </div>
    <div>
        <div class="clear title"><span>选择风险状态映射关系</span></div>
        <div class="fixwidth" id="srcriskstatus"></div>
        <div class="fixwidth" id="destriskstatus"></div>
    </div>
    <div class="bottom">
        <div class="right">
            <a id="a" href="javascript:void(0);" onclick="doImport()" >开始导入</a>
        </div>
    </div>
</div>

<script>
    achieveData("${basepath}/project/risk/src", $("#srcriskcolumn"), "column_id", "column_name");
    achieveData("${basepath}/project/risk/dest", $("#destriskcolumn"), "column_id", "column_name");
    achieveData("${basepath}/project/risk/riskCategory/src", $("#srcriskcategory"), "id", "name");
    achieveData("${basepath}/project/risk/riskCategory/dest", $("#destriskcategory"), "id", "name");
    achieveData("${basepath}/project/risk/riskStatus/src", $("#srcriskstatus"), "id", "name");
    achieveData("${basepath}/project/risk/riskStatus/dest", $("#destriskstatus"), "id", "name");
    achieveData("${basepath}/project/risk/riskDisposeStatus/src", $("#srcriskdisposestatus"), "id", "name");
    achieveData("${basepath}/project/risk/riskDisposeStatus/dest", $("#destriskdisposestatus"), "id", "name");
    achieveData("${basepath}/project/risk/riskDisposeMethod/src", $("#srcriskdisposemethod"), "id", "name");
    achieveData("${basepath}/project/risk/riskDisposeMethod/dest", $("#destriskdisposemethod"), "id", "name");

    bindSrcClick($("#srcriskcolumn"), $("#destriskcolumn"));
    bindSrcClick($("#srcriskcategory"), $("#destriskcategory"));
    bindSrcClick($("#srcriskstatus"), $("#destriskstatus"));
    bindSrcClick($("#srcriskdisposemethod"), $("#destriskdisposemethod"));
    bindSrcClick($("#srcriskdisposestatus"), $("#destriskdisposestatus"));

    bindDestClick($("#srcriskcolumn"), $("#destriskcolumn"), "${basepath}/project/risk/riskColumn");
    bindDestClick($("#srcriskcategory"), $("#destriskcategory"), "${basepath}/project/risk/riskCategory");
    bindDestClick($("#srcriskstatus"), $("#destriskstatus"), "${basepath}/project/risk/riskStatus");
    bindDestClick($("#srcriskdisposemethod"), $("#destriskdisposemethod"), "${basepath}/project/risk/riskDisposeStatus");
    bindDestClick($("#srcriskdisposestatus"), $("#destriskdisposestatus"), "${basepath}/project/risk/riskDisposeMethod");

    function doImport() {
        if ($("#a").html() == "下一步") {
            window.location.href = "${basepath}/next";
            return;
        }
        $.ajax({
            url: '${basepath}/project/risk/doimport',
            async: false,
            success: function (resutlt) {
                alert("项目风险导入成功");
                $("#a").html("下一步");
            },
            error: function (result) {
                alert("项目风险导入失败：" + JSON.stringify(result));
            }
        })
    }
    
</script>
</body>
</html>