<html>
<head>
    <#assign basepath="${request.getContextPath()}">
    <title>选择人员</title>
    <script src="${basepath}/js/jquery-3.3.1.min.js"></script>
    <script src="${basepath}/js/jstree.min.js"></script>
    <link rel="stylesheet" href="${basepath}/css/style.css">
    <style>
        .wrap{
            width: 1024px;
            margin: 0 auto;
        }
        .fixwidth {
            width: 512px;
            height: 768px;
            overflow-y: auto;
            float: left;
        }
    </style>
</head>
<body>
    <div class="wrap">
        <div id="src_user" class="fixwidth">

        </div>
        <div id="dest_user" class="fixwidth">

        </div>
        <div>
            <a href="${basepath}/step5" target="_self">下一步</a>
        </div>
    </div>
<script>
    $("#src_user").on("select_node.jstree", function (event, node) {
        var selectedUser = node.selected;
        var srcUserTree = $("#src_user").jstree(true);
        $.each(selectedUser, function (i, nd) {
            if (nd != node.node.id) {
                srcUserTree.uncheck_node(nd);
            }
        });
        var srcUsername = srcUserTree.get_node(srcUserTree.get_checked()[0]).text;
        $.ajax({
            url: "${basepath}/user/dest",
            type: "GET",
            data: {
                name: srcUsername
            },
            success: function (result) {
                var userNodes = [];
                for (var i = 0 , len = result.length; i < len; i++){
                    var node = {};
                    node.id = result[i].id;
                    node.text = result[i].text;
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

    $("#src_user").jstree({
        core:{
            data: {
                url: "${basepath}/user/notmapped"
            }
        },
        plugins: ["wholerow", "checkbox"]
    })
    $("#dest_user").jstree({
        core: {
            data: null
        },
        plugins: ["wholerow", "checkbox"]
    })

</script>
</body>
</html>
