<html>
<head>
    <title>选择人员</title>
    <script src="/js/jquery-3.3.1.min.js"></script>
    <script src="/js/jstree.min.js"></script>
    <link rel="stylesheet" href="/css/style.css">
</head>
<body>
    <div id="wrap">
        <div id="src_user">

        </div>
        <div id="dest_user">

        </div>
    </div>

    <div>
        <a href="/step5" target="_self">下一步</a>
    </div>
<script>

    var destUserTree = $("#dest_user").jstree(true);

    $("#src_user").on("select_node.jstree", function (event, node) {
        var selectedUser = node.selected;
        var srcUserTree = $("#src_user").jstree(true);
        $.each(selectedUser, function (i, nd) {
            if (nd != node.node.id) {
                srcUserTree.uncheck_node(nd);
            }
        });
        $.ajax({
            url: "",
            type: "GET",
            data: {
                src: srcUserTree.get_checked()[0]
            },
            success: function (result) {

            }
        })
    });

    $("#src_user").jstree({
        core:{
            data: {
                url: "/user/notmapped"
            }
        },
        plugins: ["wholerow", "checkbox"]
    })

</script>
</body>
</html>
