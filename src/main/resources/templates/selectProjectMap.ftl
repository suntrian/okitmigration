<html>
<head>
    <#assign basepath="${request.getContextPath()}">
    <title>选择项目</title>
    <script src="${basepath}/js/jquery-3.3.1.min.js"></script>
    <script src="${basepath}/js/jstree.min.js"></script>
    <link rel="stylesheet" href="${basepath}/css/style.css">
    <link rel="stylesheet" href="${basepath}/css/my.css">
</head>
<body>
<div class="wrap">
    <div>
        <h2>选择项目映射关系</h2>
    </div>
    <div class="fixwidth">
        <div id="project_src_tree" class="scroll_y "></div>
    </div>
    <div class="fixwidth">
        <div style="padding-left: 24px">
            <input id="search_desc" type="text" placeholder="查找...">
        </div>
        <div id="project_dest_tree" class="scroll_y"></div>
    </div>
    <div class="clear"></div>
    <div class="bottom">
        <div class="right">
                <a href="javascript:void(0);" onclick="save()">下一步</a>
        </div>
    </div>
</div>


<script>
    $("#project_src_tree").on("select_node.jstree", function (event, node) {
        var selectedNodes = node.selected;
        var djt = $("#project_src_tree").jstree(true);
        $.each(selectedNodes, function (i, nd) {
            if (nd != node.node.id){
                djt.uncheck_node(nd);
            }
        });
        var destProj = $("#project_dest_tree").jstree(true);
        destProj.uncheck_all();
    });

    $("#project_dest_tree").on("select_node.jstree", function (event, node) {
        var selectedNodes = node.selected;
        var sjt =  $("#project_dest_tree").jstree(true);
        $.each(selectedNodes, function(i, nd) {
            if (nd != node.node.id)
                sjt.uncheck_node(nd);
        });
        var srcProj = $("#project_src_tree").jstree(true);
        if (srcProj.get_checked().length == 0) {
            return;
        }
        $.ajax({
            url: "${basepath}/project/map",
            data: {
                src:  srcProj.get_checked()[0],
                dest: node.node.id
            },
            type: "POST",
            success: function (result) {
                console.log(result);
            }
        })

    });

    var to = false;
    $("#search_desc").keyup(function () {
        if (to) {
            clearTimeout(to);
        }
        to = setTimeout(function () {
            var v = $("#search_desc").val();
            $("#project_dest_tree").jstree(true).search(v);
        }, 250);
    });

    $("#project_src_tree").jstree({
        'core':{
            'data':{
                'url': "${basepath}/project/selected"
            }
        },
        'plugins': ["wholerow", "checkbox"]
    });

    $("#project_dest_tree").jstree({
        'core':{
            'data': {
                'url': "${basepath}/project/dest"
            }
        },
        'plugins': ["search", "wholerow", "checkbox"]
    });
    function save() {
        $.ajax({
            url: "${basepath}/project/map/save",
            success: function (result) {
                window.location.href = "${basepath}/step7"
            }
        })
    }
</script>
</body>
</html>