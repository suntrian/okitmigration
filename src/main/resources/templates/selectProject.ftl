<html>
<head>
    <title>选择项目</title>
    <script src="/js/jquery-3.3.1.min.js"></script>
    <script src="/js/jstree.min.js"></script>
    <link rel="stylesheet" href="/css/style.css">
</head>
<body>
<div class="wrap">
    <div id="project_tree">
        <#assign proj_counter=0>
        <#macro recurse_tree treenode depth=1>
                <#assign proj_counter=proj_counter+1 />
                <li class="jstree-open">
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

    <input type="submit" onclick="" value="下一步">
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
</script>

</body>
</html>