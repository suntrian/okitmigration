<html>
<head>
    <#assign basepath="${request.getContextPath()}">
    <title>选择导入的内容</title>
    <script src="${basepath}/js/jquery-3.3.1.min.js"></script>
    <script src="${basepath}/js/jstree.min.js"></script>
    <link rel="stylesheet" href="${basepath}/css/style.css">
    <link rel="stylesheet" href="${basepath}/css/my.css">

</head>
<body>
    <div class="wrap">

        <h1>选择要导入的内容</h1>
        <div id="import">

        </div>
        <div class="bottom">
            <div class="left">
                <input type="checkbox" value="all" id="checkall">全选
            </div>
            <div class="right">
                <a href="javascript:void(0);" onclick="next_step()" title="下一步">下一步</a>
            </div>
        </div>
    </div>
    <script>
        $(document).ready(function () {
            $.ajax({
                url:"${basepath}/project/entity",
                type: "GET",
                success: function (result) {
                    var nodes = [];
                    for (var key in result) {
                        nodes.push({
                            id: key,
                            text: result[key]
                        })
                    }
                    $("#import").jstree({
                        core: {
                            data: nodes
                        },
                        plugins: ["wholerow","checkbox"]
                    })
                }
            })
        });
        function next_step() {
            var ids = $("#import").jstree(true).get_checked();
            $.ajax({
                url: "${basepath}/project/entity",
                type: "POST",
                data: JSON.stringify(ids),
                headers: {
                    "Content-Type": "application/json; charset=UTF-8"
                },
                success: function (result) {
                    window.location.href = "${basepath}/step8"
                }
            })
        }
        $('#checkall').on("click", function (v) {
            if ($('#checkall')[0].checked == true){
                $("#import").jstree(true).check_all();
            } else {
                $("#import").jstree(true).uncheck_all();
            }

        });
    </script>
</body>
</html>