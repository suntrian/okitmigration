<html>
<head>
    <#assign basepath="${request.getContextPath()}">
    <title>选择人员</title>
    <script src="${basepath}/js/jquery-3.3.1.min.js"></script>
    <script src="${basepath}/js/jstree.min.js"></script>
    <link rel="stylesheet" href="${basepath}/css/style.css">
    <link rel="stylesheet" href="${basepath}/css/my.css">
</head>
<body>

    <div class="wrap">
        <div>
            <h1>选择人员映射关系</h1>
            <ul>
                <li>
                    下列人员无法按姓名匹配到唯一人员，请手动选择或添加
                </li>
                <li>
                    当存在同名人员时，选择左侧源系统中的人员，右侧会显示目标系统中的同名人员姓名及部门，请勾选对应人员
                </li>
                <li>
                    当未找到对应的人员时，选择左侧源系统中的人员，右侧将无人员显示，请点击添加，会自动将此人员添加到对应的部门下
                </li>
            </ul>
        </div>
        <div id="src_user" class="fixwidth">

        </div>
        <div id="dest_user" class="fixwidth">

        </div>
        <div class="clear"></div>
        <div class="bottom">
            <div class="left">
                <a id="add" href="javascript:void(0)" onclick="addUser()" >添加</a>
            </div>
            <div class="right">
                <a href="javascript:void(0)" onclick="save()">下一步</a>
            </div>
        </div>
    </div>
<script>

    $(document).ready(function () {
        $.ajax({
            url: "${basepath}/user/notmapped",
            success: function (result) {
                if (result.length == 0) {
                    $("#src_user").html("<em>人员已全部匹配</em>");
                    $("#add").hide();
                    return;
                }
                var nodes = []
                for (var i = 0, len =result.length; i < len; i++){
                    var user = result[i];
                    nodes.push({
                        id: user.id,
                        text: user.name + "【" + user.unit_name + "】" + (user.is_deleted?"<span class='deleted'>已删除</span>":""),
                        unit_id: user.unit_id,
                        unit_name: user.unit_name,
                        name: user.name
                    });
                }
                $("#src_user").jstree({
                    core: {
                        data: nodes
                    },
                    plugins: ["wholerow", "checkbox"]
                });
            }

        })
    });
    var selectedNode;
    $("#dest_user").on("refresh.jstree", function (event, data) {
        if (selectedNode) {
            $("#dest_user").jstree(true).select_node(selectedNode);
        }
    });

    $("#src_user").on("select_node.jstree", function (event, node) {
        var selectedUser = node.selected;
        var srcUserTree = $("#src_user").jstree(true);
        $.each(selectedUser, function (i, nd) {
            if (nd != node.node.id) {
                srcUserTree.uncheck_node(nd);
            }
        });
        //var srcUsername = srcUserTree.get_node(srcUserTree.get_checked()[0]).text;
        $.ajax({
            url: "${basepath}/user/dest",
            type: "GET",
            data: {
                id: node.node.id,
                name: node.node.original.name,
                unit_id: node.node.original.unit_id
            },
            success: function (result) {
                var userNodes = [];
                selectedNode = null;
                for (var i = 0 , len = result.length; i < len; i++){
                    var node = {};
                    node.id = result[i].id;
                    node.text = result[i].text + "【" + result[i].name + "】" + (result[i].is_deleted?"<span class='deleted'>已删除</span>":"");
                    if (result[i].state == "selected") {
                        selectedNode = node.id;
                    }
                    userNodes.push(node);
                }
                $("#dest_user").jstree(true).settings.core.data = userNodes;
                $("#dest_user").jstree(true).refresh();
            }
        });
    });
    $("#dest_user").on("select_node.jstree", function (event, node) {
       var srcUserTree = $("#src_user").jstree(true);
       var destUserTree = $("#dest_user").jstree(true);
       $.each(node.selected, function (i, nd) {
           if (nd != node.node.id){
               destUserTree.uncheck_node(nd);
           }
       });
       $.ajax({
           url: "${basepath}/user/map",
           type: 'POST',
           data:{
               src: srcUserTree.get_checked()[0],
               dest: node.node.id
           },
           success: function (result) {

           }
       })
    });

    $("#dest_user").jstree({
        core: {
            data: null
        },
        plugins: ["wholerow", "checkbox"]
    });
    function addUser() {
        var srcJstree = $("#src_user").jstree(true);
        var src_userid = srcJstree.get_checked()[0];
        $.ajax({
            url: "${basepath}/user",
            type: "POST",
            data:{
                id: src_userid
            },
            success: function (result) {
                srcJstree.hide_node(srcJstree.get_checked());
                //var success = srcJstree.delete_node(srcJstree.get_checked());
            },
            error: function (result) {
                alert(result);
            }
        })
    }
    function save() {
        $.ajax({
            url: "${basepath}/user/map/check",
            success: function (result) {
                if (!result.success ){
                    alert("还有人员未能匹配");
                } else {
                    $.ajax({
                        url: "${basepath}/user/map/save",
                        success: function (result) {
                            window.location.href = "${basepath}/step5";
                        }
                    });
                }
            }
        })
    }
</script>
</body>
</html>
