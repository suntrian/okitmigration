<html>
<head>
    <title>选择单位/部门</title>
    <script src="/js/jquery-3.3.1.min.js"></script>
    <script src="/js/jstree.min.js"></script>
    <link rel="stylesheet" href="/css/style.css">
</head>
<body>
<div class="wrap">
    <div id="src_unit_tree">
        <#assign unit_counter=0>
        <#macro recurse_tree treenode depth=1>
            <#assign unit_counter=unit_counter+1 />
                <li id=${treenode.self.id} class="jstree-open">
                    <span>${unit_counter}/${depth}</span>
                    <span><#if (depth>1)>><#list 2..depth as sp>--</#list></#if>${treenode.self.name}</span>
                    <span>
                        <#if treenode.self.is_deleted=1>已删除
                        <#else >正常
                        </#if>
                    </span>
                    <#if (treenode.children)??>
                        <ul>
                        <#list treenode.children as subnode>
                            <@recurse_tree treenode=subnode depth=depth+1/>
                        </#list>
                        </ul>
                    </#if>
                </li>
        </#macro>

        <#list unitTreeNode as unitNode>
        <ul>
            <@recurse_tree treenode=unitNode />
        </ul>
        </#list>
    </div>
    <div id="dest_unit_tree">

    </div>
</div>
<script>
    var srcUnitTree = $("#src_unit_tree");
    var destUnitTree = $("#dest_unit_tree");
    destUnitTree.on("select_node.jstree", function (event, node) {
        var jt = srcUnitTree.jstree(true);
        $.ajax({
            type: "POST",
            url: "/unit/map",
            data: {
                src: jt.get_checked()[0],
                dest: node.node.id
            },
            success: function (result) {
                console.log(result);
            }
        })
    });
    srcUnitTree.on("select_node.jstree", function (event, node) {
        var selectedNodes = node.selected;
        var sjt = srcUnitTree.jstree(true);
        $.each(selectedNodes, function(i, nd) {
            if (nd != node.node.id)
                sjt.uncheck_node(nd);
        });
        console.log(node);
        $.ajax({
            url: "/unit/dest",
            data: {
                id: node.node.id
            },
            success: function (data) {

                destUnitTree.jstree({
                    core:{
                        data:[
                            'Simple root node',
                            {
                                'id': 12,
                                'text' : 'Root node 2',
                                'state' : {
                                    'opened' : true,
                                    'selected' : true
                                },
                                'children' : [
                                    {
                                        'id': 13,
                                        'text' : 'Child 1'
                                    },
                                    'Child 2'
                                ]
                            }
                        ]
                    }
                })
            }
        })
    });
    srcUnitTree.on("check_node.jstree", function (event, node) {
        console.log(node);
    });
    srcUnitTree.jstree({
        "checkbox" : {
            "keep_selected_style" : false,
            "three_state": false
        },
        "plugins" : ["search", "wholerow", "checkbox" ]
    });
</script>
</body>
</html>