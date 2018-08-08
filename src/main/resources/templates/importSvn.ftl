<html>
<head>
    <#assign basepath="${request.getContextPath()}">
    <title>配置管理数据导入</title>
    <script src="${basepath}/js/jquery-3.3.1.min.js"></script>
    <script src="${basepath}/js/jstree.min.js"></script>
    <link rel="stylesheet" href="${basepath}/css/style.css">
    <link rel="stylesheet" href="${basepath}/css/my.css">
</head>
<body>
<div class="wrap">
    <div class="clear"></div>
    <div>
        <h2>
            导入配置管理数据
        </h2>
        <ul>
            <li>1. 将oKit安装目录下的svn/data目录下的所有目录拷出，粘贴到迁移节点对应的svn/data目录下，迁移的目标节点下不得存在同名目录</li>
            <li>2. svn数据迁移完成后，选择对应的节点</li>
            <li>3. 迁移成功后，请重新对SVN进行授权</li>
        </ul>
    </div>
    <div>
        <div id="svnnode"></div>
    </div>
    <div class="clear"></div>
    <div class="bottom">
        <div class="right">
            <a href="javascript:void(0);" onclick="doImport()" id="next">开始导入</a>
        </div>
    </div>
    <script>
        $(document).ready(function () {
            $.ajax({
                url: '${basepath}/project/svn/node',
                type: "GET",
                success : function (result) {
                    var nodes = [];
                    for (var sn in result) {
                        var node = result[sn];
                        var treenode = {
                            id: node.id,
                            text: node.name + "[" + node.ip + "]"
                        };
                        if (node.state && node.state == "selected") {
                            treenode['state'] = {
                                selected: true
                            }
                        }
                        nodes.push(treenode);
                    }
                    $("#svnnode").jstree({
                        core: {
                            data: nodes
                        },
                        plugins: ["checkbox", "wholerow"]
                    })
                }
            })
        });
        $("#svnnode").on("select_node.jstree", function (event, node) {
            var selectedNodes = node.selected;
            var djt = $("#svnnode").jstree(true);
            $.each(selectedNodes, function (i, nd) {
                if (nd != node.node.id){
                    djt.uncheck_node(nd);
                }
            });
            //$("#svnnode").jstree(true).uncheck_all();
            $.ajax({
                url: '${basepath}/project/svn/node',
                type: "POST",
                data: {
                    id: node.node.id
                },
                success: function (result) {

                }
            })
        });
        function doImport() {
            var svntree = $("#svnnode").jstree(true);
            if (svntree.get_checked().length == 0) return;
            if ($("#next").html() === "开始导入") {
                $.ajax({
                    url: "${basepath}/project/svn/doimport",
                    success: function (result) {
                        $("#next").html("下一步");
                        alert("配置库导入成功！")
                    }
                });
            } else {
                window.location.href = "${basepath}/next"
            }

        }
    </script>
</div>
</body>
</html>