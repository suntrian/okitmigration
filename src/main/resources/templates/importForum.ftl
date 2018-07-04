<html>
<head>
    <#assign basepath="${request.getContextPath()}">
    <title>项目论坛数据导入</title>
    <script src="${basepath}/js/jquery-3.3.1.min.js"></script>
    <script src="${basepath}/js/jstree.min.js"></script>
    <script src="${basepath}/js/my.js"></script>
    <link rel="stylesheet" href="${basepath}/css/style.css">
    <link rel="stylesheet" href="${basepath}/css/my.css">

</head>
<body>

<div class="wrap">
    <div>
        <h1>项目论坛数据导入</h1>
        <h3>使用说明</h3>
        <ul>
            <li></li>
        </ul>
    </div>
    <div>
        <div class="clear title"><span>选择问题等级映射关系</span></div>
        <div class="fixwidth" id="srcquestionpriority"></div>
        <div class="fixwidth" id="destquestionpriority"></div>
    </div>
    <div>
        <div class="clear title"><span>选择问题类型映射关系</span></div>
        <div class="fixwidth" id="srcquestiontype"></div>
        <div class="fixwidth" id="destquestiontype"></div>
    </div>
    <div>
        <div class="clear title"><span>选择问题状态映射关系</span></div>
        <div class="fixwidth" id="srcquestionstatus"></div>
        <div class="fixwidth" id="destquestionstatus"></div>
    </div>
    <div class="bottom">
        <div class="right">
            <a id="a" href="javascript:void(0);" onclick="doImport()" >开始导入</a>
        </div>
    </div>
</div>

<script>
    $(document).ready(function () {
        achieveData("${basepath}/project/forum/questionPriority/src", $("#srcquestionpriority"), "id", "name");
        achieveData("${basepath}/project/forum/questionPriority/dest", $("#destquestionpriority"), "id", "name");
        achieveData("${basepath}/project/forum/questionStatus/src", $("#srcquestionstatus"), "id", "name");
        achieveData("${basepath}/project/forum/questionStatus/dest", $("#destquestionstatus"), "id", "name");
        achieveData("${basepath}/project/forum/questionType/src", $("#srcquestiontype"), "id", "name");
        achieveData("${basepath}/project/forum/questionType/dest", $("#destquestiontype"), "id", "name");

        bindSrcClick($("#srcquestionpriority"),     $("#destquestionpriority")  );
        bindSrcClick($("#srcquestionstatus"),       $("#destquestionstatus")    );
        bindSrcClick($("#srcquestiontype"),         $("#destquestiontype")      );

        bindDestClick($("#srcquestionpriority") , $("#destquestionpriority"), "${basepath}/project/forum/questionPriority");
        bindDestClick($("#srcquestionstatus"),    $("#destquestionstatus")  , "${basepath}/project/forum/questionStatus");
        bindDestClick($("#srcquestiontype"),      $("#destquestiontype")    , "${basepath}/project/forum/questionType");
    });
    function doImport() {
        if ($("#a").html() == "下一步") {
            window.location.href = "${basepath}/next";
            return;
        }
        $.ajax({
            url: "${basepath}/project/forum/doimport",
            async: false,
            success: function (result) {
                alert("项目论坛导入成功");
                $("#a").html("下一步");
            }
        })
    }
</script>
</body>
</html>