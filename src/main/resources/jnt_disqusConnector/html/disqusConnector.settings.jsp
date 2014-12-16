<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="functions" uri="http://www.jahia.org/tags/functions" %>
<%@ taglib prefix="jcr" uri="http://www.jahia.org/tags/jcr" %>
<%@ taglib prefix="template" uri="http://www.jahia.org/tags/templateLib" %>
<%@ taglib prefix="uiComponents" uri="http://www.jahia.org/tags/uiComponentsLib" %>
<%@ taglib prefix="utility" uri="http://www.jahia.org/tags/utilityLib" %>
<%--@elvariable id="currentNode" type="org.jahia.services.content.JCRNodeWrapper"--%>
<%--@elvariable id="currentResource" type="org.jahia.services.render.Resource"--%>
<%--@elvariable id="out" type="java.io.PrintWriter"--%>
<%--@elvariable id="renderContext" type="org.jahia.services.render.RenderContext"--%>
<%--@elvariable id="script" type="org.jahia.services.render.scripting.Script"--%>
<%--@elvariable id="scriptInfo" type="java.lang.String"--%>
<%--@elvariable id="url" type="org.jahia.services.render.URLGenerator"--%>
<%--@elvariable id="workspace" type="java.lang.String"--%>

<jcr:node var="disqusSettings" path="${renderContext.site.path}/disqusSettings"/>
<c:set var="shortname" value="${disqusSettings.properties['shortname'].string}"/>
<c:set var="publicKey" value="${disqusSettings.properties['publicKey'].string}"/>

<template:addResources>
    <script type="text/javascript">
        var threads;
        var intervalValue;

        var API_URL = '${url.context}/modules/api/jcr/v1';
        var jcrShortname = '${functions:escapeJavaScript(shortname)}';
        var jcrPublickey = '${functions:escapeJavaScript(publicKey)}';
        var readUrl = API_URL + "/live/${renderContext.UILocale}/paths${renderContext.site.path}/disqusSettings";
        <c:choose>
            <c:when test="${empty disqusSettings}">
                var mode = 'create';
                var writeUrl = API_URL + "/default/${renderContext.UILocale}/nodes/${renderContext.site.identifier}";
            </c:when>
            <c:otherwise>
                var mode = 'update';
                var writeUrl = API_URL + "/default/${renderContext.UILocale}/nodes/${disqusSettings.identifier}";
            </c:otherwise>
        </c:choose>

        $(document).ready(function () {
            $('#disqusPublicKeyField').keyup(function() {
                if (($('#disqusPublicKeyField').val() != '' && $('#disqusShortnameField').val() != '')
                        && ($('#disqusPublicKeyField').val() != jcrPublickey)) {
                    $('#saveDisqusSettings').removeAttr("disabled");
                    $('#cancelChangeDisqusSettings').removeAttr("disabled");
                } else {
                    $('#saveDisqusSettings').attr("disabled", "disabled");
                    $('#cancelChangeDisqusSettings').attr("disabled", "disabled");
                }
            });

            $('#disqusShortnameField').keyup(function() {
                if (($('#disqusPublicKeyField').val() != '' && $('#disqusShortnameField').val() != '')
                        && ($('#disqusShortnameField').val() != jcrShortname)) {
                    $('#saveDisqusSettings').removeAttr("disabled");
                    $('#cancelChangeDisqusSettings').removeAttr("disabled");
                } else {
                    $('#saveDisqusSettings').attr("disabled", "disabled");
                    $('#cancelChangeDisqusSettings').attr("disabled", "disabled");
                }
            });
        });
    </script>
</template:addResources>

<div class="clearfix">
    <h1 class="pull-left"><fmt:message key="jnt_disqusConnector"/></h1>
    <div class="pull-right">
        <img alt="" src="<c:url value="${url.currentModule}/icons/disqus-logo-blue-transparent.png"/>"
        width="122" height="32">
    </div>
</div>

<c:if test="${not empty shortname and not empty publicKey}">
    <div class="row-fluid">
        <a href="<c:url value="${url.base}${renderContext.mainResource.node.path}.${renderContext.mainResource.template}.html"/>" class="btn pull-right">
            <i class="icon-list"></i>&nbsp;&nbsp;<fmt:message key="jnt_disqusConnector.button.backToTreads"/>
        </a>
    </div>
</c:if>

<div class="container">
    <div class="box-1">
        <div class="row-fluid">
            <div class="span6">
                <form class="form-horizontal" name="disqusParameters">
                    <fieldset>
                        <legend>
                            <fmt:message key="jnt_disqusConnector.title.accountInformation"/>
                        </legend>
                        <div class="control-group">
                            <label class="control-label">
                                <fmt:message key="jnt_disqusConnector.title.shortname"/>
                            </label>
                            <div class="controls">
                                <input id="disqusShortnameField" name="shortname" type="text"
                                       value="${shortname}"/>
                            </div>
                        </div>
                        <div class="control-group">
                            <label class="control-label">
                                <fmt:message key="jnt_disqusConnector.title.publicKey"/>
                            </label>
                            <div class="controls">
                                <input id="disqusPublicKeyField" name="publicKey" type="text"
                                       value="${publicKey}"/>
                            </div>
                        </div>
                        <div class="control-group">
                            <div class="controls">
                                <button id="saveDisqusSettings" type="button" class="btn btn-primary"
                                        onclick="createUpdateDisqusParameters(intervalValue)" disabled>
                                    <fmt:message key="label.save"/>
                                </button>
                                <c:if test="${not empty shortname and not empty publicKey}">
                                    <button id="cancelChangeDisqusSettings" type="button" class="btn btn-danger"
                                            onclick="resetDisqusSettings()" disabled>
                                        <fmt:message key="label.cancel"/>
                                    </button>
                                </c:if>
                            </div>
                        </div>
                    </fieldset>
                </form>
            </div>
            <div class="span6" style="text-align:justify">
                <div class="alert alert-info">
                    <h4><fmt:message key="jnt_disqusConnector.title.shortname"/></h4>
                    <p>
                        <fmt:message key="jnt_disqusConnector.help.getShortname"/><br/>
                        <fmt:message key="jnt_disqusConnector.help.getShortname2"/><br/>
                        <fmt:message key="jnt_disqusConnector.help.getShortname3"/><br/>
                    </p>
                </div>
                <div class="alert alert-info">
                    <h4><fmt:message key="jnt_disqusConnector.title.publicKey"/></h4>
                    <p>
                        <fmt:message key="jnt_disqusConnector.help.getPublicKey"/><br/>
                        <fmt:message key="jnt_disqusConnector.help.getPublicKey2"/><br/>
                        <fmt:message key="jnt_disqusConnector.help.getPublicKey3"/> : <br/>
                        <a href="https://disqus.com/api/applications/" target="_blank">
                            <fmt:message key="jnt_disqusConnector.help.applicationURL"/>
                        </a>
                    </p>
                </div>
            </div>
        </div>
    </div>
</div>