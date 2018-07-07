var achieveData = function(url, div, prop_id, prop_name) {
    var parsetTreeView = function(list, div, prop_id, prop_name) {
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
    $.ajax({
        url: url,
        success: function (result) {
            parsetTreeView(result, div, prop_id, prop_name);
        }
    });
};
var bindSrcClick = function (divsrc,divdest) {
    divsrc.on("select_node.jstree", function (event, node) {
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