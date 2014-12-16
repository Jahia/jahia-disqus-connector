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

<template:addResources type="css" resources="admin-bootstrap.css"/>
<template:addResources type="css" resources="datatables/css/bootstrap-theme.css"/>

<template:addResources type="javascript" resources="jquery.min.js"/>
<template:addResources type="javascript" resources="admin-bootstrap.js"/>
<template:addResources type="javascript" resources="jquery-ui.min.js,jquery.blockUI.js,workInProgress.js"/>
<template:addResources type="javascript" resources="datatables/jquery.dataTables.js,i18n/jquery.dataTables-${currentResource.locale}.js,datatables/dataTables.bootstrap-ext.js"/>
<template:addResources type="javascript" resources="moment.min.js"/>
<template:addResources type="javascript" resources="disqusConnectorUtils.js"/>

<c:choose>
    <c:when test="${not empty param.disqusConnectorView}">
        <c:if test="${param.disqusConnectorView eq 'settings'}">
            <template:include templateType="html" view="settings"/>
        </c:if>
    </c:when>
    <c:otherwise>
        <jcr:node var="disqusSettings" path="${renderContext.site.path}/disqusSettings"/>
        <c:set var="shortname" value="${disqusSettings.properties['shortname'].string}"/>
        <c:set var="publicKey" value="${disqusSettings.properties['publicKey'].string}"/>

        <c:choose>
            <c:when test="${empty shortname or empty publicKey}">
                <%--or empty disqusSettings.properties['privateKey']--%>
                <template:include templateType="html" view="settings"/>
            </c:when>
            <c:otherwise>
                <template:include templateType="html" view="threads"/>
            </c:otherwise>
        </c:choose>
    </c:otherwise>
</c:choose>
