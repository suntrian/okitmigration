<html>
<head>
    <#assign basepath="${request.getContextPath()}">
    <title>选择单位/部门</title>
    <script src="${basepath}/js/jquery-3.3.1.min.js"></script>
    <script src="${basepath}/js/jstree.min.js"></script>
    <link rel="stylesheet" href="${basepath}/css/style.css">
    <link rel="stylesheet" href="${basepath}/css/my.css">
</head>
<body>
<div class="wrap">
    <div>
        <h1>选择单位/部门映射关系</h1>
        <ul>
            <li>
                1. 先选择上级单位/部门的对应关系，再选择下级单位的对应关系
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
                    <span>${treenode.self.name}</span>&nbsp;&nbsp;
                    <span>【<#if treenode.self.type=1><#if treenode.self.category_id=1>内部<#else >外部</#if>单位<#else >部门</#if>】</span>
                    <span class="<#if treenode.self.is_deleted=1>deleted<#else>normal</#if>">
                        <#if treenode.self.is_deleted=1>已删除<#else></#if>
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
    <div class="clear"></div>
    <div class="bottom">
        <div class="left">
            <a onclick="addUnit()" href="javascript:void(0);" >增加单位</a>
        </div>
        <div class="right">
            <a href="javascript:void(0);" onclick="save()">下一步</a>
        </div>
    </div>
</div>
<script>
    var srcUnitTree = $("#src_unit_tree");
    var destUnitTree = $("#dest_unit_tree");
    var selectedNode;
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
        refreshDestUnitTree(node.node);
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
    // destUnitTree.on('loaded.jstree', function (event, data) {
    //     console.log(data);
    // });

    destUnitTree.on('refresh.jstree', function (event, data) {
        if (selectedNode) {
            destUnitTree.jstree(true).select_node(selectedNode)
        }
    });

    destUnitTree.jstree({
        'core':{
            data: null
        },
        'plugins': ['search', 'wholerow', "checkbox"]
    });
    function addUnit() {
        var srcJsTree = srcUnitTree.jstree(true);
        var srcUnitId = srcJsTree.get_checked()[0];
        $.ajax({
            url: "${basepath}/unit",
            type: "POST",
            data:{
                id: srcUnitId
            },
            success: function (result) {
                if (result.success == true || result.data === "succeed"){
                    alert("添加单位成功");
                    refreshDestUnitTree(srcJsTree.get_node(srcUnitId));
                }
            }
        })
    }
    function save() {
        $.ajax({
            url: "${basepath}/unit/map/check",
            success: function (result) {
                if (!result.success) {
                    alert("还有单位/部门未能匹配");
                } else {
                    $.ajax({
                        url:"${basepath}/unit/map/save",
                        success: function (result) {
                            window.location.href = "${basepath}/step4";
                        }
                    })
                }
            }
        });
    }

    function refreshDestUnitTree(node) {
        $.ajax({
            url: "${basepath}/unit/dest/mapped",
            data: {
                id: node.parent==="#"?null:node.parent,
                selfid: node.id
            },
            success: function (data) {
                destUnitTree.jstree(true).deselect_all();
                var units = [];
                selectedNode = null;
                for (var sn = 0, len = data.length; sn < len; sn++){
                    var nodes = {};
                    nodes.id = data[sn].id;
                    nodes.text = data[sn].name + '【' + (data[sn].type==1?((data[sn].category_id==1?"内部":"外部") + "单位"):"部门")+ '】' + (data[sn].is_deleted?"<span class='deleted'>已删除</span>":"");
                    if (data[sn].selected){
                        selectedNode = nodes.id;
                        if (!nodes.state) {nodes.state = {}}
                        nodes.state.selected = true;
                        nodes.state.checked = true;
                    }
                    units.push(nodes);
                }
                destUnitTree.jstree(true).settings.core.data = units;
                destUnitTree.jstree(true).refresh();
            }
        });
    }

</script>
</body>
</html>