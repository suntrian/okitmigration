<html>
<head>
    <#assign basepath="${request.getContextPath()}">
    <title>问题管理数据导入</title>
    <script src="${basepath}/js/jquery-3.3.1.min.js"></script>
    <script src="${basepath}/js/jstree.min.js"></script>
    <script src="${basepath}/js/my.js"></script>
    <link rel="stylesheet" href="${basepath}/css/style.css">
    <link rel="stylesheet" href="${basepath}/css/my.css">
</head>
<body>
<div class="wrap">
    <div>
        <h1>问题管理数据导入</h1>
        <h3>使用说明</h3>
        <ul>
            <li>请选择项目问题标准设置的对应关系</li>
            <li>显示格式为[ID]Name，左侧为源系统的标准，右侧为目标系统的标准</li>
            <li>若两边ID与名称一致，可不选择</li>
        </ul>
    </div>
    <div>
        <div class="clear title"><span>选择问题扩展字段映射关系</span></div>
        <div class="fixwidth" id="srcquestioncolumn"></div>
        <div class="fixwidth" id="destquestioncolumn"></div>
    </div>
     <div>
         <div class="clear title"><span>选择问题类别映射关系</span></div>
         <div class="fixwidth" id="srcquestioncategory"></div>
         <div class="fixwidth" id="destquestioncategory"></div>
     </div>
    <div>
        <div class="title clear"><span>选择问题状态映射关系</span></div>
        <div class="fixwidth" id="srcquestionmanagestatus"></div>
        <div class="fixwidth" id="destquestionmanagestatus"></div>
    </div>
    <div>
        <div class="clear title"><span>选择问题评价等级映射关系</span></div>
        <div class="fixwidth" id="srcquestionevaluationlevel"></div>
        <div class="fixwidth" id="destquestionevaluationlevel"></div>
    </div>
    <div class="bottom">
        <div class="right">
            <a id="a" href="javascript:void(0);" onclick="doImport()">开始导入</a>
        </div>
    </div>
</div>

<script>
    $(document).ready(function () {
        achieveData("${basepath}/project/question/src", $("#srcquestioncolumn"), "column_id", "column_name");
        achieveData("${basepath}/project/question/dest", $("#destquestioncolumn"), "column_id", "column_name");
        achieveData("${basepath}/project/question/questionCategory/src", $("#srcquestioncategory"), "id", "name");
        achieveData("${basepath}/project/question/questionCategory/dest", $("#destquestioncategory"), "id", "name");
        achieveData("${basepath}/project/question/questionManageStatus/src", $("#srcquestionmanagestatus"), "id", "name");
        achieveData("${basepath}/project/question/questionManageStatus/dest", $("#destquestionmanagestatus"), "id", "name");
        achieveData("${basepath}/project/question/questionEvaluationLevel/src", $("#srcquestionevaluationlevel"), "id", "name");
        achieveData("${basepath}/project/question/questionEvaluationLevel/dest", $("#destquestionevaluationlevel"), "id", "name");

        bindSrcClick($("#srcquestioncolumn"), $("#destquestioncolumn"));
        bindSrcClick($("#srcquestioncategory"), $("#destquestioncategory"));
        bindSrcClick($("#srcquestionmanagestatus"), $("#destquestionmanagestatus"));
        bindSrcClick($("#srcquestionevaluationlevel"), $("#destquestionevaluationlevel"));

        bindDestClick($("#srcquestioncolumn"), $("#destquestioncolumn"), "${basepath}/project/question/questionColumn");
        bindDestClick($("#srcquestioncategory"), $("#destquestioncategory"), "${basepath}/project/question/questionCateogry");
        bindDestClick($("#srcquestionmanagestatus"), $("#destquestionmanagestatus"), "${basepath}/project/question/questionManageStatus");
        bindDestClick($("#srcquestionevaluationlevel"), $("#destquestionevaluationlevel"), "${basepath}/project/question/questionEvaluationLevel");

    });
    function doImport() {
        if ($("#a").html() == "下一步") {
            window.location.href = "${basepath}/next";
            return;
        }
        $.ajax({
            url: "${basepath}/project/question/doimport",
            async: false,
            success: function (result) {
                alert("项目问题导入成功");
                $("#a").html("下一步");
            },
            error: function (result) {
                alert("项目问题导入失败:" + JSON.stringify(result));
            }
        })
    }
</script>
</body>
</html>