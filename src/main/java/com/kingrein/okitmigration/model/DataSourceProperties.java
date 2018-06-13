package com.kingrein.okitmigration.model;

public class DataSourceProperties {

    private String srcUrl;
    private String srcUsername;
    private String srcPassword;
    private String destUrl;
    private String destUsername;
    private String destPassword;

    public String getSrcUrl() {
        return srcUrl;
    }

    public void setSrcUrl(String srcUrl) {
        this.srcUrl = srcUrl;
    }

    public String getSrcUsername() {
        return srcUsername;
    }

    public void setSrcUsername(String srcUsername) {
        this.srcUsername = srcUsername;
    }

    public String getSrcPassword() {
        return srcPassword;
    }

    public void setSrcPassword(String srcPassword) {
        this.srcPassword = srcPassword;
    }

    public String getDestUrl() {
        return destUrl;
    }

    public void setDestUrl(String destUrl) {
        this.destUrl = destUrl;
    }

    public String getDestUsername() {
        return destUsername;
    }

    public void setDestUsername(String destUsername) {
        this.destUsername = destUsername;
    }

    public String getDestPassword() {
        return destPassword;
    }

    public void setDestPassword(String destPassword) {
        this.destPassword = destPassword;
    }
}
