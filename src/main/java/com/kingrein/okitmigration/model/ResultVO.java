package com.kingrein.okitmigration.model;

import java.util.Collection;

public class ResultVO {

    private Object data;
    private Boolean success;
    private Integer size;

    public ResultVO(Object data) {
        this.data = data;
    }

    public Object getData() {
        return data;
    }

    public void setData(Object data) {
        this.data = data;
    }

    public Boolean getSuccess() {
        return success;
    }

    public void setSuccess(Boolean success) {
        this.success = success;
    }

    public Integer getSize() {
        if (data instanceof Collection){
            return((Collection) data).size();
        } else {
            return 1;
        }
    }

    public void setSize(Integer size) {
        this.size = size;
    }


}
