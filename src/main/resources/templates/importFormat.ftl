<html>
<head>
    <#assign basepath="${request.getContextPath()}">
    <title>需求管理数据导入</title>
    <script src="${basepath}/js/jquery-3.3.1.min.js"></script>
    <script src="${basepath}/js/jstree.min.js"></script>
    <script src="${basepath}/js/my.js"></script>
    <link rel="stylesheet" href="${basepath}/css/style.css">
    <link rel="stylesheet" href="${basepath}/css/my.css">

</head>
<body>

<div class="wrap">
    <div>
        <h1>需求管理数据导入</h1>
        <h3>使用说明</h3>
        <ul>
            <li></li>
        </ul>
    </div>
    <div>
        <div class="title clear"><span>选择需求属性映射关系</span></div>
        <div id="srcformatcolumn" class="fixwidth"></div>
        <div id="destformatcolumn" class="fixwidth"></div>
    </div>
    <div>
        <div class="title clear"><span>选择需求文档类型映射关系</span></div>
        <div id="srcformatdoctype" class="fixwidth"></div>
        <div id="destformatdoctype" class="fixwidth"></div>
    </div>
    <div>
        <div class="title clear"><span>选择需求条目类型映射关系</span></div>
        <div id="srcformatitemtype" class="fixwidth"></div>
        <div id="destformatitemtype" class="fixwidth"></div>
    </div>
    <div>
        <div class="title clear"><span>选择需求状态映射关系</span></div>
        <div id="srcformatitemstatus" class="fixwidth"></div>
        <div id="destformatitemstatus" class="fixwidth"></div>
    </div>
    <div>
        <div class="title clear"><span>选择需求困难程度映射关系</span></div>
        <div id="srcformatdifficulty" class="fixwidth"></div>
        <div id="destformatdifficulty" class="fixwidth"></div>
    </div>
    <div>
        <div class="title clear"><span>选择需求稳定度映射关系</span></div>
        <div id="srcformatstability" class="fixwidth"></div>
        <div id="destformatstability" class="fixwidth"></div>
    </div>
    <div>
        <div class="title clear"><span>选择需求权限映射关系</span></div>
        <div id="srcformatprivileges" class="fixwidth"></div>
        <div id="destformatprivileges" class="fixwidth"></div>
    </div>
    <div>
        <div class="title clear"><span>选择需求期望等级映射关系</span></div>
        <div id="srcformatexpectedlevel" class="fixwidth"></div>
        <div id="destformatexpectedlevel" class="fixwidth"></div>
    </div>
    <div>
        <div class="title clear"><span>选择需求变更类型映射关系</span></div>
        <div id="srcformatitemchange" class="fixwidth"></div>
        <div id="destformatitemchange" class="fixwidth"></div>
    </div>
    <div>
        <div class="title clear"><span>选择需求变更状态映射关系</span></div>
        <div id="srcformatalteredstatus" class="fixwidth"></div>
        <div id="destformatalteredstatus" class="fixwidth"></div>
    </div>
    <div>
        <div class="title clear"><span>选择需求映射关系</span></div>
        <div id="srcformatchangedmanner" class="fixwidth"></div>
        <div id="destformatchangedmanner" class="fixwidth"></div>
    </div>
    <div class="bottom">
        <div class="right">
            <a id="a" href="javascript:void(0);" onclick="doImport()">开始导入</a>
        </div>
    </div>
</div>

