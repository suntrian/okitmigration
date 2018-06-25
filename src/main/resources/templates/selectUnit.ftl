<html>
<head>
    <#assign basepath="${request.getContextPath()}">
    <title>选择单位/部门</title>
    <script src="${basepath}/js/jquery-3.3.1.min.js"></script>
    <script src="${basepath}/js/jstree.min.js"></script>
    <link rel="stylesheet" href="${basepath}/css/style.css">
    <style>
        .wrap{
            width: 800px;
            margin: 0 auto;
        }
        .fixwidth{
            width: 400px;
            height: 768px;
            overflow-y: auto;
            float: left;
        }
        .normal {
            color: #00ff00;
        }
        .deleted {
            color: #ff00ff;
        }
    </style>
</head>
<body>
<div class="wrap">
    <div>
        <h1>使用说明</h1>
        <ul>
            <li>
                1. 先选择上级单位的对应关系，再选择下级单位的对应关系
            </li>
            <li>
                2. 找不到对应的单位/部门时，选中源单位，然后点击【增加单位】。非外部单位请谨慎添加
            </li>
        </ul>

    </div>
    <div id="src_unit_tree" class="fixwidth">
        <#assign unit_counter=0>
        <#macro recurse_tree treenode depth=1>
            <#assign unit_counter=unit_counter+1 />
                <li id=${treenode.self.id} class="jstree-open">
                    <span>${treenode.self.name}</span>
                    <span class="<#if treenode.self.is_deleted=1>deleted<#else>normal</#if>">
                        <#if treenode.self.is_deleted=1>已删除<#else>正常</#if>
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
    <div id="dest_unit_tree"  class="fixwidth">

    </div>
    <div>
        <a onclick="addUnit()" >增加单位</a>
        <a href="${basepath}/step4" target="_self" >下一步</a>
    </div>
</div>
<script>
    var srcUnitTree = $("#src_unit_tree");
    var destUnitTree = $("#dest_unit_tree");
    destUnitTree.on("select_node.jstree", function (event, node) {
        var selectedNodes = node.selected;
        var djt = destUnitTree.jstree(true);
        $.each(selectedNodes, function (i, nd) {
            if (nd != node.node.id){
                djt.uncheck_node(nd);
            }
        });

        var jt = srcUnitTree.jstree(true);
        $.ajax({
            type: "POST",
            url: "${basepath}/unit/map",
            data: {
                src: jt.get_checked()[0],
                dest: node.node.id
            },
            success: function (result) {

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
        $.ajax({
            url: "${basepath}/unit/dest/mapped",
            data: {
                id: node.node.parent==="#"?null:node.node.parent,
                selfid: node.node.id
            },
            success: function (data) {
                destUnitTree.jstree(true).deselect_all();
                var units = [];
                var selectedNode;
                for (var sn = 0, len = data.length; sn < len; sn++){
                    var node = {};
                    node.id = data[sn].id;
                    node.text = data[sn].name;
                    if (data[sn].selected){
                        selectedNode = node.id;
                        if (!node.state) {node.state = {}}
                        node.state.selected = true;
                        node.state.checked = true;
                    }
                    units.push(node);
                };
                destUnitTree.jstree(true).settings.core.data = units;
                if (selectedNode) {
                    destUnitTree.jstree(true).select_node(selectedNode)
                }
                destUnitTree.jstree(true).refresh();
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
    destUnitTree.jstree({
        'core':{
            data: null
        },
        'plugins': ['search', 'wholerow', "checkbox"]
    });
    function addUnit() {
        var srcUnitId = srcUnitTree.jstree(true).get_checked()[0];
        $.ajax({
            url: "${basepath}/unit",
            type: "POST",
            data:{
                id: srcUnitId
            },
            success: function (result) {

            }
        })
    }
</script>
</body>
</html>