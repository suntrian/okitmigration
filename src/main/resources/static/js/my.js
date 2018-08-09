var parseTreeView = function(list, div, prop_id, prop_name) {
    var nodes = [];
    for (var sn = 0, len = list.length; sn < len; sn++) {
        var id = list[sn][prop_id];
        if (id.length>16) {
            id = id.substr(0,6);
        }
        nodes.push({
            id: list[sn][prop_id],
            text: '[' + id + ']' + list[sn][prop_name]
        })
    }

    div.jstree({
        core: {
            data: nodes
        },
        plugins: ["checkbox", "wholerow"]
    });
};

var parseTreeViewForWorkflow = function (list, div, prop_id, prop_name) {
    var nodes = [];
    for (var sn = 0, len = list.length; sn < len; sn++) {
        var id = list[sn][prop_id];
        var typeId = list[sn].config_id;
        var type = '';
        switch (typeId) {
            case 1:
                type = "缺陷";
                break;
            case 2:
                type = "需求";
                break;
            case 3:
                type = "问题";
                break;
            case 4:
                type = "风险";
                break;
        } 
        if (id.length>16) {
            id = id.substr(0,6);
        }
        nodes.push({
            id: list[sn][prop_id],
            text: '[' + id + ']' + '[' + type + ']' + list[sn][prop_name]
        });
    }

    div.jstree({
        core: {
            data: nodes
        },
        plugins: ["checkbox", "wholerow"]
    });
};

var achieveData = function(url, div, prop_id, prop_name, func) {

    $.ajax({
        url: url,
        success: function (result) {
            if (!func) {
                func = parseTreeView;
            }
            func(result, div, prop_id, prop_name);
        }
    });
};


var bindSrcClick = function (divsrc,divdest, url) {
    divsrc.on("select_node.jstree", function (event, node) {
        if (url) {
            $.ajax({
                url: url,
                type: "GET",
                data: {
                    src: node.node.id
                },
                success: function (result) {
                    if (result.data) {
                        divdest.jstree(true).select_node(result.data);
                    }
                }
            })
        }
        var treesrc = divsrc.jstree(true);
        $.each(node.selected, function (i, nd) {
            if (nd!=node.node.id) {
                treesrc.uncheck_node(nd);
            }
        });
        divdest.jstree(true).uncheck_all();
    });
};
var bindDestClick = function(divsrc, divdest, url) {
    divdest.on("select_node.jstree", function (event, node) {
        var treeDest = divdest.jstree(true);
        var treeSrc = divsrc.jstree(true);
        $.each(node.selected, function (i, nd) {
            if  (nd!=node.node.id) {
                treeDest.uncheck_node(nd);
            }
        });
        if (treeSrc.get_checked().length == 0) {
            return;
        }
        $.ajax({
            url: url,
            type: "POST",
            data: {
                src: treeSrc.get_checked()[0],
                dest: node.node.id
            },
            success: function (result) {

            }
        })
    });
};