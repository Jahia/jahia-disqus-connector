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

<fmt:message key="jnt_disqusConnector.status.closed" var="statusClosed"/>
<fmt:message key="jnt_disqusConnector.status.open" var="statusOpen"/>
<fmt:message key="jnt_disqusConnector.empty.table" var="emptyTable"/>
<fmt:message key="jnt_disqusConnector.error.publicKey" var="errorPublicKey"/>

<template:addResources>
    <script type="text/javascript">
        var locale = '${renderContext.UILocale}';
        var jcrShortname = '${functions:escapeJavaScript(shortname)}';
        var jcrPublickey = '${functions:escapeJavaScript(publicKey)}';
        var threads;

        var jsVarMap = {
            statusClosed: '<span class="text-error"><strong>${functions:escapeJavaScript(statusClosed)}</strong></span>',
            statusOpen: '<span class="text-success">${functions:escapeJavaScript(statusOpen)}<strong></strong></span>',
            emptyTable: '${functions:escapeJavaScript(emptyTable)}',
            errorPublicKey: '${functions:escapeJavaScript(errorPublicKey)}'
        };

        $(document).ready(function () {
            //load datatable with the list of disqus threads calling disqus API
            loadDataTable(jcrShortname, jcrPublickey);
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

<div class="row-fluid">
    <c:set var="linkToSettings" value="${url.base}${renderContext.mainResource.node.path}.${renderContext.mainResource.template}.html"/>
    <a href="<c:url value='${linkToSettings}?disqusConnectorView=settings'/>" class="btn pull-right">
        <i class="icon-edit"></i>&nbsp;&nbsp;<fmt:message key="jnt_disqusConnector.button.editSettings"/>
    </a>
</div>

<div class="container">
    <div class="box-1">
        <div class="row-fluid">
            <h3><fmt:message key="jnt_disqusConnector.title.displayThreads"/></h3>
            <c:choose>
                <c:when test="${not empty shortname and not empty publicKey}">
                    <div id="dataTableDiv" class="row-fluid hide">
                        <div class="span12">
                            <fieldset>
                                <table cellpadding="0" cellspacing="0" border="0" class="table table-striped table-bordered"
                                       id="disqusThreads_table">
                                    <thead>
                                    <tr>
                                        <th><fmt:message key="jnt_disqusConnector.label.threadsTitle"/></th>
                                        <th><fmt:message key="jnt_disqusConnector.label.postNumber"/></th>
                                        <th><fmt:message key="label.created"/></th>
                                        <th><fmt:message key="jnt_disqusConnector.favorites"/></th>
                                        <th><fmt:message key="jnt_disqusConnector.status"/></th>
                                    </tr>
                                    </thead>
                                    <tbody id="tableBody">
                                    </tbody>
                                </table>
                            </fieldset>
                        </div>
                    </div>
                </c:when>
                <c:otherwise>
                    <div><fmt:message key="jnt_disqusConnector.noSettings"/></div>
                </c:otherwise>
            </c:choose>
            <div id="datatableErrorMessage">
                <%@include file="disqus.loader.jspf" %>
            </div>
        </div>
    </div>
</div>