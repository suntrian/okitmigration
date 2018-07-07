<html>
<head>
    <#assign basepath="${request.getContextPath()}">
    <title>选择导入的内容</title>
    <script src="${basepath}/js/jquery-3.3.1.min.js"></script>
    <script src="${basepath}/js/jstree.min.js"></script>
    <script src="${basepath}/js/my.js"></script>
    <link rel="stylesheet" href="${basepath}/css/style.css">
    <link rel="stylesheet" href="${basepath}/css/my.css">

</head>
<body>
<div class="wrap">
    <div>
        <h1>选择流程对应关系</h1>
        <li>如ID一致可不选</li>
    </div>
    <div>
        <div class="fixwidth" id="srcworkflow"></div>
        <div class="fixwidth" id="destworkflow"></div>
    </div>
    <div class="clear"></div>
    <div class="bottom">
        <div class="right">
            <a href="javascript:void(0);" onclick="next()">下一步</a>
        </div>
    </div>
</div>
<script>
    $(document).ready(function () {
        achieveData("${basepath}/project/workflow/src", $("#srcworkflow"), "uid", "name");
        achieveData("${basepath}/project/workflow/dest", $("#destworkflow"), "uid", "name");

        bindSrcClick($("#srcworkflow"), $("#destworkflow"));
        bindDestClick($("#srcworkflow"), $("#destworkflow"), "${basepath}/project/workflow")
    });
    function next() {
        $.ajax({
            url: '${basepath}/project/workflow/save',
            async: false,
            success: function (result) {
                window.location.href = "${basepath}/next";
            }
        })
    }
</script>
</body>
</html>