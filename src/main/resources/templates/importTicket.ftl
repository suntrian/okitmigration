<html>
<head>
    <#assign basepath="${request.getContextPath()}">
    <title>缺陷数据导入</title>
    <script src="${basepath}/js/jquery-3.3.1.min.js"></script>
    <script src="${basepath}/js/jstree.min.js"></script>
    <script src="${basepath}/js/my.js"></script>
    <link rel="stylesheet" href="${basepath}/css/style.css">
    <link rel="stylesheet" href="${basepath}/css/my.css">
</head>
<body>
    <div class="wrap">
        <div>
            <h1>缺陷数据导入</h1>
            <h2>使用说明</h2>
        </div>
        <div id="column">
            <div class="clear title"><span>选择缺陷列映射关系</span></div>
            <div id="column_src" class="fixwidth"></div>
            <div id="column_dest" class="fixwidth"></div>
        </div>
        <div class="clear"></div>
        <div id="type">
            <div class="clear title ">选择类型映射关系</div>
            <div id="type_src" class="fixwidth"></div>
            <div id="type_dest" class="fixwidth"></div>
        </div>
        <div class="clear"></div>
        <div id="status">
            <div class="clear title">选择缺陷状态映射关系</div>
            <div id="status_src" class="fixwidth"></div>
            <div id="status_dest" class="fixwidth"></div>
        </div>
        <div class="clear"></div>
        <div id="category">
            <div class="clear title">选择缺陷类别映射关系</div>
            <div id="category_src" class="fixwidth"></div>
            <div id="category_dest" class="fixwidth"></div>
        </div>
        <div class="clear"></div>
        <div id="source">
            <div class="clear title ">选择缺陷来源映射关系</div>
            <div id="source_src" class="fixwidth"></div>
            <div id="source_dest" class="fixwidth"></div>
        </div>
        <div class="clear"></div>
        <div id="frequency">
            <div class="clear title ">选择缺陷出现频率映射关系</div>
            <div id="frequency_src" class="fixwidth"></div>
            <div id="frequency_dest" class="fixwidth"></div>
        </div>
        <div class="clear"></div>
        <div id="priority">
            <div class="clear title ">选择缺陷优先级映射关系</div>
            <div id="priority_src" class="fixwidth"></div>
            <div id="priority_dest" class="fixwidth"></div>
        </div>
        <div class="clear"></div>
        <div id="resolution">
            <div class="clear title">选择缺陷解决方式映射关系</div>
            <div id="resolution_src" class="fixwidth"></div>
            <div id="resolution_dest" class="fixwidth"></div>
        </div>
        <div class="clear"></div>
        <div id="severity">
            <div class="clear title ">选择缺陷严重程度映射关系 </div>
            <div id="severity_src" class="fixwidth"></div>
            <div id="severity_dest" class="fixwidth"></div>
        </div>
        <div class="clear"></div>
        <div class="bottom">
            <div class="right">
                <a id="a" onclick="doImport()" href="#" id="next">开始导入</a>
            </div>
        </div>
    </div>



<script>
    $(document).ready(function () {
        achieveData("${basepath}/project/ticket/column/src", $("#column_src"), "column_id", "column_name");
        achieveData("${basepath}/project/ticket/column/dest", $("#column_dest"), "column_id", "column_name");
        achieveData("${basepath}/project/ticket/type/src", $("#type_src"), "id", "name");
        achieveData("${basepath}/project/ticket/type/dest", $("#type_dest"), "id", "name");
        achieveData("${basepath}/project/ticket/status/src", $("#status_src"), "id", "name");
        achieveData("${basepath}/project/ticket/status/dest", $("#status_dest"), "id", "name");
        achieveData("${basepath}/project/ticket/resolution/src", $("#resolution_src"), "id", "name");
        achieveData("${basepath}/project/ticket/resolution/dest", $("#resolution_dest"), "id", "name");
        achieveData("${basepath}/project/ticket/priority/src", $("#priority_src"), "id", "name");
        achieveData("${basepath}/project/ticket/priority/dest", $("#priority_dest"), "id", "name");
        achieveData("${basepath}/project/ticket/frequency/src", $("#frequency_src"), "id", "name");
        achieveData("${basepath}/project/ticket/frequency/dest", $("#frequency_dest"), "id", "name");
        achieveData("${basepath}/project/ticket/source/src", $("#source_src"), "id", "name");
        achieveData("${basepath}/project/ticket/source/dest", $("#source_dest"), "id", "name");
        achieveData("${basepath}/project/ticket/severity/src", $("#severity_src"), "id", "name");
        achieveData("${basepath}/project/ticket/severity/dest", $("#severity_dest"), "id", "name");
        achieveData("${basepath}/project/ticket/category/src", $("#category_src"), "id", "name");
        achieveData("${basepath}/project/ticket/category/dest", $("#category_dest"), "id", "name");

        bindSrcClick($("#column_src"), $("#column_dest"));
        bindSrcClick($("#type_src"), $("#type_dest"));
        bindSrcClick($("#status_src"), $("#status_dest"));
        bindSrcClick($("#resolution_src"), $("#resolution_dest"));
        bindSrcClick($("#priority_src"), $("#priority_dest"));
        bindSrcClick($("#frequency_src"), $("#frequency_dest"));
        bindSrcClick($("#source_src"), $("#source_dest"));
        bindSrcClick($("#severity_src"), $("#severity_dest"));
        bindSrcClick($("#category_src"), $("#category_dest"));

        bindDestClick($("#column_src"), $("#column_dest"), "${basepath}/project/ticket/column");
        bindDestClick($("#type_src"), $("#type_dest") , "${basepath}/project/ticket/type");
        bindDestClick($("#status_src"), $("#status_dest"), "${basepath}/project/ticket/status");
        bindDestClick($("#resolution_src"), $("#resolution_dest"), "${basepath}/project/ticket/resolution");
        bindDestClick($("#priority_src"), $("#priority_dest"), "${basepath}/project/ticket/priority");
        bindDestClick($("#frequency_src"), $("#frequency_dest"), "/project/ticket/frequency");
        bindDestClick($("#source_src"), $("#source_dest"), "${basepath}/project/ticket/source");
        bindDestClick($("#severity_src"), $("#severity_dest"), "${basepath}/project/ticket/severity");
        bindDestClick($("#category_src"), $("#category_dest"), "${basepath}/project/ticket/category");
    });

    function doImport() {
        if ($("#a").html() == "下一步") {
            window.location.href = "${basepath}/next";
            return;
        }
        $.ajax({
            url: "${basepath}/project/ticket/doimport",
            async: false,
            success: function (result) {
                alert("缺陷导入成功");
                $("#a").html("下一步");
            },
            error: function (result) {
                alert("缺陷导入失败:" + JSON.stringify(result));
            }
        })
    }
</script>
</body>
</html>