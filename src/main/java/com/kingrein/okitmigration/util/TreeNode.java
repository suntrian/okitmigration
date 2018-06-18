package com.kingrein.okitmigration.util;

import com.fasterxml.jackson.annotation.JsonIgnore;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

public class TreeNode<T> {

    @JsonIgnore
    private TreeNode<T> parent;
    private List<TreeNode<T>> children;
    private T self;

    public TreeNode(T self){
        this.self = self;
        this.parent = null;
        this.children = new ArrayList<>();
    }

    public List<TreeNode<T>> addChild(TreeNode<T> node){
        node.setParent(this);
        this.children.add(node);
        return this.children;
    }

    public TreeNode<T> getParent() {
        return parent;
    }

    public void setParent(TreeNode<T> parent) {
        this.parent = parent;
    }

    public List<TreeNode<T>> getChildren() {
        return children;
    }

    public void setChildren(List<TreeNode<T>> children) {
        this.children = children;
    }

    public T getSelf() {
        return self;
    }

    public void setSelf(T self) {
        this.self = self;
    }
}
