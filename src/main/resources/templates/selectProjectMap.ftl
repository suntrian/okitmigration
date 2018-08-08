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
        <h1>选择项目映射关系</h1>
        <li>先选择上级项目的映射关系，再选择子项目的映射关系</li>
        <li>当无法找到对应的项目时，可选中源项目，再点击【添加项目】</li>
        <li>当添加项目时，有可能因项目标准字段配置不同等原因导致失败，请在oKit系统中手动添加项目</li>
        <li>即使项目添加成功，因项目标准字段配置及页面配置不同的原因，项目的标准属性配置与页面数据可能与源系统项目不同，需在oKit系统中手动修改</li>
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
        <div class="left">
            <a href="javascript:void(0);" onclick="addProject()">添加项目</a>
        </div>
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
        var srcProj = $("#project_src_tree").jstree(true);
        $.ajax({
            url: "${basepath}/project/map",
            type: "GET",
            data: {
                src: srcProj.get_checked()[0]
            }, 
            success: function (result) {
                if (result.data) {
                    destProj.select_node(result.data);
                }
            }
        });
    });

    $("#project_dest_tree").on("refresh.jstree", function (event, node) {
        
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
            $("#project_dest_tree").jstree(true).search(v, undefined, true);
        }, 250);
    });

    $("#project_src_tree").jstree({
        'core':{
            'data':{
                'url': "${basepath}/project/selected"
            }
        },
        "checkbox" :{
            "three_state": false,
            "cascade": ""
        },
        'plugins': ["wholerow", "checkbox"]
    });

    $("#project_dest_tree").jstree({
        'core':{
            'data': {
                'url': "${basepath}/project/dest"
            }
        },
        "checkbox": {
            "three_state": false,
            "cascade": ""
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
    function addProject() {
        $.ajax({
            url: "${basepath}/project/",
            type: "POST",
            data: {
                id: $("#project_src_tree").jstree(true).get_selected()[0]
            },
            success: function (result) {
                $("#project_dest_tree").jstree(true).refresh();
            },
            error: function (result) {
                alert("添加项目失败， 请检查项目类型，状态等系统标准是否一致");
            }
        })
    }
</script>
</body>
</html>