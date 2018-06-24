<html>
<head>
    <title>选择将导入的项目</title>
    <script src="/js/jquery-3.3.1.min.js"></script>
    <script src="/js/jstree.min.js"></script>
    <link rel="stylesheet" href="/css/style.css">
    <style>
        .wrap{
            width: 1024px;
            margin: 0 auto;
        }
        .project_tree {
            height: 768px;
            overflow-y: auto;
        }
    </style>
</head>
<body>
<div class="wrap">
    <div id="project_tree" class="project_tree">
        <#assign proj_counter=0>
        <#macro recurse_tree treenode depth=1>
                <#assign proj_counter=proj_counter+1 />
                <li class="jstree-open" id="${treenode.self.id}">
                    <span>${proj_counter}/${depth}</span>
                    <span><#if (depth>1)>><#list 2..depth as sp>--</#list></#if>${treenode.self.name}</span>
                    <span>${treenode.self.project_code!}</span>
                    <#if (treenode.children)??>
                        <ul>
                        <#list treenode.children as subnode>
                            <@recurse_tree treenode=subnode depth=depth+1/>
                        </#list>
                        </ul>
                    </#if>
                </li>
        </#macro>

            <#list projectTreeNode as projectNode>
                <ul>
                <@recurse_tree treenode=projectNode />
                </ul>
            </#list>
    </div>
    <input type="checkbox" value="all" id="checkall">全选
    <span>&nbsp;&nbsp;&nbsp;&nbsp;</span>
    <input type="submit" onclick="submit()" value="下一步">
</div>
<script>
    var projectTree = $('#project_tree');
    projectTree.on("select_node.jstree", function (evnet, node) {
        console.log(node);
    });

    projectTree.on('check_node.jstree', function(event, obj) {
        var ref = $('#project_tree').jstree(true);
        var nodes = ref.get_checked();  //使用get_checked方法
        $.each(nodes, function(i, nd) {
            if (nd != obj.node.id)
                ref.uncheck_node(nd);
        });
    });
    projectTree.jstree({
        "checkbox" : {
            "keep_selected_style" : false,
            "three_state": false,
            "cascade": "up"
        },
        "plugins" : ["search","state", "wholerow", "checkbox" ]
    });
    var submit = function () {
        var ref = $('#project_tree').jstree(true);
        var idArray = ref.get_checked();
        var ids = [];
        for (var id in idArray){
            if (ids.indexOf(parseInt(idArray[id])) >= 0) continue;
            ids.push(parseInt(idArray[id]))
        }
        $.ajax({
            url: "/project/selected",
            data: JSON.stringify(ids),
            type: "POST",
            headers: {
                "Content-Type": "application/json; charset=UTF-8"
            },
            success: function (data) {
                if (data.data === "successed"){
                    window.location.href='/step6'
                }
            }
        })
    }
    $('#checkall').on("click", function (v) {
        if ($('#checkall')[0].checked == true){
            projectTree.jstree(true).check_all();
        } else {
            projectTree.jstree(true).uncheck_all();
        }

    });
</script>

</body>
</html>