<script>
    achieveData("${basepath}/project/format/src", $("#srcformatcolumn"), "column_id", "column_name");
    achieveData("${basepath}/project/format/dest", $("#destformatcolumn"), "column_id", "column_name");
    achieveData("${basepath}/project/format/formatDocType/src", $("#srcformatdoctype"), "id", "name");
    achieveData("${basepath}/project/format/formatDocType/dest", $("#destformatdoctype"), "id", "name");
    achieveData("${basepath}/project/format/formatItemType/src", $("#srcformatitemtype"), "id", "name");
    achieveData("${basepath}/project/format/formatItemType/dest", $("#destformatitemtype"), "id", "name");
    achieveData("${basepath}/project/format/formatItemStatus/src", $("#srcformatitemstatus"), "id", "name");
    achieveData("${basepath}/project/format/formatItemStatus/dest", $("#destformatitemstatus"), "id", "name");
    achieveData("${basepath}/project/format/formatItemChange/src", $("#srcformatitemchange"), "id", "name");
    achieveData("${basepath}/project/format/formatItemChange/dest", $("#destformatitemchange"), "id", "name");
    achieveData("${basepath}/project/format/formatDifficulty/src", $("#srcformatdifficulty"), "id", "NAME");
    achieveData("${basepath}/project/format/formatDifficulty/dest", $("#destformatdifficulty"), "id", "NAME");
    achieveData("${basepath}/project/format/formatStability/src", $("#srcformatstability"), "id", "NAME");
    achieveData("${basepath}/project/format/formatStability/dest", $("#destformatstability"), "id", "NAME");
    achieveData("${basepath}/project/format/formatPrivileges/src", $("#srcformatprivileges"), "id", "name");
    achieveData("${basepath}/project/format/formatPrivileges/dest", $("#destformatprivileges"), "id", "name");
    achieveData("${basepath}/project/format/formatExpectedLevel/src", $("#srcformatexpectedlevel"), "id", "NAME");
    achieveData("${basepath}/project/format/formatExpectedLevel/dest", $("#destformatexpectedlevel"), "id", "NAME");
    achieveData("${basepath}/project/format/formatAlteredStatus/src", $("#srcformatalteredstatus"), "id", "name");
    achieveData("${basepath}/project/format/formatAlteredStatus/dest", $("#destformatalteredstatus"), "id", "name");
    achieveData("${basepath}/project/format/formatChangedManner/src", $("#srcformatchangedmanner"), "id", "name");
    achieveData("${basepath}/project/format/formatChangedManner/dest", $("#destformatchangedmanner"), "id", "name");

    bindSrcClick($("#srcformatcolumn"),         $("#destformatcolumn")          );
    bindSrcClick($("#srcformatdoctype"),        $("#destformatdoctype")         );
    bindSrcClick($("#srcformatitemtype"),       $("#destformatitemtype")        );
    bindSrcClick($("#srcformatitemstatus"),     $("#destformatitemstatus")      );
    bindSrcClick($("#srcformatitemchange"),     $("#destformatitemchange")      );
    bindSrcClick($("#srcformatdifficulty"),     $("#destformatdifficulty")      );
    bindSrcClick($("#srcformatstability"),      $("#destformatstability")       );
    bindSrcClick($("#srcformatprivileges"),     $("#destformatprivileges")      );
    bindSrcClick($("#srcformatexpectedlevel"),  $("#destformatexpectedlevel")   );
    bindSrcClick($("#srcformatalteredstatus"),  $("#destformatalteredstatus")   );
    bindSrcClick($("#srcformatchangedmanner"),  $("#destformatchangedmanner")   );

    bindDestClick($("#srcformatcolumn"),        $("#destformatcolumn")      , "${basepath}/project/format/formatColumn");
    bindDestClick($("#srcformatdoctype"),       $("#destformatdoctype")      , "${basepath}/project/format/formatDocType");
    bindDestClick($("#srcformatitemtype"),      $("#destformatitemtype")     , "${basepath}/project/format/formatItemType");
    bindDestClick($("#srcformatitemstatus"),    $("#destformatitemstatus")   , "${basepath}/project/format/formatItemStatus");
    bindDestClick($("#srcformatitemchange"),    $("#destformatitemchange")   , "${basepath}/project/format/formatItemChange");
    bindDestClick($("#srcformatdifficulty"),    $("#destformatdifficulty")   , "${basepath}/project/format/formatDifficulty");
    bindDestClick($("#srcformatstability"),     $("#destformatstability")    , "${basepath}/project/format/formatStability");
    bindDestClick($("#srcformatprivileges"),    $("#destformatprivileges")   , "${basepath}/project/format/formatPrivileges");
    bindDestClick($("#srcformatexpectedlevel"), $("#destformatexpectedlevel"), "${basepath}/project/format/formatExpectedLevel");
    bindDestClick($("#srcformatalteredstatus"), $("#destformatalteredstatus"), "${basepath}/project/format/formatAlteredStatus");
    bindDestClick($("#srcformatchangedmanner"), $("#destformatchangedmanner"), "${basepath}/project/format/formatChangedManner");

    function doImport() {
        if ($("#a").html() == "下一步") {
            window.location.href = "${basepath}/next";
            return;
        }
        $.ajax({
            url: "${basepath}/project/format/doimport",
            async: false, 
            success: function (result) {
                alert("需求导入成功");
                $("#a").html("下一步");
            },
            error: function (result) {
                alert("需求导入失败：" + JSON.stringify(result));
            }
        })
    }
    
</script>
</body>
</html>